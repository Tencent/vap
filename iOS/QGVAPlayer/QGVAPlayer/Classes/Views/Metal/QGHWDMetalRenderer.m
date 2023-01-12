// QGHWDMetalRenderer.m
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

#import "QGHWDMetalRenderer.h"
#import "QGHWDShaderTypes.h"
#import "QGVAPLogger.h"
#import <simd/simd.h>
#import <MetalKit/MetalKit.h>
#import "UIDevice+VAPUtil.h"
#import "QGVAPMetalUtil.h"
#import "QGVAPMetalShaderFunctionLoader.h"

#pragma mark - constants

NSString *const kQGHWDVertexFunctionName      = @"hwd_vertexShader";
NSString *const kQGHWDYUVFragmentFunctionName = @"hwd_yuvFragmentShader";

static NSInteger const kQGQuadVerticesConstantsRow    = 4;
static NSInteger const kQGQuadVerticesConstantsColumn = 32;
static NSInteger const kQGHWDVertexCount              = 4;

id<MTLDevice> kQGHWDMetalRendererDevice;

// BT.601, which is the standard for SDTV.
matrix_float3x3 const kQGColorConversionMatrix601Default = {{
    {1.164,     1.164,      1.164},
    {0.0,       -0.392,     2.017},
    {1.596,     -0.813,     0.0}
}};

/*矩阵形式！！！
 1.0 0.0 1.4
 [1.0 -0.343 -0.711 ]
 1.0 1.765 0.0
 */
//ITU BT.601 Full Range
 matrix_float3x3 const kQGColorConversionMatrix601FullRangeDefault = {{
    {1.0,       1.0,        1.0},
    {0.0,       -0.34413,   1.772},
    {1.402,     -0.71414,   0.0}
}};

// BT.709, which is the standard for HDTV.
matrix_float3x3 const kQGColorConversionMatrix709Default = {{
    {1.164,     1.164,      1.164},
    {0.0,       -0.213,     2.112},
    {1.793,     -0.533,     0.0}
}};

// BT.709 Full Range.
matrix_float3x3 const kQGColorConversionMatrix709FullRangeDefault = {{
    {1.0,       1.0,        1.0},
    {0.0,       -.18732,    1.8556},
    {1.57481,   -.46813,    0.0}
}};

// Blur weight matrix.
matrix_float3x3 const kQGBlurWeightMatrixDefault = {{
    {0.0625,     0.125,      0.0625},
    {0.125,      0.25,       0.125},
    {0.0625,     0.125,      0.0625}
}};

//QGHWDVertex  顶点坐标+纹理坐标（rgb+alpha）
static const float kQGQuadVerticesConstants[kQGQuadVerticesConstantsRow][kQGQuadVerticesConstantsColumn] = {
    //左侧alpha
    {-1.0, -1.0, 0.0, 1.0, 0.5, 1.0, 0.0, 1.0,
    -1.0, 1.0, 0.0, 1.0, 0.5, 0.0, 0.0, 0.0,
    1.0, -1.0, 0.0, 1.0, 1.0, 1.0, 0.5, 1.0,
    1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.5, 0.0},
    //右侧alpha
    {-1.0, -1.0, 0.0, 1.0, 0.0, 1.0, 0.5, 1.0,
    -1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.0,
    1.0, -1.0, 0.0, 1.0, 0.5, 1.0, 1.0, 1.0,
    1.0, 1.0, 0.0, 1.0, 0.5, 0.0, 1.0, 0.0},
    //顶部alpha
    {-1.0, -1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.5,
    -1.0, 1.0, 0.0, 1.0, 0.0, 0.5, 0.0, 0.0,
    1.0, -1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.5,
    1.0, 1.0, 0.0, 1.0, 1.0, 0.5, 1.0, 0.0},
    //底部alpha
    {-1.0, -1.0, 0.0, 1.0, 0.0, 0.5, 0.0, 1.0,
     -1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5,
     1.0, -1.0, 0.0, 1.0, 1.0, 0.5, 1.0, 1.0,
     1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.5}
};

#if TARGET_OS_SIMULATOR//模拟器
#else

@interface QGHWDMetalRenderer () {
    BOOL _renderingResourcesDisposed;      //用以标记渲染资源是否被回收
    matrix_float3x3 _currentColorConversionMatrix;
}

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> yuvMatrixBuffer;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;//This will keep track of the compiled render pipeline you’re about to create.
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) int vertexCount;
@property (nonatomic, assign) CVMetalTextureCacheRef videoTextureCache;//need release
@property (nonatomic, strong) QGVAPMetalShaderFunctionLoader *shaderFuncLoader;

@end

@implementation QGHWDMetalRenderer

#pragma mark - main
- (instancetype)initWithMetalLayer:(CAMetalLayer *)layer blendMode:(QGHWDTextureBlendMode)mode {
    self = [super init];
    if (self) {
        _blendMode = mode;
        if (!kQGHWDMetalRendererDevice) {
            kQGHWDMetalRendererDevice = MTLCreateSystemDefaultDevice();
        }
        layer.device = kQGHWDMetalRendererDevice;
        [self setupConstants];
        [self setupPipelineStatesWithMetalLayer:layer];
    }
    return self;
}

/**
 回收渲染数据，减少内存占用
 */
