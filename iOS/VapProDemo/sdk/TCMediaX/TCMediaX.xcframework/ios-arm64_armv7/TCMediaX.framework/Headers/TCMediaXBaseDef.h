//  Copyright © 2023年 Tencent. All rights reserved.

#ifndef TCMediaXManagerDef_h
#define TCMediaXManagerDef_h
#import <Foundation/Foundation.h>

/**
 *  MediaX Licence检查错误码
 *
 */
typedef NS_ENUM(NSInteger, TCMediaXLicenceCheckErrorCode) {
    // ----- 公共 -----
    TMXLicenseCheckOk                       = 0,    // 成功

    // ----- V1 -----
    TMXLicenseCheckInvalidInput             = -1,   // 输入参数无效
    TMXLicenseCheckDownloadError            = -3,   // 下载环节失败，请检查网络设置
    TMXLicenseCheckLocalLicenseEmpty        = -4,   // 从本地读取的TE授权信息为空
    TMXLicenseCheckFileContentEmpty         = -5,   // 读取VCUBE TEMP License文件内容为空
    TMXLicenseCheckJsonErrorVcube           = -6,   // v_cube.license文件json字段错误
    TMXLicenseCheckSignatureError           = -7,   // 签名校验失败
    TMXLicenseCheckDecodeError              = -8,   // 解密失败
    TMXLicenseCheckTEJsonError              = -9,   // TELicense字段里的json字段错误
    TMXLicenseCheckTEContentEmpty           = -10,  // 从网络解析的TE授权信息为空
    TMXLicenseCheckWriteLocalFailed         = -11,  // 把TE授权信息写到本地文件时失败
    TMXLicenseCheckDownloadAndAssetBothFailed = -12,// 下载失败，解析本地asset也失败
    TMXLicenseCheckAuthError                = -13,  // 鉴权失败

    // ----- V2 -----
    TMXLicenseV2Ok                          = 0,    // 成功
    TMXLicenseV2NotSet                      = -1,   // 还没有调用过 setLicense
    TMXLicenseV2JsonError                   = -2,   // envelope 或明文 JSON 解析失败
    TMXLicenseV2DownloadError               = -3,   // 保留枚举值
    TMXLicenseV2ContentEmpty                = -4,   // 入参空
    TMXLicenseV2PackageNotMatch             = -5,   // packageName / bundleId 不匹配
    TMXLicenseV2Expired                     = -6,   // 保留枚举值
    TMXLicenseV2SignatureError              = -7,   // RSA 验签失败
    TMXLicenseV2FeatureNotSupported         = -8,   // feature 不在授权列表
    TMXLicenseV2DecodeError                 = -9,   // AES 解密失败
    TMXLicenseV2Base64Error                 = -10,  // 外层/内层 base64 解码失败
};

#endif /* TCMediaXManagerDef_h */
