// Copyright (c) 2024 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"
#import "TCEffectAnimView.h"
#import "TCEffectAnimInfo.h"

NS_ASSUME_NONNULL_BEGIN

TCEP_EXPORT @interface ITCEffectPlayer : NSObject

/**
 * 用于关联显示的特效播放器View
 *
 * Special effects player View for associated display
 */
@property (nonatomic, weak, nullable) TCEffectAnimView *vapRenderView;

#pragma mark - Public

/**
 * 播放Alpha视频（目前仅支持本地文件播放）
 * @param url 播放的视频文件地址，目前仅支持本地文件播放
 *
 * Play Alpha video (currently only supports local file playback)
 * -param url The video file address to be played. Currently, only local file playback is supported.
 */
- (void)startPlay:(NSString *)url;

/**
 * 停止播放音视频流
 * Stop playing audio and video streams
 */
- (void)stopPlay;

/**
 * 是否允许循环播放
 */
- (void)setLoop:(BOOL)loop;

/**
 * 设置循环播放的次数
 */
- (void)setLoopCount:(int)loopCount;

/**
 * 设置动画需要多长时间播放完成。设置之后，后续动画播放时自动调整动画播放速度，以保证动画在设置的规定时长时播放结束。
 * 即：设置的时长超过动画原时长，则动画慢放；小于动画原时长，则快进播放。
 * 注意：
 * 1、目前仅对 tcmp4 格式的动画生效
 * 2、当前方法和 setRate 设置倍速的方法是互斥的，后调用的会覆盖掉先调用的
 * @param durationInMilliSec   要设置的时长，单位毫秒
 *
 * Set how long it takes for the animation to complete. After setting, the animation playback speed will be automatically
 * adjusted when subsequent animations are played to ensure that the animation ends within the set specified duration.
 *
 * if the set duration exceeds the original duration of the animation, the animation will be played in slow motion; if the set
 * duration is less than the original duration of the animation, it will be played in fast forward.
 *
 * Note:
 * 1. Currently only works for animations in tcmp4 format
 * 2. The current method and the setRate method for setting the speed are mutually exclusive, and the later method will overwrite the earlier method

 * durationInMilliSec The duration to be set, in milliseconds
 */
- (void)setDuration:(long)durationInMilliSec;

/**
 * 移除播放器
 * Remove player
 */
- (void)removePlayer;

/**
 * 是否正在播放
 * is playing
 */
- (BOOL)isPlaying;

/**
 * 暂停播放
 * Pause playback
 */
- (void)pause;

/**
 * 继续播放
 * resume playing
 */
- (void)resume;

/**
 * 播放跳转到音视频流某个时间
 * @param time 起始播放的时间
 *
 * * Playback jumps to a certain time in the audio and video stream
 * -param time time to start playing
 */
- (void)seek:(float)time;

/**
 * 播放跳转到音视频流某个时间
 * @param progress  跳转的比例
 *
 * * Playback jumps to a certain time in the audio and video stream
 * -param progress  jump ratio
 */
- (void)seekProgress:(float)progress;

/**
 * 设置画面的方向
 * @param rotation 画面方向
 *
 * Set the screen orientation
 * -param rotation screen direction
 */
- (void)setRenderRotation:(TCEP_Enum_Type_HomeOrientation)rotation;

/**
 * 设置画面的裁剪模式
 * @param renderMode 填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值TCEPVPViewContentModeAspectFit
 *
 * Set the cropping mode of the screen
 * -param renderMode fill (the picture may be stretched and cropped) or adapt (the picture may have black edges), default value TCEPVPViewContentModeAspectFit
 */
- (void)setRenderMode:(TCEPVPViewContentMode)renderMode;

/**
 * 设置静音
 * @param bEnable 设置是否为静音
 *
 * Set mute
 * -param bEnable Set whether to mute
 */
- (void)setMute:(BOOL)bEnable;

/**
 * 设置播放速率
 * @param rate 播放速度（0.5-2.0）
 *
 * Set playback rate
 * -param rate playback speed (0.5-2.0)
 */
- (void)setRate:(float)rate;

/**
 * 设置 Alpha素材中每一帧Alpha通道数据的位置
 * @param mode Alpha通道数据的位置
 *
 * Set the position of the Alpha channel data of each frame in the Alpha material
 * -param mode Alpha channel data location
 */
- (void)setVideoMode:(TCEPVAPVideoFrameTextureBlendMode)mode;

/**
 * 设置显示的View
 * @param view 设置显示的View
 *
 * Set the displayed View
 * -param view sets the displayed View
 */
- (void)setDisplayView:(TCEffectAnimView *)view;

/**
 * 返回播放器对象的相关信息
 *
 * Returns information about the player object
 */
- (NSString *)description;

/**
 * 调用后将刷新一次融合动画信息
 * @param value 是否强制刷新一次融合动画信息
 *
 * After calling, the fusion animation information will be refreshed once
 * -param value  Whether to force refresh the fusion animation information
 */
- (void)requestUpdateResource:(BOOL)value;

/**
 * 是否将刷新一次融合动画信息
 * @return 将返回是否将刷新一次融合动画信息
 *
 * Whether to refresh the fusion animation information
 * -return Will return whether to refresh the fusion animation information once
 */
- (BOOL)canRequestUpdateResource;

 /**
 * 获取播放器配置
 */
- (TCEffectConfig *)getPlayerConfig;

/**
 * 预加载动画信息
 *
 * preload animation info
 */
+ (nullable TCEffectAnimInfo *)preloadTCAnimInfo:(NSString *)playUrl config:(TCEffectConfig *)config;

@end

NS_ASSUME_NONNULL_END
