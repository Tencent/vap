//  Copyright © 2023 Tencent. All rights reserved.
//

#ifndef TCEP_APPLE_BASIC_DEFINE_TCEPCONSTANT_H_
#define TCEP_APPLE_BASIC_DEFINE_TCEPCONSTANT_H_
#import <UIKit/UIKit.h>

// 宏定义部分
// 1. Context Source的类型
UIKIT_EXTERN NSString * const TCEPContextSourceTypeImageURL;  // 图片的URL地址
UIKIT_EXTERN NSString * const TCEPContextSourceTypeImageIndex;  // 图片的Index(TEPG)
UIKIT_EXTERN NSString * const TCEPContextSourceTypeTextIndex;  // 文字的Index(TEPG)

// 2. Symbol Export
#if defined(BUILD_TCEPSDK)
#define TCEP_EXPORT __attribute__((visibility("default")))
#else
#define TCEP_EXPORT
#endif

// 3.播放结束，保留帧设置
// 默认不冻结帧，播放器正常播放
TCEP_EXPORT extern NSInteger const FRAME_NONE;
// 播放完毕，重新开始播放到下一次首帧出现时暂停（暂未实现）
TCEP_EXPORT extern NSInteger const FRAME_FIRST;
// 播放完毕，本次播放尾帧出现时暂停（循环播放不受此影响）
TCEP_EXPORT extern NSInteger const FRAME_LAST;
// 3.0 版本开始支持， 配置额外拓展 License
TCEP_EXPORT extern NSString * const TCEPParamOptionalStringExtraLicenseKey;


/**
* 特效播放器资源类型
* The  resource type of  effects player
*/
typedef NS_ENUM(NSInteger, TCEPAnimResourceType) {
    
    TCEPAnimResourceTypeMP4   = 1, ///< MP4类型的资源
    TCEPAnimResourceTypeTCMP4 = 2, ///< TCMP4类型的资源
};

/**
* 特效播放器加密类型
* The  encryption type of  effects player
*/
typedef NS_ENUM(NSInteger, TCEPEncryptLevelType) {
    
    TCEPEncryptLevelTypeNone  = 0, ///< None
    TCEPEncryptLevelTypeL1    = 1, ///< L1
};

/**
 * 素材中每一帧Alpha通道数据的位置
 * The position of the Alpha channel data of each frame in the material
 */
typedef NS_ENUM(NSInteger, TCEPVAPVideoFrameTextureBlendMode) {

    /// 无Alpha
    /// 播放普通mp4文件
    TCEPVAPVFTextureBlendMode_None = 0,
    /// 左侧Alpha
    /// Left Alpha
    TCEPVAPVFTextureBlendMode_AlphaLeft = 1,

    /// 右侧Alpha
    /// Right Alpha
    TCEPVAPVFTextureBlendMode_AlphaRight = 2,

    /// 上侧Alpha
    /// Top Alpha
    TCEPVAPVFTextureBlendMode_AlphaTop = 3,

    /// 下侧alpha
    /// Bottom alpha
    TCEPVAPVFTextureBlendMode_AlphaBottom = 4,
};

/**
 * 特效播放器View的Content Mode
 * Content Mode of Effect player View
 */
typedef NS_ENUM(NSUInteger, TCEPVPViewContentMode) {

    /// ScaleToFill
    TCEPVPViewContentModeScaleToFill = 0,

    /// Aspect Fit
    TCEPVPViewContentModeAspectFit = 1,

    /// Aspect Fill
    TCEPVPViewContentModeAspectFill = 2,
};


/**
 * 特效播放器播放引擎类型，默认是AVPlayer
 * The engine type of special effects player
 */
typedef NS_ENUM(NSInteger, TCEPCodecType) {
    TCEPCodecTypeAVPlayer  = 0,
    TCEPCodecTypeVODPlayer = 1,
};

/**
 * 画面旋转方向
 * Screen rotation direction
 */
