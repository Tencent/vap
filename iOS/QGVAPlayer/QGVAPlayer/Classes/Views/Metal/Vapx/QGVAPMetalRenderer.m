// QGVAPMetalRenderer.m
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
//
// Licensed under the MIT License (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

#import "QGVAPMetalRenderer.h"
#import "QGHWDMetalRenderer.h"
#import <MetalKit/MetalKit.h>
#import "QGVAPLogger.h"
#import <simd/simd.h>
#import "UIDevice+VAPUtil.h"
#import "QGVAPMetalUtil.h"
#import "QGVAPMetalShaderFunctionLoader.h"

#if TARGET_OS_SIMULATOR//模拟器
#else

@interface QGVAPMetalRenderer () {
    BOOL _renderingResourcesDisposed;      //用以标记渲染资源是否被回收
    matrix_float3x3 _currentColorConversionMatrix;
}

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> yuvMatrixBuffer;
@property (nonatomic, strong) id<MTLBuffer> maskBlurBuffer;
@property (nonatomic, strong) id<MTLRenderPipelineState> attachmentPipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> defaultMainPipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> mainPipelineStateForMask; //带遮罩处理的主流程管线
@property (nonatomic, strong) id<MTLRenderPipelineState> mainPipelineStateForMaskBlur; //带遮罩模糊处理的主流程管线
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) CVMetalTextureCacheRef videoTextureCache;//need release
@property (nonatomic, strong) QGVAPMetalShaderFunctionLoader *shaderFuncLoader;
@property (nonatomic, weak) CAMetalLayer *metalLayer;

@end

@implementation QGVAPMetalRenderer

- (instancetype)initWithMetalLayer:(CAMetalLayer *)layer {
    
    if (self = [super init]) {
        if (!kQGHWDMetalRendererDevice) {
            kQGHWDMetalRendererDevice = MTLCreateSystemDefaultDevice();
        }
        layer.device = kQGHWDMetalRendererDevice;
        _metalLayer = layer;
        [self setupRenderContext];
    }
    return self;
}

#pragma mark - main

- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer metalLayer:(CAMetalLayer *)layer mergeInfos:(NSArray<QGVAPMergedInfo *> *)infos {
    
    if (!layer.superlayer || layer.bounds.size.width <= 0 || layer.bounds.size.height <= 0) {
        //https://forums.developer.apple.com/thread/26278
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz layer.superlayer or size error is nil! superlayer:%@ height:%@ width:%@", layer.superlayer, @(layer.bounds.size.height), @(layer.bounds.size.width));
        return ;
    }
    [self reconstructIfNeed:layer];
    if (pixelBuffer == NULL || !self.commandQueue) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz pixelbuffer is nil!");
        return ;
    }
    [self updateMetalPropertiesIfNeed:pixelBuffer];
    CVMetalTextureCacheFlush(_videoTextureCache, 0);
    CVMetalTextureRef yTextureRef = nil, uvTextureRef = nil;
    size_t yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t yHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    size_t uvWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    size_t uvHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    //注意格式！r8Unorm
    CVReturn yStatus = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, nil, MTLPixelFormatR8Unorm, yWidth, yHeight, 0, &yTextureRef);
    //注意格式！rg8Unorm
    CVReturn uvStatus = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, nil, MTLPixelFormatRG8Unorm, uvWidth, uvHeight, 1, &uvTextureRef);
    if (yStatus != kCVReturnSuccess || uvStatus != kCVReturnSuccess) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz failing getting yuv texture-yStatus%@:uvStatus%@", @(yStatus), @(uvStatus));
        return ;
    }
    id<MTLTexture> yTexture = CVMetalTextureGetTexture(yTextureRef);
    id<MTLTexture> uvTexture = CVMetalTextureGetTexture(uvTextureRef);
    CVBufferRelease(yTextureRef);
    CVBufferRelease(uvTextureRef);
    CVMetalTextureCacheFlush(_videoTextureCache, 0);
    yTextureRef = NULL;
    uvTextureRef = NULL;
    if (!yTexture || !uvTexture || !layer) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz content is nil! y:%@ uv:%@, layer:%@", @(yTexture != nil), @(uvTexture != nil), @(layer != nil));
        return ;
    }
    if (layer.drawableSize.width  <= 0 || layer.drawableSize.height <= 0) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz drawableSize is 0");
        return ;
    }
    id<CAMetalDrawable> drawable = layer.nextDrawable;
    if (!drawable) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz nextDrawable is nil!");
        return ;
    }
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor new];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture; //which returns the texture in which you need to draw in order for something to appear on the screen.
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear; //“set the texture to the clear color before doing any drawing,”
    renderPassDescriptor.colorAttachments[0].clearColor =MTLClearColorMake(0.0, 0.0, 0.0, 0.0);
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    if (renderEncoder == nil) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz renderEncoder:%p or self.pipelineState:%p is nil!", renderEncoder);
        return ;
    }
    if (self.vertexBuffer == nil || self.yuvMatrixBuffer == nil) {
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz vertexBuffer:%p or yuvMatrixBuffer:%p is nil!", self.vertexBuffer, self.yuvMatrixBuffer);
        [renderEncoder endEncoding];
        return ;
    }
    
    [self drawBackground:yTexture uvTexture:uvTexture encoder:renderEncoder];
    [self drawMergedAttachments:infos yTexture:yTexture uvTexture:uvTexture renderEncoder:renderEncoder metalLayer:layer];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)drawBackground:(id<MTLTexture>)yTexture uvTexture:(id<MTLTexture>)uvTexture encoder:(id<MTLRenderCommandEncoder>)renderEncoder {
    
    if (self.maskInfo) {
        id<MTLTexture> maskTexture = self.maskInfo.texture;
        if (!maskTexture) {
            VAP_Error(kQGVAPModuleCommon, @"maskTexture error! maskTexture is nil");
            return;
        }
        
        if (!self.mainPipelineStateForMask) {
            VAP_Error(kQGVAPModuleCommon, @"maskPipelineState error! maskTexture is nil");
            return;
        }
        
        if (self.maskInfo.blurLength > 0) {
            [renderEncoder setRenderPipelineState:self.mainPipelineStateForMaskBlur];
            [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
            [renderEncoder setFragmentBuffer:self.yuvMatrixBuffer offset:0 atIndex:0];
            [renderEncoder setFragmentBuffer:self.maskBlurBuffer offset:0 atIndex:1];
            [renderEncoder setFragmentTexture:yTexture atIndex:QGHWDYUVFragmentTextureIndexLuma];
            [renderEncoder setFragmentTexture:uvTexture atIndex:QGHWDYUVFragmentTextureIndexChroma];
            [renderEncoder setFragmentTexture:maskTexture atIndex:QGHWDYUVFragmentTextureIndexAttachmentStart];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
        } else {
            [renderEncoder setRenderPipelineState:self.mainPipelineStateForMask];
            [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
            [renderEncoder setFragmentBuffer:self.yuvMatrixBuffer offset:0 atIndex:0];
            [renderEncoder setFragmentTexture:yTexture atIndex:QGHWDYUVFragmentTextureIndexLuma];
            [renderEncoder setFragmentTexture:uvTexture atIndex:QGHWDYUVFragmentTextureIndexChroma];
            [renderEncoder setFragmentTexture:maskTexture atIndex:QGHWDYUVFragmentTextureIndexAttachmentStart];
            [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
        }
    } else {
        if (!self.defaultMainPipelineState) {
            VAP_Error(kQGVAPModuleCommon, @"yuvPipelineState error! maskTexture is nil");
            return;
        }
        [renderEncoder setRenderPipelineState:self.defaultMainPipelineState];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [renderEncoder setFragmentBuffer:self.yuvMatrixBuffer offset:0 atIndex:0];
        [renderEncoder setFragmentTexture:yTexture atIndex:QGHWDYUVFragmentTextureIndexLuma];
        [renderEncoder setFragmentTexture:uvTexture atIndex:QGHWDYUVFragmentTextureIndexChroma];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
    }
}

- (void)dispose {
    
    _commandQueue = nil;
    _vertexBuffer = nil;
    _yuvMatrixBuffer = nil;
    _attachmentPipelineState = nil;
    _shaderFuncLoader = nil;
    if (_videoTextureCache) {
        CVMetalTextureCacheFlush(_videoTextureCache, 0);
        CFRelease(_videoTextureCache);
        _videoTextureCache = NULL;
    }
    _renderingResourcesDisposed = YES;
    _mainPipelineStateForMask = nil;
    _defaultMainPipelineState = nil;
}

-(void)dealloc {
    [self dispose];
}

- (void)setupRenderContext {
    
    //constants
    _currentColorConversionMatrix = kQGColorConversionMatrix601FullRangeDefault;
    struct ColorParameters yuvMatrixs[] = {{_currentColorConversionMatrix,{0.5, 0.5}}};
    NSUInteger yuvMatrixsDataSize = sizeof(struct ColorParameters);
    _yuvMatrixBuffer = [kQGHWDMetalRendererDevice newBufferWithBytes:yuvMatrixs length:yuvMatrixsDataSize options:kDefaultMTLResourceOption];
    
    //function loader
    self.shaderFuncLoader = [[QGVAPMetalShaderFunctionLoader alloc] initWithDevice:kQGHWDMetalRendererDevice];
    
    //command queue
    self.commandQueue = [kQGHWDMetalRendererDevice newCommandQueue];
    
    //texture cache
    CVReturn textureCacheError = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, kQGHWDMetalRendererDevice, nil, &_videoTextureCache);
    if (textureCacheError != kCVReturnSuccess) {
        VAP_Error(kQGVAPModuleCommon, @"create texture cache fail!:%@", textureCacheError);
    }
}

- (void)drawMergedAttachments:(NSArray<QGVAPMergedInfo *> *)infos
                       yTexture:(id<MTLTexture>)yTexture
                      uvTexture:(id<MTLTexture>)uvTexture
                  renderEncoder:(id<MTLRenderCommandEncoder>)encoder
                     metalLayer:(CAMetalLayer *)layer {
    
    if (infos.count == 0) {
        return ;
    }
    if (!encoder || !self.commonInfo || !self.attachmentPipelineState) {
        VAP_Error(kQGVAPModuleCommon, @"renderMergedAttachments error! infos:%@ encoder:%p commonInfo:%@ attachmentPipelineState:%p", @(infos.count), encoder, @(self.commonInfo != nil), self.attachmentPipelineState);
        return ;
    }
    if (yTexture == nil || uvTexture == nil) {
        VAP_Error(kQGVAPModuleCommon, @"renderMergedAttachments error! cuz yTexture:%p or uvTexture:%p is nil!", yTexture, uvTexture);
        return ;
    }
    [infos enumerateObjectsUsingBlock:^(QGVAPMergedInfo * _Nonnull mergeInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [encoder setRenderPipelineState:self.attachmentPipelineState];
        id<MTLTexture> sourceTexture = mergeInfo.source.texture;//图片纹理
        id<MTLBuffer> vertexBuffer = [mergeInfo vertexBufferWithContainerSize:self.commonInfo.size maskContianerSize:self.commonInfo.videoSize device:kQGHWDMetalRendererDevice];
        id<MTLBuffer> colorParamsBuffer = mergeInfo.source.colorParamsBuffer;
        id<MTLBuffer> yuvMatrixBuffer = self.yuvMatrixBuffer;
        if (!sourceTexture || !vertexBuffer || !colorParamsBuffer || !yuvMatrixBuffer) {
            //VAP_Error(kQGVAPModuleCommon, @"quit attachment:%p cuz-source:%p vertex:%p",mergeInfo, sourceTexture, vertexBuffer);
            return ;
        }
        [encoder setVertexBuffer:vertexBuffer offset:0 atIndex:0];
        [encoder setFragmentBuffer:yuvMatrixBuffer offset:0 atIndex:0];
        [encoder setFragmentBuffer:colorParamsBuffer offset:0 atIndex:1];
        //遮罩信息在视频流中
        [encoder setFragmentTexture:yTexture atIndex:QGHWDYUVFragmentTextureIndexLuma];
        [encoder setFragmentTexture:uvTexture atIndex:QGHWDYUVFragmentTextureIndexChroma];
        [encoder setFragmentTexture:sourceTexture atIndex:QGHWDYUVFragmentTextureIndexAttachmentStart];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4 instanceCount:1];
    }];
}

#pragma mark - setter&getter

- (id<MTLBuffer>)maskBlurBuffer {
    if (!_maskBlurBuffer) {
        struct MaskParameters parameters[] = {{kQGBlurWeightMatrixDefault, 3, 0.01}};
        NSUInteger parametersSize = sizeof(struct MaskParameters);
        _maskBlurBuffer = [kQGHWDMetalRendererDevice newBufferWithBytes:parameters length:parametersSize options:kDefaultMTLResourceOption];
    }
    return _maskBlurBuffer;
}

- (void)setCommonInfo:(QGVAPCommonInfo *)commonInfo {
    _commonInfo = commonInfo;
    [self updateMainVertexBuffer];
}

- (void)setMaskInfo:(QGVAPMaskInfo *)maskInfo {
    
    if (maskInfo && (!maskInfo.data || maskInfo.dataSize.width <= 0 || maskInfo.dataSize.height <= 0)) {
        VAP_Error(kQGVAPModuleCommon, @"setMaskInfo fail: data:%@, size:%@", maskInfo.data, NSStringFromCGSize(maskInfo.dataSize));
        return;
    }
    if (_maskInfo == maskInfo) {
        return ;
    }
    _maskInfo = maskInfo;
    if (_vertexBuffer) {
        [self updateMainVertexBuffer];
    }
}

#pragma mark - pipelines

- (id<MTLRenderPipelineState>)createPipelineState:(NSString *)vertexFunction fragmentFunction:(NSString *)fragmentFunction {
    
    id<MTLFunction> vertexProgram = [self.shaderFuncLoader loadFunctionWithName:vertexFunction];
    id<MTLFunction> fragmentProgram = [self.shaderFuncLoader loadFunctionWithName:fragmentFunction];
    
    if (!vertexProgram || !fragmentProgram) {
        VAP_Error(kQGVAPModuleCommon, @"setupPipelineStatesWithMetalLayer fail! cuz: shader load fail!");
        NSAssert(0, @"check if .metal files been compiled to correct target!");
        return nil;
    }
    
    //融混方程
    //https://objccn.io/issue-3-1/
    //https://www.andersriggelsen.dk/glblendfunc.php
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineStateDescriptor.vertexFunction = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = _metalLayer.pixelFormat;
    [pipelineStateDescriptor.colorAttachments[0] setBlendingEnabled:YES];
    pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor =  MTLBlendFactorSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    NSError *psError = nil;
    id<MTLRenderPipelineState> pipelineState = [kQGHWDMetalRendererDevice newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&psError];
    if (!pipelineState || psError) {
        VAP_Error(kQGVAPModuleCommon, @"newRenderPipelineStateWithDescriptor error!:%@", psError);
        return nil;
    }
    
    return pipelineState;
}

- (id<MTLRenderPipelineState>)defaultMainPipelineState {
    if (!_defaultMainPipelineState) {
        _defaultMainPipelineState = [self createPipelineState:kVAPVertexFunctionName fragmentFunction:kVAPYUVFragmentFunctionName];
    }
    return _defaultMainPipelineState;
}

- (id<MTLRenderPipelineState>)mainPipelineStateForMask {
    if (!_mainPipelineStateForMask) {
        _mainPipelineStateForMask = [self createPipelineState:kVAPVertexFunctionName fragmentFunction:kVAPMaskFragmentFunctionName];
    }
    return _mainPipelineStateForMask;
}

- (id<MTLRenderPipelineState>)attachmentPipelineState {
    if (!_attachmentPipelineState) {
        _attachmentPipelineState = [self createPipelineState:kVAPAttachmentVertexFunctionName fragmentFunction:kVAPAttachmentFragmentFunctionName];
    }
    return _attachmentPipelineState;
}

- (id<MTLRenderPipelineState>)mainPipelineStateForMaskBlur {
    if (!_mainPipelineStateForMaskBlur) {
        _mainPipelineStateForMaskBlur = [self createPipelineState:kVAPVertexFunctionName fragmentFunction:kVAPMaskBlurFragmentFunctionName];
    }
    return _mainPipelineStateForMaskBlur;
}

#pragma mark - private

- (void)reconstructIfNeed:(CAMetalLayer *)layer {
    
    if (_renderingResourcesDisposed) {
        [self setupRenderContext];
        _renderingResourcesDisposed = NO;
    }
}

- (void)updateMetalPropertiesIfNeed:(CVPixelBufferRef)pixelBuffer {
    
    if (!pixelBuffer) {
        return ;
    }
    CFTypeRef yCbCrMatrixType = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    matrix_float3x3 matrix = kQGColorConversionMatrix601FullRangeDefault;
    if (CFStringCompare(yCbCrMatrixType, kCVImageBufferYCbCrMatrix_ITU_R_709_2, 0) == kCFCompareEqualTo) {
        matrix = kQGColorConversionMatrix709FullRangeDefault;
    }
    if (simd_equal(_currentColorConversionMatrix, matrix)) {
        return ;
    }
    _currentColorConversionMatrix = matrix;
    struct ColorParameters yuvMatrixs[] = {{_currentColorConversionMatrix,{0.5, 0.5}}};
    NSUInteger yuvMatrixsDataSize = sizeof(struct ColorParameters);
    _yuvMatrixBuffer = [kQGHWDMetalRendererDevice newBufferWithBytes:yuvMatrixs length:yuvMatrixsDataSize options:kDefaultMTLResourceOption];
}

- (void)updateMainVertexBuffer {
    
    const int colunmCountForVertices = 4, colunmCountForCoordinate = 2, vertexDataLength = 40; //顶点(x,y,z,w),纹理坐标(x,x),数组长度
    static float vertexData[vertexDataLength]; //顶点+纹理坐标数据
    float rgbCoordinates[8], alphaCoordinates[8];
    float maskCoordinates[8] = {0};
    const void *vertices = kVAPMTLVerticesIdentity;
    
    genMTLTextureCoordinates(self.commonInfo.rgbAreaRect, self.commonInfo.videoSize, rgbCoordinates, NO, 0);
    genMTLTextureCoordinates(self.commonInfo.alphaAreaRect, self.commonInfo.videoSize, alphaCoordinates, NO, 0);
    if (self.maskInfo) {
        genMTLTextureCoordinates(self.maskInfo.sampleRect, self.maskInfo.dataSize, maskCoordinates, NO, 0);
    }
    
    int indexForVertexData = 0;
    //顶点数据+坐标。==> 这里的写法需有优化一下
    for (int i = 0; i < 4 * colunmCountForVertices; i ++) {
        //顶点数据
        vertexData[indexForVertexData++] = ((float*)vertices)[i];
        //逐行处理
        if (i%colunmCountForVertices == colunmCountForVertices-1) {
            int row = i/colunmCountForVertices;
            //rgb纹理坐标
            vertexData[indexForVertexData++] = ((float*)rgbCoordinates)[row*colunmCountForCoordinate];
            vertexData[indexForVertexData++] = ((float*)rgbCoordinates)[row*colunmCountForCoordinate+1];
            //alpha纹理坐标
            vertexData[indexForVertexData++] = ((float*)alphaCoordinates)[row*colunmCountForCoordinate];
            vertexData[indexForVertexData++] = ((float*)alphaCoordinates)[row*colunmCountForCoordinate+1];
            //mask纹理坐标
            vertexData[indexForVertexData++] = ((float*)maskCoordinates)[row*colunmCountForCoordinate];
            vertexData[indexForVertexData++] = ((float*)maskCoordinates)[row*colunmCountForCoordinate+1];
        }
    }
    NSUInteger allocationSize = vertexDataLength * sizeof(float);
    id<MTLBuffer> vertexBuffer = [kQGHWDMetalRendererDevice newBufferWithBytes:vertexData length:allocationSize options:kDefaultMTLResourceOption];
    _vertexBuffer = vertexBuffer;
}

@end

#endif
