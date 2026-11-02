### TCMediaXBase类

### getInstance

**说明**

获取 TCMediaXBase 的单例。

**接口**

```dart
public static TCMediaXBase getInstance()
```

**参数说明**

无

### setLicense

**说明**

设置 License

**接口**

```dart
public void setLicense(Context context, String license, ILicenseCallback callback)
```

**参数说明**

| 参数名   | 类型             | 描述            |
| -------- | ---------------- | --------------- |
| context  | Context          | 应用的 Context  |
| license  | String           | License  字符串 |
| callback | ILicenseCallback | 校验结果回调    |

回调声明：

```java
public interface ILicenseCallback {
    void onResult(final int errCode, final String msg);
}
```

License 校验错误码：

```java
public interface TCLicenceErrorCode {
    int LicenseV2Ok = 0;                                  // 成功
    int LicenseV2NotSet = -1;                             // 还没有调用过 setLicense
    int LicenseV2JsonError = -2;                          //  JSON 解析失败
    int LicenseV2DownloadError = -3;                      // 下载失败
    int LicenseV2ContentEmpty = -4;                       // 入参空
    int LicenseV2PackageNotMatch = -5;                    // packageName / bundleId 不匹配
    int LicenseV2Expired = -6;                            // License 过期
    int LicenseV2SignatureError = -7;                     // RSA 验签失败
    int LicenseV2FeatureNotSupported = -8;                // feature 不在授权列表
    int LicenseV2DecodeError = -9;                        // AES 解密失败
    int LicenseV2Base64Error = -10;                       // 外层/内层 base64 解码失败
}
```

### setLogEnable

**说明**

是否开启 Log 输出，默认开始。

Android 端保存在 /sdcard/Android/data/packagename/files/TCMediaX 目录，iOS端保存在sandbox的Documents/TCMediaX目录，您可以根据业务需要把此目录的日志上传到业务后台，用于定位线上用户问题。

**接口**

```dart
public void setLogEnable(Context context, boolean enable)
```

## TCEffectAnimView类

### startPlay

**说明**

启动播放器。

**接口**

```java
public int startPlay(String playUrl)
```

**参数说明**

playUrl 为视频资源地址。

只支持播放 sdcard 本地视频资源， 如果您使用的网络视频资源， 先下载到本地再播放。

### setVideoMode

**说明**

设置 tep 动画的 alpha 和 rgb 区域的对齐方式。 

**接口**

```java
public void setVideoMode(TCEffectPlayerConstant.VideoMode mode)
```

**参数说明**

mode 支持以下格式：

| 枚举值                                                       | 含义                      |
| ------------------------------------------------------------ | ------------------------- |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_NONE             | 普通mp4文件               |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_HORIZONTAL | 左右对齐（alpha左\rgb右） |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_VERTICAL   | 上下对齐（alpha上\rgb下） |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE | 左右对齐（rgb左\alpha右） |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_VERTICAL_REVERSE | 上下对齐（rgb上\alpha下） |

### setConfig

**说明**

设置特效播放器参数，需要在启动播放前调用。

**接口**

```java
public void setConfig(TCEffectConfig config)
```

**参数说明**

参考TCEffectConfig 类。

### setScaleType

**说明**

设置对齐方式

**接口**

```java
public void setScaleType(TCEffectPlayerConstant.ScaleType type)
```

**参数说明**

type 支持以下格式：

| 枚举值                                       | 含义                                     |
| -------------------------------------------- | ---------------------------------------- |
| TCEffectPlayerConstant.ScaleType.FIT_XY      | 完整填充整个布局，默认值                 |
| TCEffectPlayerConstant.ScaleType.FIT_CENTER  | 按视频比例在布局中间完整显示             |
| TCEffectPlayerConstant.ScaleType.CENTER_CROP | 按视频比例完整填充布局（多余部分不显示） |

### setFetchResource

**说明**

设置融合动画的资源

**接口**

```java
public void setFetchResource(IFetchResource fetchResource)
```

**参数说明**

