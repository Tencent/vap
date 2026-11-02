// Copyright (c) 2021 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"

NS_ASSUME_NONNULL_BEGIN

TCEP_EXPORT @interface TCEffectConfig : NSObject

/**
 * VAP 特效播放器播放引擎类型
 * vapEngineType   特效播放器播放引擎Type类型，默认为AVPlayer
 *
 * The playback engine type of vap effects player
 * -param  vapEngineType   playback engine type, default value is AVPlayer
 */
@property (nonatomic, assign) TCEPCodecType vapEngineType;

/**
 * 是否保留最后一帧，详见 TCEPConstant.h 中`播放结束，保留帧设置`
 * freezeFrame  设置保留帧的位置，默认为FRAME_NONE
 *
 * Whether to keep the last frame, see Playback ends, keep frame settings  in TCEPConstant.h for details
 * -param  freezeFrame  Set the position of the reserved frame, the default is FRAME_NONE
 */
@property (nonatomic, assign) NSInteger freezeFrame;

/**
 * 拓展配置参数
 *
 * Extended configuration parameters.
 */
@property(nonatomic, strong, nullable) NSDictionary *extendMapParams;

/**
 * 播放进度回调开关，默认关闭
 * Playback progress callback switch, closed by default
 */
@property (nonatomic, assign) BOOL enableProgressCallback;

/**
 * 帧渲染回调开关，默认关闭
 * Frame render callback switch, closed by default
 */
@property (nonatomic, assign) BOOL enableFrameRenderCallback;


/**
 * 播放进度回调时间间隔，单位：毫秒，默认 200 毫秒
 * Play progress callback interval, unit: milliseconds, default 200 milliseconds
 */
@property (nonatomic, assign) NSInteger progressCallbackIntervalMs;

/**
 * 音频帧回调开关，默认关闭
 * Audio frame callback switch, closed by default
 */
@property (nonatomic, assign) BOOL enableAudioFrameCallback;

@end

NS_ASSUME_NONNULL_END
