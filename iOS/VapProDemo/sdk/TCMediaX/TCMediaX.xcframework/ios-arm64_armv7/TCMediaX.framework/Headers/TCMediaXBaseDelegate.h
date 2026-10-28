//  Copyright © 2023年 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TCMediaXBaseDelegate <NSObject>

@optional

/**
 * License检查CallBack函数
 * @param errcode  错误码
 * @param param  字典信息
 */
- (void)onLicenseCheckCallback:(int)errcode withParam:(NSDictionary *)param;

/**
 *  插件部分事件回调
 * @param pluginName   插件的名称，每个插件有其独特的名字
 * @param eventType   事件类型 详见‘TXVoiceChangerDefine.h’中 TX_VOICE_CHANGE_EVENT_CODE部分
 * @Param param  具体参数的含义
 */
- (void)onPluginEvent:(NSString *)pluginName event:(int)eventType withParam:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