IFetchResource 接口：

```java
public interface IFetchResource {
    // 获取图片
    void fetchImage(Resource resource, IFetchResourceImgResult result);

    // 获取文字
    void fetchText(Resource resource, IFetchResourceTxtResult result);

    // 资源释放通知
    void releaseResource(List<Resource> resources);
}
```

resource.tag 为融合动画的 tag（下标），可以判断 tag 传入不同的文字或图片资源。

### setOnResourceClickListener

**说明**

设置融合动画的资源点击事件。

**接口**

```java
public void setOnResourceClickListener(OnResourceClickListener listener)
```

**参数说明**

OnResourceClickListener 接口：

```java
public interface OnResourceClickListener {

    void onClick(Resource resource);
}
```

根据 resource.tag 区分融合动画的资源。

### setRenderRotation

**说明**

设置融合动画选择旋转角度，支持 0， 90，180, 270， 360 度。

**接口**

```java
public void setRenderRotation(int rotation)
```

### isPlaying

**说明**

返回特效播放器是否在播放中

**接口**

```java
public boolean isPlaying()
```

### resume

**说明**

恢复特效动画播放

**接口**

```java
public void resume()
```

### pause

**说明**

暂停特效动画播放

**接口**

```java
public void pause()
```


### seekTo

**说明**

跳转到指定位置开始播放

注意：
1. startPlay() 之后才可以调用该方法，否则不生效
2. 该接口对于 mp4 动画、或者设置了 TCEffectConfig.CodecType.TX_LITEAV_SDK 时播放的mp4动画生效

milliSec：要跳转到指定时长处开始播放，单位毫秒


**接口**

```java
public void seekTo(long milliSec)
```

### seekProgress
**说明**

跳转到指定位置开始播放

注意：
1. startPlay() 之后才可以调用该方法，否则不生效
2. 该接口对于 tcmp4 动画、或者设置了 TCEffectConfig.CodecType.TX_LITEAV_SDK 时播放的mp4动画生效
3. 入参 progress 取值范围为 [0.0-1.0]，超出范围的不生效

progress：跳转到动画时长的指定百分比处开始播放，单位百分比，取值范围为:[0.0-1.0]

**接口**

```java
public void seekProgress(float progress)
```


### setLoop

**说明**

设置循环播放。

true： 表示循环播放；

false： 表示关闭循环播放；

**接口**

```java
public void setLoop(boolean isLoop)
```



### setLoopCount

**说明**

设置循环播放次数。

loopCount： 表示循环播放次数。当loopCount <=0 时，表示无限循环播放；当 loopCount=n(n>=1)时表示从开始播放到播放结束，共播放n次

注意：
1. loopCount 默认值是1，即当外部不主动调用该方法时，动画只播放一次就结束
2. setLoop(boolean isLoop) 方法内部会调用当前方法，即当 isLoop = true 时，等价于调用 setLoopCount(-1)；，即当 isLoop = false 时，等价于调用 setLoopCount(1)；因此这两个方法是互相影响的，后调用的会覆盖之前的调用。


**接口**

```java
public void setLoopCount(int loopCount)
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

```java
public void setDuration(long durationInMilliSec)
```


### stopPlay

**说明**

停止播放。

**接口**

```java
public void stopPlay(boolean clearLastFrame)
```

### setMute

**说明**

设置是否静音播放。

true： 静音播放；

false： 非静音播放；

**接口**

```java
public void setMute(boolean mute)
```

### setPlayListener

**说明**

设置特效播放器播放回调。

**接口**

```java
public void setPlayListener(IAnimPlayListener listener)
```

**参数说明**

IAnimPlayListener 接口：

```java
public interface IAnimPlayListener {
    void onPlayStart();

    void onPlayEnd();

    void onPlayError(int errorCode);

