### TCMediaXBase类

### getInstance

**说明**

获取 TCMediaXBase 的单例。

**接口**

```objective-c
+ (instancetype)getInstance;
```

**参数说明**

无

### setLicense

**说明**

设置 License

**接口**

```objective-c
- (void)setLicense:(NSString *)license
          callback:(nullable TCMediaXLicenseCallback)callback;
```

**参数说明**

| 参数名   | 类型                    | 描述           |
| -------- | ----------------------- | -------------- |
| license  | NSString                | License 字符串 |
| callback | TCMediaXLicenseCallback | 校验结果回调   |

回调声明：

```objective-c
typedef void(^TCMediaXLicenseCallback)(int errCode, NSString * _Nullable message);
```

License 校验错误码：

```objective-c
typedef NS_ENUM(NSInteger, TCMediaXLicenceCheckErrorCode) {
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
```

### setLogEnable

**说明**

是否开启 Log 输出，默认开始。

Android 端保存在 /sdcard/Android/data/packagename/files/TCMediaX 目录，iOS端保存在sandbox的Documents/TCMediaX目录，您可以根据业务需要把此目录的日志上传到业务后台，用于定位线上用户问题。

**接口**

```objective-c
- (void)setLogEnable:(BOOL)enabled;
```

### getSdkVersion

**说明**

获取当前 sdk 的版本。

**接口**

```objective-c
- (NSString *)getSdkVersion;
```

## 

## TCEffectAnimView类

### initWithFrame

**说明**

创建 TCEffectAnimView。

**接口**

```objective-c
- (instancetype)initWithFrame:(CGRect)frame;
```

**参数说明**

frame： View 对象的 frame。

### startPlay

**说明**

启动播放器。

**接口**

```objective-c
- (void)startPlay:(NSString *)url;
```

**参数说明**

url 为视频资源地址。

只支持播放 本地视频资源， 如果您使用的网络视频资源， 先下载到本地再播放。

### setVideoMode

**说明**

设置 mp4 动画的 alpha 和 rgb 区域的对齐方式。 

**接口**

```objective-c
- (void)setVideoMode:(TCEPVAPVideoFrameTextureBlendMode)mode;
```

**参数说明**

mode 支持以下格式：

| 枚举值                                | 含义                      |
| ------------------------------------- | ------------------------- |
| TCEPVAPVFTextureBlendMode_None        | 普通mp4文件               |
| TCEPVAPVFTextureBlendMode_AlphaLeft   | 左右对齐（alpha左\rgb右） |
| TCEPVAPVFTextureBlendMode_AlphaTop    | 上下对齐（alpha上\rgb下） |
| TCEPVAPVFTextureBlendMode_AlphaRight  | 左右对齐（rgb左\alpha右） |
| TCEPVAPVFTextureBlendMode_AlphaBottom | 上下对齐（rgb上\alpha下） |

### setEffectPlayerConfig

**说明**

设置特效播放器参数，需要在启动播放前调用。

**接口**

```objective-c
- (void)setEffectPlayerConfig:(TCEffectConfig *)config;
```

**参数说明**

参考TCEffectConfig 类。

### setRenderMode

**说明**

设置对齐方式

**接口**

```objective-c
- (void)setRenderMode:(TCEPVPViewContentMode)renderMode;
```

**参数说明**

renderMode 支持以下格式：

| 枚举值                           | 含义                                                     |
| -------------------------------- | -------------------------------------------------------- |
| TCEPVPViewContentModeScaleToFill | 内容被拉伸到填满整个视图，可能失真，默认值。             |
| TCEPVPViewContentModeAspectFit   | 内容保持原始宽高比，缩放以完全显示，可能有空白区域。     |
| TCEPVPViewContentModeAspectFill  | 内容保持原始宽高比，缩放以填满视图，可能会裁剪部分内容。 |

### effectPlayerDelegate

**说明**

TCEPAnimViewDelegate 支持设置动画特效播放器播放事件回调，设置融合动画信息等。

**播放回调接口**

```objective-c
// 动画开始播放回调
- (void)tcePlayerStart:(ITCEffectPlayer *)player;

// 动画结束播放回调
- (void)tcePlayerEnd:(ITCEffectPlayer *)player;

// 动画播放错误回调
- (void)tcePlayerError:(ITCEffectPlayer *)player error:(NSError *)error;

// 播放器事件通知
- (void)onPlayEvent:(ITCEffectPlayer *)player
              event:(int)EvtID
          withParam:(NSDictionary *)param;
```

