// QGVAPConfigModel.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

typedef NS_ENUM(NSInteger, QGVAPOrientation){
    
    QGVAPOrientation_None                   = 0,          // 兼容
    QGVAPOrientation_Portrait               = 1,          // 竖屏
    QGVAPOrientation_landscape              = 2,          // 横屏
};

typedef NSString * QGAGAttachmentSourceType     NS_EXTENSIBLE_STRING_ENUM;//资源类型
typedef NSString * QGAGAttachmentSourceLoadType NS_EXTENSIBLE_STRING_ENUM;//资源加载类型
typedef NSString * QGAGAttachmentSourceStyle    NS_EXTENSIBLE_STRING_ENUM;//字体
typedef NSString * QGAGAttachmentFitType        NS_EXTENSIBLE_STRING_ENUM;//资源适配类型

//资源适配类型
UIKIT_EXTERN QGAGAttachmentFitType     const kQGAGAttachmentFitTypeFitXY;                //按指定尺寸缩放
UIKIT_EXTERN QGAGAttachmentFitType     const kQGAGAttachmentFitTypeCenterFull;           //默认按资源尺寸展示，如果资源尺寸小于遮罩，则等比缩放至可填满
//资源类型
UIKIT_EXTERN QGAGAttachmentSourceType  const kQGAGAttachmentSourceTypeTextStr;           //文字
UIKIT_EXTERN QGAGAttachmentSourceType  const kQGAGAttachmentSourceTypeImgUrl;            //图片

UIKIT_EXTERN QGAGAttachmentSourceType    const kQGAGAttachmentSourceTypeText;
UIKIT_EXTERN QGAGAttachmentSourceType    const kQGAGAttachmentSourceTypeImg;
UIKIT_EXTERN QGAGAttachmentSourceLoadType const QGAGAttachmentSourceLoadTypeLocal;
UIKIT_EXTERN QGAGAttachmentSourceLoadType const QGAGAttachmentSourceLoadTypeNet;

//字体
UIKIT_EXTERN QGAGAttachmentSourceStyle const kQGAGAttachmentSourceStyleBoldText;         //粗体

//https://docs.qq.com/sheet/DTGl0bXdidFVkS3pn?tab=7od8yj&c=C25A0I0
@class QGVAPCommonInfo,QGVAPSourceInfo,QGVAPMergedInfo;
@interface QGVAPConfigModel : NSObject

@property (nonatomic, strong) QGVAPCommonInfo *info;
@property (nonatomic, strong) NSArray<QGVAPSourceInfo *> *resources;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSArray<QGVAPMergedInfo*> *> *mergedConfig; ///@{帧，@[多个融合信息]}

@end

#pragma mark - 整体信息
@interface QGVAPCommonInfo : NSObject

@property (nonatomic, assign) NSInteger                 version;
@property (nonatomic, assign) NSInteger                 framesCount;
@property (nonatomic, assign) CGSize                    size;
@property (nonatomic, assign) CGSize                    videoSize;
@property (nonatomic, assign) QGVAPOrientation          targetOrientaion;
@property (nonatomic, assign) NSInteger                 fps;
@property (nonatomic, assign) BOOL                      isMerged;
@property (nonatomic, assign) CGRect                    alphaAreaRect;
@property (nonatomic, assign) CGRect                    rgbAreaRect;

@end

#pragma mark - 渲染资源信息
@interface QGVAPSourceInfo : NSObject

//原始信息
@property (nonatomic, strong) QGAGAttachmentSourceType  type;
@property (nonatomic, strong) QGAGAttachmentSourceLoadType  loadType;
@property (nonatomic, strong) NSString                  *contentTag;
@property (nonatomic, strong) NSString                  *contentTagValue;
@property (nonatomic, strong) UIColor                   *color;
@property (nonatomic, strong) QGAGAttachmentSourceStyle style;
@property (nonatomic, assign) CGSize                    size;
@property (nonatomic, strong) QGAGAttachmentFitType     fitType;

//加载内容
@property (nonatomic, strong) UIImage                   *sourceImage;
@property (nonatomic, strong) id<MTLTexture>            texture;
@property (nonatomic, strong) id<MTLBuffer>             colorParamsBuffer;

@end

@interface QGVAPSourceDisplayItem : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) QGVAPSourceInfo *sourceInfo;

@end

#pragma mark - 融合信息
@interface QGVAPMergedInfo : NSObject

@property (nonatomic, strong) QGVAPSourceInfo           *source;
@property (nonatomic, assign) NSInteger                 renderIndex;
@property (nonatomic, assign) CGRect                    renderRect;
@property (nonatomic, assign) BOOL                      needMask;
@property (nonatomic, assign) CGRect                    maskRect;
@property (nonatomic, assign) NSInteger                 maskRotation;

//加载内容
- (id<MTLBuffer>)vertexBufferWithContainerSize:(CGSize)size maskContianerSize:(CGSize)mSize device:(id<MTLDevice>)device;

@end
