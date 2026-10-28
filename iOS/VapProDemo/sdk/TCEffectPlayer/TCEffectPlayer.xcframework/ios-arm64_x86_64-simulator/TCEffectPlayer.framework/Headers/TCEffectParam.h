// Copyright (c) 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"

// 3D动画播放模式
typedef NS_ENUM(NSInteger, TCEffectPlayMode) {
    TCEffectPlayModeNone = -1, // 无指定时机，按顺序执行
    TCEffectPlayModeStartWhenAnimViewPlayEnd = 0, // 动效结束后播放
    TCEffectPlayModeStartBeforeAnimViewPlayEnd = 1, // 动效结束前播放
    TCEffectPlayModeStartWhenAnimViewPlay = 2, // 动效开始时播放
};

TCEP_EXPORT @interface TCEffectParam : NSObject

/**
 * 动效参数，默认对应美颜'motion' 动效
 * Animation parameters,  default corresponds to beauty 'motion' effect
 */
@property (nonatomic, copy) NSString *effectName;

/**
 *  动效参数值
 * Animation parameter value
 */
@property (nonatomic, assign) int effectValue;

/**
 * 资源路径
 * Resource path
 */
@property (nonatomic, copy) NSString *resourcePath;

/**
 * 附加参数
 * Additional parameters
 */
@property(nonatomic,strong) NSDictionary *extraInfoDic;

/**
 * 3D动画播放模式，默认是TCEffectPlayModeStartWhenAnimViewPlayEnd
 * 3D animation playback mode, default is 'TCEffectPlayModeStartWhenAnimViewPlayEnd'
 */
@property (nonatomic, assign) TCEffectPlayMode playMode;

/**
 * 动画播放时长（毫秒），默认2000毫秒
 * Animation playback duration (milliseconds), default is 2000 milliseconds
 */
@property (nonatomic, assign) int playbackDurationInMs;

/**
 * 动画提前播放时间（毫秒）, 默认1000毫秒
 * Advanced playback time before playend (milliseconds), default is 1000 milliseconds
 */
@property (nonatomic, assign) int advancedPlaybackTimeBeforePlayEnd;

@end
