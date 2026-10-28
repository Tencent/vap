// Copyright (c) 2025 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TELicenseCheckErrorCode) {
    TELicenseCheckOk = 0,                   // 成功
    TELicenseCheckInvalidInput = -1,        // 输入参数无效
    TELicenseCheckDownloadError = -3,       // 下载环节失败，请检查网络设置
    TELicenseCheckLocalLicenseEmpty = -4,   // 从本地读取的TE授权信息为空
    TELicenseCheckFileContentEmpty = -5,    // 读取VCUBE TEMP License文件内容为空
    TELicenseCheckJsonErrorVcube = -6,      // v_cube.license文件json字段错误
    TELicenseCheckSignatureError = -7,      // 签名校验失败
    TELicenseCheckDecodeError = -8,         // 解密失败
    TELicenseCheckTEJsonError = -9,         // TELicense字段里的json字段错误
    TELicenseCheckTEContentEmpty = -10,     // 从网络解析的TE授权信息为空
    TELicenseCheckWriteLocalFailed = -11,   // 把TE授权信息写到本地文件时失败
    TELicenseCheckDownloadAndAssetBothFailed = -12, // 下载失败，解析本地asset也失败
    TELicenseCheckAuthError = -13,          // 鉴权失败
};


typedef void(^callback)(NSInteger authresult, NSString *errorMsg);

@interface TELicenseCheck : NSObject


/// 加载license信息并鉴权，如果completion为nil，则仅触发下载更新缓存
/// @param url 在腾讯云控制台申请到的 LicenseURL
/// @param key 在腾讯云控制台申请到的 LicenseKEY
/// @param completion 鉴权结果回调
+ (void)setTELicense:(NSString *)url key:(NSString *)key completion:(callback)completion;


@end

NS_ASSUME_NONNULL_END
