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
#import "NSDictionary+HWDUtil.h"

//资源适配类型
VapAttachmentFitType       const kVapAttachmentFitTypeFitXY          = @"fitXY";         //按指定尺寸缩放
VapAttachmentFitType       const kVapAttachmentFitTypeCenterFull     = @"centerFull";    //默认按资源尺寸展示，如果资源尺寸小于遮罩，则等比缩放至可填满
//资源类型
VapAttachmentSourceType    const kVapAttachmentSourceTypeTextStr     = @"txt";       //文字
VapAttachmentSourceType    const kVapAttachmentSourceTypeImgUrl      = @"img";        //图片

//资源加载类型
VapAttachmentLoadType      const kVapAttachmentLoadTypeLocal         = @"local";
VapAttachmentLoadType      const kVapAttachmentLoadTypeNet           = @"net";

//字体
VapAttachmentSourceStyle   const kVapAttachmentSourceStyleBoldText   = @"b";             //粗体
//遮罩融合类型
VapAttachmentMaskType      const kVapAttachmentMaskTypeSrcOut        = @"srcOut";        //表示去除遮挡区域
VapAttachmentMaskType      const kVapAttachmentMaskTypeSrcIn         = @"srcIn";         //表示根据遮罩形状裁剪
VapAttachmentMaskType      const kVapAttachmentMaskTypeSrcMix        = @"srcMix";

NSInteger const kVapLayoutMaxWidth = 1504;

@implementation QGVAPConfigModel

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {info:%@, configs:%@}", self.class, self, _info, _mergedConfig];
}

- (NSString *)jsonString {
    
    NSString *infoJson = [self.info jsonString];
    __block NSString *srcString = nil;
    __block NSString *framesString = nil;
    
    if (self.resources.count > 0) {
        srcString = @"[";
        [self.resources enumerateObjectsUsingBlock:^(QGVAPSourceInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            srcString = [srcString stringByAppendingString:[obj jsonString]];
            if (idx != self.resources.count-1) {
                srcString = [srcString stringByAppendingString:@","];
            }
        }];
        srcString = [srcString stringByAppendingString:@"]"];
    }
    
    if (self.mergedConfig.count > 0) {
        framesString = @"[";
        [self.mergedConfig enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSArray<QGVAPMergedInfo *> * _Nonnull obj, BOOL * _Nonnull stop) {
            
            __block NSString *objString = @"[";
            [obj enumerateObjectsUsingBlock:^(QGVAPMergedInfo * _Nonnull mergInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                objString = [objString stringByAppendingString:[mergInfo jsonString]];
                objString = [objString stringByAppendingString:@","];
            }];
            if([objString hasSuffix:@","]) {
                objString = [objString substringToIndex:objString.length-1];
            }
            objString = [objString stringByAppendingString:@"]"];
            framesString = [framesString stringByAppendingString:[NSString stringWithFormat:@"{\"i\":%@,\"obj\":%@},", key, objString]];
        }];
        if([framesString hasSuffix:@","]) {
            framesString = [framesString substringToIndex:framesString.length-1];
        }
        framesString = [framesString stringByAppendingString:@"]"];
    }
    
    NSString *totalString = @"{";
    if (infoJson) {
        totalString = [totalString stringByAppendingString:[NSString stringWithFormat:@"\"info\":%@", infoJson]];
    }
    if (srcString) {
        totalString = [totalString stringByAppendingString:[NSString stringWithFormat:@",\"src\":%@", srcString]];
    }
    if (framesString) {
        totalString = [totalString stringByAppendingString:[NSString stringWithFormat:@",\"frame\":%@", framesString]];
    }
    totalString = [totalString stringByAppendingString:@"}"];
    return totalString;
}

@end

@implementation QGVAPCommonInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {version:%@, frames:%@, size:(%@,%@), videoSize:(%@,%@) orien:%@, fps:%@, merged:%@, alpha:(%@,%@,%@,%@), rgb:(%@,%@,%@,%@)}", self.class, self, @(_version), @(_framesCount), @(_size.width), @(_size.height), @(_videoSize.width), @(_videoSize.height), @(_targetOrientaion), @(_fps), @(_isMerged), @(_alphaAreaRect.origin.x), @(_alphaAreaRect.origin.y), @(_alphaAreaRect.size.width), @(_alphaAreaRect.size.height), @(_rgbAreaRect.origin.x), @(_rgbAreaRect.origin.y), @(_rgbAreaRect.size.width), @(_rgbAreaRect.size.height)];
}

- (NSString *)jsonString {
    return [NSString stringWithFormat:@"{\"v\":%@,\"f\":%@,\"w\":%@,\"h\":%@,\"videoW\":%@,\"videoH\":%@,\"orien\":%@,\"fps\":%@,\"isVapx\":%@,\"aFrame\":[%@,%@,%@,%@],\"rgbFrame\":[%@,%@,%@,%@]}", @(_version),@(_framesCount),@(_size.width),@(_size.height),@(_videoSize.width),@(_videoSize.height),@(_targetOrientaion),@(_fps),@(_isMerged),@(_alphaAreaRect.origin.x),@(_alphaAreaRect.origin.y),@(_alphaAreaRect.size.width),@(_alphaAreaRect.size.height),@(_rgbAreaRect.origin.x),@(_rgbAreaRect.origin.y),@(_rgbAreaRect.size.width),@(_rgbAreaRect.size.height)];
}

@end

@implementation QGVAPSourceInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {type:%@, tag:%@ color:%@, style:%@, size:(%@,%@), fitType:%@}", self.class, self, _type, _contentTag, _color, _style, @(_size.width), @(_size.height), _fitType];
}

- (NSString *)jsonString {
    return [NSString stringWithFormat:@"{\"srcId\":\"%@\",\"srcType\":\"%@\",\"loadType\":\"%@\", \"srcTag\":\"%@\",%@%@\"w\":%@,\"h\":%@,\"fitType\":\"%@\"}", _srcID, _type, _loadType, _contentTag, (_color.length > 0)?[NSString stringWithFormat:@"\"color\":\"%@\",",_color] : @"", _style.length>0 ? [NSString stringWithFormat:@"\"style\":\"%@\",",_style]:@"", @(_size.width), @(_size.height), _fitType];
}

@end

@implementation QGVAPMergedInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> {index:%@, rect:(%@,%@,%@,%@), mask:%@, maskRect:(%@,%@,%@,%@), maskRotation:%@, source:%@}", self.class, self, @(_renderIndex), @(_renderRect.origin.x), @(_renderRect.origin.y), @(_renderRect.size.width), @(_renderRect.size.height), @(_needMask), @(_maskRect.origin.x), @(_maskRect.origin.y), @(_maskRect.size.width), @(_maskRect.size.height), @(_maskRotation), _source];
}

- (NSString *)jsonString {
    return [NSString stringWithFormat:@"{\"srcId\":\"%@\",\"z\":%@,\"frame\":[%@,%@,%@,%@],\"mFrame\":[%@,%@,%@,%@],\"mt\":%@}", _source.srcID, @(_renderIndex), @(_renderRect.origin.x), @(_renderRect.origin.y), @(_renderRect.size.width), @(_renderRect.size.height),@(_maskRect.origin.x), @(_maskRect.origin.y), @(_maskRect.size.width), @(_maskRect.size.height), @(_maskRotation)];
}

@end
