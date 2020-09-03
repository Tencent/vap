// QGVAPConfigModel.m
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

#import "QGVAPConfigModel.h"
#import "NSDictionary+VAPUtil.h"
#import "QGVAPMetalUtil.h"
#import "QGVAPLogger.h"
#import "UIDevice+VAPUtil.h"

//资源适配类型
QGAGAttachmentFitType       const kQGAGAttachmentFitTypeFitXY          = @"fitXY";         //按指定尺寸缩放
QGAGAttachmentFitType       const kQGAGAttachmentFitTypeCenterFull     = @"centerFull";    //默认按资源尺寸展示，如果资源尺寸小于遮罩，则等比缩放至可填满
//资源类型
QGAGAttachmentSourceType    const kQGAGAttachmentSourceTypeTextStr     = @"textStr";       //文字
QGAGAttachmentSourceType    const kQGAGAttachmentSourceTypeImgUrl      = @"imgUrl";        //图片

QGAGAttachmentSourceType    const kQGAGAttachmentSourceTypeText        = @"txt";       //文字
QGAGAttachmentSourceType    const kQGAGAttachmentSourceTypeImg         = @"img";        //图片
QGAGAttachmentSourceLoadType const QGAGAttachmentSourceLoadTypeLocal   = @"local";
QGAGAttachmentSourceLoadType const QGAGAttachmentSourceLoadTypeNet     = @"net";

//字体
QGAGAttachmentSourceStyle   const kQGAGAttachmentSourceStyleBoldText   = @"b";             //粗体

@implementation QGVAPConfigModel

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {info:%@, configs:%@}", self.class, self, _info, _mergedConfig];
}

@end

@implementation QGVAPCommonInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {version:%@, frames:%@, size:(%@,%@), videoSize:(%@,%@) orien:%@, fps:%@, merged:%@, alpha:(%@,%@,%@,%@), rgb:(%@,%@,%@,%@)}", self.class, self, @(_version), @(_framesCount), @(_size.width), @(_size.height), @(_videoSize.width), @(_videoSize.height), @(_targetOrientaion), @(_fps), @(_isMerged), @(_alphaAreaRect.origin.x), @(_alphaAreaRect.origin.y), @(_alphaAreaRect.size.width), @(_alphaAreaRect.size.height), @(_rgbAreaRect.origin.x), @(_rgbAreaRect.origin.y), @(_rgbAreaRect.size.width), @(_rgbAreaRect.size.height)];
}

@end

@implementation QGVAPSourceInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {type:%@, tag:%@-%@ color:%@, style:%@, size:(%@,%@), fitType:%@}", self.class, self, _type, _contentTag, _contentTagValue, _color, _style, @(_size.width), @(_size.height), _fitType];
}

@end

@implementation QGVAPSourceDisplayItem

@end

@implementation QGVAPMergedInfo

- (id<MTLBuffer>)vertexBufferWithContainerSize:(CGSize)size maskContianerSize:(CGSize)mSize device:(id<MTLDevice>)device {
    
    if (size.width <= 0 || size.height <= 0 || mSize.width <= 0 || mSize.height <= 0) {
        VAP_Error(kQGVAPModuleCommon, @"vertexBufferWithContainerSize size error! :%@ - %@", [NSValue valueWithCGSize:size], [NSValue valueWithCGSize:mSize]);
        NSAssert(0, @"vertexBufferWithContainerSize size error!");
        return nil;
    }
    const int colunmCountForVertices = 4, colunmCountForCoordinate = 2, vertexDataLength = 32;
    float vertices[16], maskCoordinates[8], sourceCoordinates[8];
    genMTLVertices(self.renderRect, size, vertices, NO);
    genMTLTextureCoordinates(self.maskRect, mSize, maskCoordinates,YES, self.maskRotation);
    
    if ([self.source.fitType isEqualToString:kQGAGAttachmentFitTypeCenterFull]) {
        CGRect sourceRect = vapRectForCenterFull(self.source.size, self.renderRect.size);
        CGSize sourceSize = vapSourceSizeForCenterFull(self.source.size, self.renderRect.size);
        genMTLTextureCoordinates(sourceRect, sourceSize, sourceCoordinates,NO, 0);
    } else {
        replaceArrayElements(sourceCoordinates, (void*)kVAPMTLTextureCoordinatesIdentity, 8);
    }
    static float vertexData[vertexDataLength];
    int indexForVertexData = 0;
    //顶点数据+纹理坐标+遮罩纹理坐标
    for (int i = 0; i < 16; i ++) {
        vertexData[indexForVertexData++] = ((float*)vertices)[i];
        if (i%colunmCountForVertices == colunmCountForVertices-1) {
            int row = i/colunmCountForVertices;
            vertexData[indexForVertexData++] = ((float*)sourceCoordinates)[row*colunmCountForCoordinate];
            vertexData[indexForVertexData++] = ((float*)sourceCoordinates)[row*colunmCountForCoordinate+1];
            vertexData[indexForVertexData++] = ((float*)maskCoordinates)[row*colunmCountForCoordinate];
            vertexData[indexForVertexData++] = ((float*)maskCoordinates)[row*colunmCountForCoordinate+1];
        }
    }
    NSUInteger allocationSize = vertexDataLength * sizeof(float);
    id<MTLBuffer> vertexBuffer = [device newBufferWithBytes:vertexData length:allocationSize options:kDefaultMTLResourceOption];
    return vertexBuffer;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {index:%@, rect:(%@,%@,%@,%@), mask:%@, maskRect:(%@,%@,%@,%@), maskRotation:%@, source:%@}", self.class, self, @(_renderIndex), @(_renderRect.origin.x), @(_renderRect.origin.y), @(_renderRect.size.width), @(_renderRect.size.height), @(_needMask), @(_maskRect.origin.x), @(_maskRect.origin.y), @(_maskRect.size.width), @(_maskRect.size.height), @(_maskRotation), _source];
}

@end
