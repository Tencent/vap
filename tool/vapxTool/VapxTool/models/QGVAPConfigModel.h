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
#import <AppKit/AppKit.h>

typedef NSString * VapAttachmentVariable       NS_EXTENSIBLE_STRING_ENUM;//预定义变量
typedef NSString * VapAttachmentFitType        NS_EXTENSIBLE_STRING_ENUM;//资源适配类型
typedef NSString * VapAttachmentSourceType     NS_EXTENSIBLE_STRING_ENUM;//资源类型
typedef NSString * VapAttachmentLoadType       NS_EXTENSIBLE_STRING_ENUM;//资源加载类型
typedef NSString * VapAttachmentSourceStyle    NS_EXTENSIBLE_STRING_ENUM;//字体
typedef NSString * VapAttachmentMaskType       NS_EXTENSIBLE_STRING_ENUM;//遮罩融合类型

//资源适配类型
APPKIT_EXTERN VapAttachmentFitType     const kVapAttachmentFitTypeFitXY;                //按指定尺寸缩放
APPKIT_EXTERN VapAttachmentFitType     const kVapAttachmentFitTypeCenterFull;           //默认按资源尺寸展示，如果资源尺寸小于遮罩，则等比缩放至可填满
//资源类型
APPKIT_EXTERN VapAttachmentSourceType  const kVapAttachmentSourceTypeTextStr;           //文字
APPKIT_EXTERN VapAttachmentSourceType  const kVapAttachmentSourceTypeImgUrl;            //图片
//资源加载类型
APPKIT_EXTERN VapAttachmentLoadType    const kVapAttachmentLoadTypeLocal;
APPKIT_EXTERN VapAttachmentLoadType    const kVapAttachmentLoadTypeNet;
//字体
APPKIT_EXTERN VapAttachmentSourceStyle const kVapAttachmentSourceStyleBoldText;         //粗体
//遮罩融合类型
APPKIT_EXTERN VapAttachmentMaskType    const kVapAttachmentMaskTypeSrcOut;              //表示去除遮挡区域
APPKIT_EXTERN VapAttachmentMaskType    const kVapAttachmentMaskTypeSrcIn;               //表示根据遮罩形状裁剪
APPKIT_EXTERN VapAttachmentMaskType    const kVapAttachmentMaskTypeSrcMix;

APPKIT_EXTERN NSInteger const kVapLayoutMaxWidth;

typedef NS_ENUM(NSInteger, VapxAlphaPostion){
    
    VapxAlphaPostion_leftTop,
    VapxAlphaPostion_leftCenter,
    VapxAlphaPostion_leftBottom,
    VapxAlphaPostion_bottomLeft,
    VapxAlphaPostion_bottomCenter,
    VapxAlphaPostion_bottomRight,
    VapxAlphaPostion_rightBottom,
    VapxAlphaPostion_rightCenter,
    VapxAlphaPostion_rightTop,
    VapxAlphaPostion_topRight,
    VapxAlphaPostion_topCenter,
    VapxAlphaPostion_topLeft
};

typedef NS_ENUM(NSInteger, QGVAPOrientation){
    
    QGVAPOrientation_None                   = 0,          // 兼容
    QGVAPOrientation_Portrait               = 1,          // 竖屏
    QGVAPOrientation_landscape              = 2,          // 横屏
};

//https://docs.qq.com/sheet/DTGl0bXdidFVkS3pn?tab=7od8yj&c=C25A0I0
@class QGVAPCommonInfo,QGVAPSourceInfo,QGVAPMergedInfo;
@interface QGVAPConfigModel : NSObject

@property (nonatomic, strong) QGVAPCommonInfo *info;
@property (nonatomic, strong) NSArray<QGVAPSourceInfo *> *resources;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSArray<QGVAPMergedInfo*> *> *mergedConfig; ///@{帧，@[多个融合信息]}

- (NSString *)jsonString;

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

@property (nonatomic, assign) VapxAlphaPostion          alphaPostion;
@property (nonatomic, strong) NSArray                   *alphaPaths;
@property (nonatomic, strong) NSArray                   *rgbPaths;

- (NSString *)jsonString;

@end

#pragma mark - 渲染资源信息
@interface QGVAPSourceInfo : NSObject

//原始信息
@property (nonatomic, strong) NSString                  *srcID;
@property (nonatomic, strong) VapAttachmentSourceType   type;
@property (nonatomic, strong) VapAttachmentLoadType     loadType;
@property (nonatomic, strong) NSString                  *contentTag;
@property (nonatomic, strong) NSString                  *color;
@property (nonatomic, strong) VapAttachmentSourceStyle style;
@property (nonatomic, assign) CGSize                    size;
@property (nonatomic, strong) VapAttachmentFitType     fitType;

- (NSString *)jsonString;

@end

#pragma mark - 融合信息
@interface QGVAPMergedInfo : NSObject

@property (nonatomic, strong) QGVAPSourceInfo           *source;
@property (nonatomic, assign) NSInteger                 renderIndex;
@property (nonatomic, assign) CGRect                    renderRect;
@property (nonatomic, assign) BOOL                      needMask;
@property (nonatomic, assign) CGRect                    maskRect;
@property (nonatomic, assign) NSInteger                 maskRotation;

//
@property (nonatomic, strong) NSString                  *tempPathForMask;

- (NSString *)jsonString;

@end