**融合动画信息替换接口**

```objective-c
// 替换融合动画资源配置中的文本占位符， 支持配置文件的对齐方式、颜色等属性。
- (TCEffectText *)loadTextForPlayer:(ITCEffectPlayer *)player
                           withTag:(NSString *)tag;


// 替换融合动画资源中的图片信息
// 获取当前图片对应 tag： NSString *tag = context[TCEPContextSourceTypeImageIndex];  
- (void)loadImageForPlayer:(ITCEffectPlayer *)player
                   context:(NSDictionary *)context
                completion:(void(^)(UIImage *image,
                                    NSError *error))completionBlock;
```

**融合动画点击换接口**

```objective-c
// 融合动画的资源点击事件回调
- (void)tcePlayerTagTouchBegan:(ITCEffectPlayer *)player tag:(NSString *)tag;
```

### setRenderRotation

**说明**

设置动画旋转方向。

**接口**

```objective-c
- (void)setRenderRotation:(TCEP_Enum_Type_HomeOrientation)rotation;
```

**参数说明**

rotation 支持以下格式：

| 枚举值                               | 含义                                          |
| ------------------------------------ | --------------------------------------------- |
| TCEP_HOME_ORIENTATION_RIGHT          | HOME 键在右边，横屏模式。                     |
| TCEP_HOME_ORIENTATION_DOWN           | HOME 键在下面，手机直播中最常见的竖屏直播模式 |
| TCEP_HOME_ORIENTATION_LEFT           | HOME 键在左边，横屏模式。                     |
| TCEPVAPVFTextureBlendMode_AlphaRight | HOME 键在上边，竖屏直播。                     |

### isPlaying

**说明**

返回特效播放器是否在播放中

**接口**

```objective-c
- (BOOL)isPlaying;
```

### resume

**说明**

恢复特效动画播放

**接口**

```objective-c
- (void)resume;
```

### pause

**说明**

暂停特效动画播放

**接口**

```objective-c
- (void)pause;
```


### seekTo

**说明**

跳转到指定位置开始播放

注意：
1. startPlay() 之后才可以调用该方法，否则不生效
2. 该接口对于 tcmp4 动画、或者设置了 vapEngineType 为 TCEPCodecTypeVODPlayer 时播放的mp4动画生效

time：要跳转到指定时长处开始播放，单位毫秒


**接口**

```objective-c
- (void)seek:(float)time;
```

### seekProgress
**说明**

跳转到指定位置开始播放

注意：
1. startPlay() 之后才可以调用该方法，否则不生效
2. 该接口对于 mp4 动画、或者设置了 vapEngineType 为 TCEPCodecTypeVODPlayer 时播放的mp4动画生效
3. 入参 progress 取值范围为 [0.0-1.0]，超出范围的不生效

progress：跳转到动画时长的指定百分比处开始播放，单位百分比，取值范围为:[0.0-1.0]

**接口**

```objective-c
- (void)seekProgress:(float)progress;
```


### setLoop

**说明**

设置循环播放。

YES： 表示循环播放；

NO： 表示关闭循环播放；

**接口**

```objective-c
- (void)setLoop:(BOOL)loop;
```

### setLoopCount

**说明**

设置循环播放次数。

loopCount： 表示循环播放次数。当loopCount <=0 时，表示无限循环播放；当 loopCount=n(n>=1)时表示从开始播放到播放结束，共播放n次

注意：
1. loopCount 默认值是1，即当外部不主动调用该方法时，动画只播放一次就结束
2. setLoop 方法内部会调用当前方法，即当 isLoop = true 时，等价于调用 setLoopCount(-1)；，即当 isLoop = false 时，等价于调用 setLoopCount(1)；因此这两个方法是互相影响的，后调用的会覆盖之前的调用。

**接口**

```objective-c
- (void)setLoopCount:(int)loopCount;
```

### setDuration
**说明**

设置动画需要多长时间播放完成。设置之后，后续动画播放时自动调整动画播放速度，以保证动画在设置的规定时长时播放结束。

即：设置的时长超过动画原时长，则动画慢放；小于动画原时长，则快进播放。

