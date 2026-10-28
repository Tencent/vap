//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TCEPConstant.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 动画方向类型定义
 * Animation direction type definition
 */
typedef NS_ENUM(NSInteger, TCEPVAPOrientation) {

    /// 兼容 compatible
    TCEPVAPOrientation_None = 0,

    /// 竖屏 Vertical screen
    TCEPVAPOrientation_Portrait = 1,

    /// 横屏 Horizontal screen
    TCEPVAPOrientation_landscape = 2,
};

TCEP_EXPORT @interface TCEPAnimConfig : NSObject

/**
 * 配置信息版本（不同版本号不兼容）
 * Configuration information version (different version numbers are not compatible)
 */
@property(nonatomic, assign) NSInteger version;

/**
 * 总帧数
 * total frames
 */
@property(nonatomic, assign) NSInteger framesCount;

/**
 * 需要显示视频的真实宽高
 * Need to display the true width and height of the video
 */
@property(nonatomic, assign) CGSize size;

/**
 * 视频实际宽高
 * Actual video width and height
 */
@property(nonatomic, assign) CGSize videoSize;

/**
 * 显示方向
 * Show direction
 */
@property(nonatomic, assign) TCEPVAPOrientation targetOrientaion;

/**
 * 帧率
 * Frame rate
 */
@property(nonatomic, assign) NSInteger fps;

/**
 * Alpha区域
 * Alpha area
 */
@property(nonatomic, assign) CGRect alphaAreaRect;

/**
 * RGB区域
 * RGB area
 */
@property(nonatomic, assign) CGRect rgbAreaRect;


@end

NS_ASSUME_NONNULL_END
