// Copyright (c) 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TCEPConstant.h"

NS_ASSUME_NONNULL_BEGIN

///代理 delegate
@protocol TCEPAuthDelegate <NSObject>
/**
 * License检查CallBack函数
 * @param errcode  错误码
 * @param param  字典信息
 *
 * License check CallBack function
 * -param errcode error code
 * -param param dictionary information
 */
- (void)onLicenseCheckCallback:(int)errcode withParam:(NSDictionary *)param;

@end

///权限 Auth
TCEP_EXPORT @interface TCEPAuth : NSObject

/**
 * delegate 回调
 * delegate callback
 */
@property (nonatomic, weak, nullable)id<TCEPAuthDelegate> delegate;///代理

/**
 * 单例
 * Singleton
 */
+ (instancetype)shareInstance;

/**
 * 设置licence
 * @param licenseUrl url
 * @param licenseKey key
 *
 * Set license
 * -param licenseUrl url
 * -param licenseKey key
 */
+ (void)setLicense:(NSString *)licenseUrl licenseKey:(NSString *)licenseKey;

/**
 *  特效播放权限判断（完整版）
 *  @return BOOL值
 *
 *  Special effects playback permission judgment (full edition)
 *  -return BOOL value
 */
+ (BOOL)checkTceffectAuth;

/**
 *  特效播放 Lite 权限判断（vap_pro 版本）
 *  @return BOOL值
 *
 *  Special effects playback lite permission judgment (vap_pro edition)
 *  -return BOOL value
 */
+ (BOOL)checkTceffectAuthLite;


/**
 @brief 设置Log是否允许
 @param enabled   YES 允许  NO 不允许。默认为YES
*/
- (void)setLogEnable:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
