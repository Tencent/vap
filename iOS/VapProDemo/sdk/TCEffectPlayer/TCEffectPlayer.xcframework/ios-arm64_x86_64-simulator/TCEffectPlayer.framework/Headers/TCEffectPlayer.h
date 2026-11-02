//  Copyright © 2023年 Tencent. All rights reserved.

#import "TCEffectPlayerSDK.h"

NS_ASSUME_NONNULL_BEGIN

TCEP_EXPORT @interface TCEffectPlayer : NSObject

/**
 * 播放小游戏资源（目前仅支持本地文件播放）
 * @param effectParam  播放的小游戏资源，目前仅需配置TCEffectParam#resourcePath
 * @return 返回开启的结果回调
 *
 * Play mini-game resources (currently only supports local file playback)
 * -param  effectParam  the resources of the mini-game to be played. Currently, only TCEffectParam#resourcePath needs to be configured.
 * -return  Returns the result callback of the start
 */
- (BOOL)startGame:(TCEffectParam *)effectParam;

/**
 * 设置小游戏事件监听
 * @param delegate  监听回调
 * @return 返回设置的结果回调
 *
 * Set up light game event delegate
 * -param  delegate  callback delegate
 * -return  Returns the set result callback
 */
- (BOOL)setLightGameListener:(nullable id<TCEPLightGameDelegate>)delegate;

/**
 * 停止播放游戏
 * @return 返回操作的结果
 *
 * Stop playing game
 * -return  Return the result of the operation
 */
- (BOOL)stopGame;

@end

NS_ASSUME_NONNULL_END