- (void)dispose {
    
    _commandQueue = nil;
    _pipelineState = nil;
    _vertexBuffer = nil;
    _yuvMatrixBuffer = nil;
    _shaderFuncLoader = nil;
    if (_videoTextureCache) {
        CVMetalTextureCacheFlush(_videoTextureCache, 0);
        CFRelease(_videoTextureCache);
        _videoTextureCache = NULL;
    }
    _renderingResourcesDisposed = YES;
}

- (void)dealloc {
    [self dispose];
}

- (void)setupConstants {
    //buffers
    const void *vertices = [self suitableQuadVertices];
    NSUInteger allocationSize = kQGQuadVerticesConstantsColumn * sizeof(float);
    _vertexBuffer = [kQGHWDMetalRendererDevice newBufferWithBytes:vertices length:allocationSize options:kDefaultMTLResourceOption];
    _vertexCount = kQGHWDVertexCount;
    _currentColorConversionMatrix = kQGColorConversionMatrix601FullRangeDefault;
    struct ColorParameters yuvMatrixs[] = {{_currentColorConversionMatrix,{0.5, 0.5}}};
    NSUInteger yuvMatrixsDataSize = sizeof(struct ColorParameters);
    _yuvMatrixBuffer = [kQGHWDMetalRendererDevice newBufferWithBytes:yuvMatrixs length:yuvMatrixsDataSize options:kDefaultMTLResourceOption];
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

- (void)setupPipelineStatesWithMetalLayer:(CAMetalLayer *)metalLayer {
    
    self.shaderFuncLoader = [[QGVAPMetalShaderFunctionLoader alloc] initWithDevice:kQGHWDMetalRendererDevice];
    id<MTLFunction> vertexProgram = [self.shaderFuncLoader loadFunctionWithName:kQGHWDVertexFunctionName];
    id<MTLFunction> fragmentProgram = [self.shaderFuncLoader loadFunctionWithName:kQGHWDYUVFragmentFunctionName];
    
    if (!vertexProgram || !fragmentProgram) {
        VAP_Error(kQGVAPModuleCommon, @"setupPipelineStatesWithMetalLayer fail! cuz: shader load fail");
        NSAssert(0, @"check if .metal files been compiled to correct target!");
        return ;
    }
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineStateDescriptor.vertexFunction = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat;
    NSError *psError = nil;
    id<MTLRenderPipelineState> pipelineState = [kQGHWDMetalRendererDevice newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&psError];
    if (!pipelineState || psError) {
        VAP_Error(kQGVAPModuleCommon, @"newRenderPipelineStateWithDescriptor error!:%@", psError);
        return ;
    }
    self.pipelineState = pipelineState;
    self.commandQueue = [kQGHWDMetalRendererDevice newCommandQueue];
    CVReturn textureCacheError = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, kQGHWDMetalRendererDevice, nil, &_videoTextureCache);
    if (textureCacheError != kCVReturnSuccess) {
        VAP_Error(kQGVAPModuleCommon, @"create texture cache fail!:%@", textureCacheError);
        return ;
    }
}

/**
 使用metal渲染管线渲染CVPixelBufferRef，若有需要融合的图层则通过对应的管线一并渲染

 @param pixelBuffer 图像数据
 @param layer metalLayer
 */
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer metalLayer:(CAMetalLayer *)layer {
    
    if (!layer.superlayer || layer.bounds.size.width <= 0 || layer.bounds.size.height <= 0) {
        //https://forums.developer.apple.com/thread/26278
        VAP_Error(kQGVAPModuleCommon, @"quit rendering cuz layer.superlayer or size error is nil! superlayer:%@ height:%@ width:%@", layer.superlayer, @(layer.bounds.size.height), @(layer.bounds.size.width));
        return ;
    }
    [self reconstructIfNeed:layer];
    if (pixelBuffer == NULL || !self.commandQueue || !self.pipelineState) {
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
    renderPassDescriptor.colorAttachments[0].clearColor =MTLClearColorMake(1.0, 1.0, 1.0, 1.0);
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderEncoder setFragmentBuffer:self.yuvMatrixBuffer offset:0 atIndex:0];
    [renderEncoder setFragmentTexture:yTexture atIndex:QGHWDYUVFragmentTextureIndexLuma];
    [renderEncoder setFragmentTexture:uvTexture atIndex:QGHWDYUVFragmentTextureIndexChroma];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:self.vertexCount instanceCount:1];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

#pragma mark - private

/**
 在必要的时候重建渲染数据，以便渲染
 
 @param layer metalLayer
 */
- (void)reconstructIfNeed:(CAMetalLayer *)layer {
    if (_renderingResourcesDisposed) {
        [self setupConstants];
        [self setupPipelineStatesWithMetalLayer:layer];
        _renderingResourcesDisposed = NO;
    }
}

- (const void *)suitableQuadVertices {
    
    switch (self.blendMode) {
        case QGHWDTextureBlendMode_AlphaLeft:
            return kQGQuadVerticesConstants[0];
        case QGHWDTextureBlendMode_AlphaRight:
            return kQGQuadVerticesConstants[1];
        case QGHWDTextureBlendMode_AlphaTop:
            return kQGQuadVerticesConstants[2];
        case QGHWDTextureBlendMode_AlphaBottom:
            return kQGQuadVerticesConstants[3];
        default:
            break;
    }
    return kQGQuadVerticesConstants[0];
}

@end
#endif
