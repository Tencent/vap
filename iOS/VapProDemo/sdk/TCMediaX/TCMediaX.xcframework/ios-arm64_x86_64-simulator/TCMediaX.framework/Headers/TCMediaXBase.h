//  Copyright © 2023年 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCMediaXBaseDelegate;

/**
 License 校验结果回调（block 版本）。
 errCode == 0 表示成功；非 0 时参见 TCMediaXBaseDef.h 中 TCMediaXLicenceCheckErrorCode 的 V2 段。
 */
typedef void(^TCMediaXLicenseCallback)(int errCode, NSString * _Nullable message);

@interface TCMediaXBase : NSObject

/**
 @brief 创建TCMediaXBase对象
 @discussion 创建TCMediaXBase对象
 @return 返回创建的TCMediaXBase对象
*/
+ (instancetype)getInstance;

/**
 @brief 设置Delegate
 @param  delegate  设置的Delegate
*/
- (void)setDelegate:(id<TCMediaXBaseDelegate>)delegate;

/**
 @brief 设置本地 License
 @param license   base64 编码后的 License envelope 字符串
 @param callback  校验结果回调（errCode == 0 表示成功）；可为 nil；
                  即使 callback 为 nil，已通过 {@link setDelegate:} 挂载的 delegate 的
                  {@code onLicenseCheckCallback:withParam:} 仍会被触发。
*/
- (void)setLicense:(NSString *)license
          callback:(nullable TCMediaXLicenseCallback)callback;

/**
 @brief 设置Licence
 @param url  设置Licence的URL地址
 @param key  设置Licence的对应的Key
*/
- (void)setLicenceURL:(NSString *)url key:(NSString *)key;

/**
 @brief 设置Log是否允许
 @param enabled   YES 允许  NO 不允许。默认为YES
*/
- (void)setLogEnable:(BOOL)enabled;

/**
 @brief Get the SDK version info.
 */
- (NSString *)getSdkVersion;

@end

NS_ASSUME_NONNULL_END