    void onPlayEvent(int event, Bundle param);
}
```

对于 onPlayEvent 方法中的 event 值详见 TCEffectPlayerConstant 类中的常量值：
```java
public static final int REPORT_INFO_ON_PLAY_EVT_PLAY_END = 2006;
public static final int REPORT_INFO_ON_PLAY_EVT_RCV_FIRST_I_FRAME = 2003;
public static final int REPORT_INFO_ON_PLAY_EVT_CHANGE_RESOLUTION = 2009;
public static final int REPORT_INFO_ON_PLAY_EVT_LOOP_ONCE_COMPLETE = 6001;
public static final int REPORT_INFO_ON_VIDEO_CONFIG_READY = 200001;
public static final int REPORT_INFO_ON_NEED_SURFACE = 200002;
public static final int REPORT_INFO_ON_VIDEO_SIZE_CHANGE = 200003;
public static final int REPORT_ANIM_INFO = 200004;
```


对于 onPlayError 方法中的 errorCode 值详见 TCEffectPlayerConstant 类中的常量值：

```java
public static final int REPORT_ERROR_TYPE_HEVC_NOT_SUPPORT = -10007; // 不支持h265
public static final int REPORT_ERROR_TYPE_INVALID_PARAM = -10008; // 参数非法
public static final int REPORT_ERROR_TYPE_INVALID_LICENSE = -10009; // License 不合法
public static final int REPORT_ERROR_TYPE_ADVANCE_MEDIA_PLAYER = -10010; // MediaPlayer播放失败
public static final int REPORT_ERROR_TYPE_MC_DECODER = -10011; // MediaCodec 中 Decoder 失败
public static final int REPORT_ERROR_TYPE_UNKNOWN_ERROR = -20000; // 未知错误
```

### getTCAnimInfo

**说明**

获取当前播放动画对应的信息，返回 TCEffectAnimInfo 实例，详见 TCEffectAnimInfo 

注意：该方法必须在 IAnimPlayListener#onPlayStart() 方法中，或者该方法执行之后调用才可以获取到当前动画的信息，否则返回null

**接口**

```java
public TCEffectAnimInfo getTCAnimInfo()
```

### getTCEffectPlayer

**说明**

获取 TCEffectPlayer 实例。

**接口**

```java
public TCEffectPlayer getTCEffectPlayer() 
```

### onDestroy

**说明**

停止播放并释放资源。

**接口**

```java
public void onDestroy()
```

## TCEffectConfig类

**注意：以下功能需要腾讯云视立方·礼物动画特效 企业版 SDK 和 企业 License 授权才支持， 可以[点击这里](https://cloud.tencent.com/document/product/616/116459)了解详情。**

**说明**

构造特效播放器配置，需要通过 Builder  构造。

**Builder接口**

```java
// 设置 CodecType
public Builder setCodecType(CodecType type)
```

**参数说明**

setCodecType(CodecType type) ：它有三个取值，分别是：

- TCEffectConfig.CodecType.TC_MPLAYER (MPLAYER播放引擎)

- TCEffectConfig.CodecType.TC_MCODEC(MCODEC播放引擎) 

- TCEffectConfig.CodecType.TX_LITEAV_SDK (腾讯云播放器SDK)


```java
// 设置播放配置，非必需得步骤
TCEffectConfig config = new TCEffectConfig.Builder().setCodecType(TCEffectConfig.CodecType.TC_MPLAYER).build();
mPlayerView.setConfig(config);
```

注意：

1. 目前仅支持在播放器开始前调用 setConfig() 方法来设置播放配置，开始播放后不支持修改配置

2. 目前支持的三种CodecType仅对 TEP 动画生效

3. 如果设置CodecType为 TCEffectConfig.CodecType.TX_LITEAV_SDK ，则还需要单独引入腾讯云播放器SDK，以及申请、注册好其对应的license。 

4. 如果不设置config，则会默认使用 CodecType = TCEffectConfig.CodecType.TC_MPLAYER



```java
// 设置冻结停留帧索引
public Builder setFreezeFrame(int frame)
```
**参数说明**

入参frame表示当动画播放中需要停留在哪一帧。目前可选值：

- TCEffectConfig.FREEZE_FRAME_NONE : 关闭freezeFrame能力，播放器正常播放暂停消失

- TCEffectConfig.FREEZE_FRAME_LAST : 当第一次播放完毕之后，画面停留在最后一帧

```java
// 设置后续要播放的动画格式
public Builder setAnimType(AnimType type)
```
**参数说明**

用于指定后续要播放的动画格式，适用于某些情况下，要播放的动画文件后缀被修改的场景。入参type表示要指定的动画格式。目前可选值：

- TCEffectConfig.AnimType.AUTO  (sdk默认策略，即以动画文件的后缀来判断动画格式，比如tcmp4/mp4/tep/tepg等格式)

- TCEffectConfig.AnimType.MP4  (MP4动画格式，后续都将动画文件当做MP4类型来播放，无视文件后缀名)

- TCEffectConfig.AnimType.TCMP4 (TCMP4动画格式，后续都将动画文件当做TCMP4类型来播放，无视文件后缀名)




## TCEffectAnimInfo
**说明**

存储当前播放的动画信息

**属性说明**

| 属性名   | 类型              | 描述           |
| -------- | ----------------| -------------- |
| type     | int             | 当前动画类型，取值：TCEffectAnimInfo.TYPE_MP4 和 TCEffectAnimInfo.TYPE_TCMP4 |
| duration | long            | 动画时长，单位毫秒 |
| width    | int             | 动画宽度         |
| height   | int             | 动画高度         |
| encryptLevel  | int             | 当前动画的高级加密类型，取值如果是TCEffectAnimInfo#ENCRYPT_LEVEL_NONE表示没有高级加密，否则表示已是高级加密         |
| mixInfo   | MixInfo             | 融合动画信息，为null时则表示该动画无融合信息                        |



## TCEffectAnimInfo.MixInfo
**说明**

存储当前播放动画中的融合信息

**属性说明**

| 属性名   | 类型              | 描述                      |
| -------- | ----------------|-------------------------|
| textMixItemList     | List<MixItem>             | 文字融合信息，为null时则表示无文字融合信息 |
| imageMixItemList     | List<MixItem>             | 图片融合信息，为null时则表示无图片融合信息 |


## TCEffectAnimInfo.MixInfo.MixItem
**说明**

存储当前播放动画中的融合信息

**属性说明**

| 属性名   | 类型            | 描述                                                                              |
| -------- |---------------|---------------------------------------------------------------------------------|
| id     | String        | 当前融合动画id。如果是tcmp4时，则是对应要替换的图层index;如果是mp4时，则是在工具中显示的id值                         |
| tag     | String        | 当前融合动画tag。如果是tcmp4时，则是固定值：TCEffectPlayerConstant.TAG_TPEG;如果是mp4时，则是在工具中填写的tag值 |
| text     | String        | 当前文字融合动画文字内容(图片融合动画时该值为空)。如果是tcmp4时，则是其内部原始的文字内容;如果是mp4时，则是在工具中填写的tag值         |


## TCEffectText
**说明**

融合动画替换文本样式数据类

**属性说明**

| 属性名       | 类型     | 描述                                                                                                                                                                   |
|-----------|--------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| text      | String | 最终要替换显示的文本内容                                                                                                                                                         |
| color     | int    | 文字颜色，格式要求：ARGB，如 0xFFFFFFFF                                                                                                                                          |
| fontStyle | String | 文字显示样式，可取值："bold"表示粗体，不传则默认大小                                                                                                                                        |
| alignment    | int    | 文字对齐方式，可取值：TEXT_ALIGNMENT_NONE（默认值，即保持sdk默认对齐方式）、TCEffectText.TEXT_ALIGNMENT_LEFT(居左) 、TCEffectText.TEXT_ALIGNMENT_CENTER(居中)、 TCEffectText.TEXT_ALIGNMENT_RIGHT(居右) |
| fontSize     | float    | 文字大小，单位是px；如果设置了文字大小(值大于0)，则内部自动缩放策略失效，强制以设置的文字大小为准，则可能出现文字过大显示不全的问题|