typedef NS_ENUM(NSInteger, TCEP_Enum_Type_HomeOrientation) {
    ///< HOME 键在右边，横屏模式。
    ///< The HOME button is on the right, in landscape mode.
    TCEP_HOME_ORIENTATION_RIGHT = 0,
    ///< HOME 键在下面，手机直播中最常见的竖屏直播模式。
    ///< The HOME button is below, the most common vertical screen live broadcast mode in mobile live broadcast.
    TCEP_HOME_ORIENTATION_DOWN = 1,
    ///< HOME 键在左边，横屏模式。
    ///< The HOME button is on the left, in landscape mode.
    TCEP_HOME_ORIENTATION_LEFT = 2,
    ///< HOME 键在上边，竖屏直播。
    ///< HOME button is at the top, vertical screen live broadcast.
    TCEP_HOME_ORIENTATION_UP = 3,
};

/**
 * 事件ID 列表
 * Event ID List
 */
typedef NS_ENUM(NSInteger, TCEPEventID) {
    
    // 事件ID
    TCEP_OK = 0, //成功
    
    // 通过获取‘onPlayEvent:event:withParam:’中的param中的数值，得到Animation的Config
    TCEP_EVT_TYPE_GET_ANIMATION_CONFIG = 200001, // 成功解析Animation的Config
    
    // 通用错误码
    TCEP_REPORT_ERROR_TYPE_EXTRACTOR_EXC = -10001, // MediaExtractor exception
    TCEP_REPORT_ERROR_TYPE_DECODE_EXC = -10002, // MediaCodec exception
    TCEP_REPORT_ERROR_TYPE_CREATE_THREAD = -10003, // 线程创建失败
    TCEP_REPORT_ERROR_TYPE_CREATE_RENDER = -10004, // render创建失败
    TCEP_REPORT_ERROR_TYPE_PARSE_CONFIG = -10005, // 配置解析失败
    TCEP_REPORT_ERROR_TYPE_FILE_ERROR = -10006, // 文件无法读取
    TCEP_REPORT_ERROR_TYPE_HEVC_NOT_SUPPORT = -10007, // 不支持h265
    TCEP_REPORT_ERROR_TYPE_INVALID_PARAM = -10008, // 参数非法
    TCEP_REPORT_ERROR_TYPE_INVALID_LICENSE = -10009, // License 不合法
    TCEP_REPORT_ERROR_TYPE_NOT_SUPPORT_SIMULATOR = -10010, // 模拟器不支持
    TCEP_REPORT_ERROR_TYPE_LACK_DEPENDENT = -10012, // 缺少必备的依赖(比如TX_LITEAV_SDK时没有)
    TCEP_REPORT_ERROR_TYPE_PAG_NOT_SUPPORTED = -10013, // vap_pro 版本不支持 PAG/TEPG 播放

    // 资源鉴权错误码
    TCEP_REPORT_ERROR_TYPE_INVALID_SIGNATURE = -100200, // 签名校验失败
    TCEP_REPORT_ERROR_TYPE_DECODE_ERROR = -100201, // 解密数据失败
    TCEP_REPORT_ERROR_TYPE_INVALID_PACKAGE_NAME = -100202, // BundleID 或者 PackageName不一致
    TCEP_REPORT_ERROR_TYPE_TIME_EXPIRED = -100203, // 资源过期
    TCEP_REPORT_ERROR_TYPE_JSON_FORMAT_ERROR = -100204, // JSON字段不正确
    TCEP_REPORT_ERROR_TYPE_INVALID_BOX_TYPE = -100205, // boxType 类型不支持
    TCEP_REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX = -100206, // vapx融合动画资源获取失败
    
    TCEP_PLAYER_EVT_PROGRESS = 2005,  // 视频播放进度

    /// 帧渲染完成事件
    /// param: TCEPEventFrameIndexKey = 当前帧索引（从0开始）
    TCEP_PLAYER_EVT_VIDEO_RENDER_PROGRESS = 200005,

};

// 播放进度，单位：毫秒
TCEP_EXPORT extern NSString * const TCEPEventProgressMSKey;
// 播放总长，单位：毫秒
TCEP_EXPORT extern NSString * const TCEPEventDurationMSKey;

// 帧渲染回调参数 Key
/// 当前帧索引（NSNumber, NSInteger）
TCEP_EXPORT extern NSString * const TCEPEventFrameIndexKey;
#endif  // TCEP_APPLE_BASIC_DEFINE_TCEPCONSTANT_H_
