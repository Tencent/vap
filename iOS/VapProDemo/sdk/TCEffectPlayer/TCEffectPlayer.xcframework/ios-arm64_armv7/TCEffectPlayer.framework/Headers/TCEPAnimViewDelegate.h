//
// Copyright (c) 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TCEPAnimConfig;
@class ITCEffectPlayer;
@class TCEffectText;
@class TCEffectAudioFrameData;

@protocol TCEPAnimViewDelegate <NSObject>

@optional

/**
 * 播放器事件通知
 * @param player    播放器对象
 * @param EvtID     Event ID
 * @param param      附加参数
 *
 * * Player event notification
 * -param player        effect player
 * -param EvtID    Event ID
 * -param param     additional parameters
 */
- (void)onPlayEvent:(ITCEffectPlayer *)player
              event:(int)EvtID
          withParam:(NSDictionary *)param;

/**
 * 替换融合动画资源配置中的文本占位符，如果要支持配置文件的对齐方式、颜色等属性，请使用 loadTextForPlayer。
 * @param player     特效播放器对象
 * @param tag   标签
 *
 * Note: This interface has been deprecated. Please use loadTextForPlayer interface.
 * Replace resource placeholders in Fusion Animation resource configuration
 * -param player    effect player
 * -param tag   tag
 */
- (NSString *)textContentForPlayer:(ITCEffectPlayer *)player
                           withTag:(NSString *)tag DEPRECATED_MSG_ATTRIBUTE("Use loadTextForPlayer:withTag: instead.");


/**
 * 替换融合动画资源配置中的文本占位符， 支持配置文件的对齐方式、颜色等属性。
 * @param player     特效播放器对象
 * @param tag   标签
 *
 * Replace the text placeholder in the Fusion Animation resource configuration, and support the configuration file's alignment, color and other properties.
 * -param player    effect player
 * -param tag   tag
 */
- (TCEffectText *)loadTextForPlayer:(ITCEffectPlayer *)player
                           withTag:(NSString *)tag;


/**
 * 传入融合动画资源中的图片信息
 * @param player    特效播放器对象
 * @param context   resource资源信息 (如:  .mp4文件 ) 或 透传的index信息 (如:  .tepg文件 )，
 *                具体参数见 TCEPConstant.h
 * @param completionBlock    回调
 *
 * * Pass in the image information in the fusion animation resource
 * -param player    effect player
 * -param context   resource information ( for .mp4 file ) or index information (for .tepg file)
 * -param completionBlock   callback
 */
- (void)loadImageForPlayer:(ITCEffectPlayer *)player
                   context:(NSDictionary *)context
                completion:(void(^)(UIImage *image,
                                    NSError *error))completionBlock;

/**
 * 融合动画资源点击事件回调，非融合动画不回调
 * @param player    特效播放器对象
 * @param tag   标签
 *
 * Fusion animation resource click event callback,  non-fusion animation does not call back
 * -param player    effect player
 * -param tag   resource tag
 */
- (void)tcePlayerTagTouchBegan:(ITCEffectPlayer *)player tag:(NSString *)tag;

/**
 * 融合动画开始播放回调
 * @param player    特效播放器对象
 *
 * Effect player start to play callback
 * -param player    effect player
 */
- (void)tcePlayerStart:(ITCEffectPlayer *)player;

/**
 * 融合动画结束播放回调
 * @param player    特效播放器对象
 *
 * Effect player end to play callback
 * -param player   effect player
 */
- (void)tcePlayerEnd:(ITCEffectPlayer *)player;

/**
 * 融合动画播放错误回调
 * @param player    特效播放器对象
 * @param errorInfo  错误信息
 *
 * Effect player play error callback
 * -param player   effect player
 * -param errorInfo  error info
 */
- (void)tcePlayerError:(ITCEffectPlayer *)player 
             errorInfo:(NSDictionary *)errorInfo DEPRECATED_MSG_ATTRIBUTE("Use tcePlayerError:error: instead.");

/**
 * 融合动画播放错误回调
 * @param player    特效播放器对象
 * @param error  错误对象信息
 *
 * Effect player play error callback
 * -param player   effect player
 * -param error  error info
 */
- (void)tcePlayerError:(ITCEffectPlayer *)player error:(NSError *)error;

/**
 * 动画播放音频回调
 * @param audioFrameData  音频帧
 *
 * Animation audio frame callback
 * -param audioFrameData   audio frame
 */
- (void)tcePlayerAudioFrame:(TCEffectAudioFrameData *)audioFrameData;
@end