注意：
1、目前仅对 tcmp4 格式的动画生效
2、当前方法和 setRate 设置倍速的方法是互斥的，后调用的会覆盖掉先调用的

durationInMilliSec： 要设置的时长，单位毫秒

**接口**

```objective-c
- (void)setDuration:(long)durationInMilliSec;
```


### stopPlay

**说明**

停止播放。

**接口**

```objective-c
- (void)stopPlay;
```

### setMute

**说明**

设置是否静音播放。

YES： 静音播放；

NO： 非静音播放；

**接口**

```objective-c
- (void)setMute:(BOOL)bEnable;
```

### getTCAnimInfo

**说明**

获取当前播放动画对应的信息，返回 TCEffectAnimInfo 实例，详见 TCEffectAnimInfo 

注意：该方法必须在 IAnimPlayListener#onPlayStart() 方法中，或者该方法执行之后调用才可以获取到当前动画的信息，否则返回null

**接口**

```objective-c
- (nullable TCEffectAnimInfo *)getAnimInfo;
```

## TCEffectConfig类

**注意：以下功能需要腾讯云视立方·礼物动画特效 企业版 SDK 和 企业 License 授权才支持， 可以[点击这里](https://cloud.tencent.com/document/product/616/116459)了解详情。**

**说明**

构造特效播放器配置，支持属性有：

1、vapEngineType(CodecType type) ：它有三个取值，分别是：

- TCEPCodecTypeAVPlayer，动画特效播放器默认播放引擎。
- TCEPCodecTypeVODPlayer ，腾讯云播放器SDK播放引擎。


```objective-c
// 设置播放配置，非必需的步骤
TCEffectConfig *config = [[TCEffectConfig alloc] init];
[self.alphaAnimView setEffectPlayerConfig:config];

```

注意：

1. 目前仅支持在播放器开始前调用 setEffectPlayerConfig 方法来设置播放配置，开始播放后不支持修改配置。
2. 目前支持的 2 种 vapEngineType 仅对 MP4 动画生效。
3. 如果设置 vapEngineType为 TCEPCodecTypeVODPlayer，则还需要单独引入腾讯云播放器SDK，以及申请、注册好其对应的 license。

2、freezeFrame 用于设置播放动画冻结帧，目前可选值：

- FRAME_NONE : 默认取值，关闭 freezeFrame 能力，播放器正常播放暂停消失。

- FRAME_FIRST: 播放完毕，重新开始播放到下一次首帧出现时暂停。

- FRAME_LAST : 当第一次播放完毕之后，画面停留在最后一帧。


## TCEffectAnimInfo
**说明**

存储当前播放的动画信息

**属性说明**

| 属性名   | 类型              | 描述           |
| -------- | ----------------| -------------- |
| type     | TCEPAnimResourceType | 当前动画类型，取值：TCEPAnimResourceTypeMP4 MP4类型的资源和 TCEPAnimResourceTypeTCMP4 TCMP4类型的资源。 |
| duration | long            | 动画时长，单位毫秒 |
| width    | int             | 动画宽度         |
| height   | int             | 动画高度         |
| encryptLevel  | TCEPEncryptLevelType | 当前动画的高级加密类型，取值如果是TCEffectAnimInfo#ENCRYPT_LEVEL_NONE表示没有高级加密，否则表示已是高级加密         |


## TCEffectText
**说明**

融合动画替换文本样式数据类

**属性说明**

| 属性名    | 类型     | 描述                                                         |
| --------- | -------- | ------------------------------------------------------------ |
| text      | NSString | 最终要替换显示的文本内容                                     |
| color     | UIColor  | 文字颜色，格式要求：ARGB，如 0xFFFFFFFF                      |
| fontStyle | NSString | 文字显示样式，可取值："bold"表示粗体，不传则默认大小         |
| alignment | int      | 文字对齐方式，可取值：TCEPTextAlignmentNone（默认值，即保持sdk默认对齐方式）、TCEPTextAlignmentLeft(居左) 、TCEPTextAlignmentCenter(居中)、 TCEPTextAlignmentRight(居右) |
| fontSize  | CGFloat  | 文字大小，单位是px；如果设置了文字大小(值大于0)，则内部自动缩放策略失效，强制以设置的文字大小为准，则可能出现文字过大显示不全的问题 |