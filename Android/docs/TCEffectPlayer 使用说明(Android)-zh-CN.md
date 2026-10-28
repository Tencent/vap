# 腾讯云视立方·礼物动画特效  Vap Pro SDK 简介

腾讯云视立方·礼物动画特效  Vap Pro SDK （以下简称：礼物动画特效 SDK）用于播放酷炫的视频动画，常见用于直播间里显示酷炫的送礼动画。

下面是原始模板视频播放和融合后播放的动画效果展示：

| 原始模板视频                                                 | 融合后播放效果                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_temlate.gif) | ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_vapx_car.gif) |

# 集成指引
## 手动集成

1. 下载 [MediaX_Android_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_Android_Vap_Pro_SDK_Latest.zip) ，下载完成后进行解压获取到 SDK aar 文件。
2. 将下载文件解压之后 SDK 目录下的 aar 文件拷贝到工程的 app/libs 目录下
3. 在工程根目录下的 build.gradle 中，添加 flatDir，指定本地仓库路径。
4. 添加 腾讯礼物动画特效SDK 依赖，在 app/build.gradle 中，添加引用 aar 包的代码
```groovy
implementation(name: "TCEffectPlayer_vap_pro_x.x.x", ext: "aar")
implementation(name: "TCMediaX_x.x.x", ext: "aar")
implementation(name: "xmagic-auth_x.x.x", ext: "aar")
```
注意：如上示例中的 x.x.x 为版本号，具体以实际下载的SDK最新版本号为准；另外需要注意3个 aar 的版本号必须一致。

5. 在 app/build.gradle 的 defaultConfig 中，指定 App 使用的 CPU 架构（目前支持 armeabi 、armeabi-v7a 和 arm64-v8a）。
```groovy
defaultConfig {
 ndk {
     abiFilters "armeabi", "armeabi-v7a", "arm64-v8a"
 }
}
```
## 设置混淆规则:
在 proguard-rules.pro 文件中，将相关类加入不混淆名单：

```java
-keep class com.tcmediax.** { *; }
-keep class com.tencent.** { *; }
-keep class androidx.exifinterface.** {*;}
```

# 申请授权 License

## 申请license

[点击打开](https://tceffect-license.tmf.qq.com/) 腾讯云视立方·礼物动画特效 VAP Pro SDK 授权申请页面，申请成功后，您将获取到一个永久授权的 License 字符串，请务必妥善保存。

## 初始化注册license

申请成功后，您将获得一段 License  字符串（已经过 base64 编码），直接传入下面的接口即可完成 License 校验。

```java
// 使用时替换 LICENSE 为申请到的 License envelope 字符串
String license = "${license}";
TCMediaXBase.getInstance().setLicense(appContext, license, new ILicenseCallback() {
    @Override
    public void onResult(int errCode, String msg) {
        Log.d(TAG, "TCMediaX license result: errCode: " + errCode + ", msg: " + msg);
    }
});
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

## 日志管理

可以通过调用 TCMediaXBase#setLogEnable 开启日志保存到文件，Android 端保存在 /sdcard/Android/data/packagename/files/TCMediaX 目录，iOS端保存在sandbox的Documents/TCMediaX目录，您可以根据业务需要把此目录的日志上传到业务后台，用于定位线上用户问题。


# 礼物动画特效 SDK TCEffectPlayer 使用

## 1、把TCEffectAnimView 加入布局里

```xml
<FrameLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:layout_marginTop="0dp">
    <com.tencent.tcmediax.tceffectplayer.api.TCEffectAnimView
        android:id="@+id/video_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_centerInParent="true"
        android:visibility="visible" />
</FrameLayout>
```

## 2、初始化TCEffectAnimView

```java
private TCEffectAnimView mPlayerView;
mPlayerView = (TCEffectAnimView) findViewById(R.id.video_view);

// 可选: 设置视频对齐方式（默认FIT_CENTER，支持自定义）
mPlayerView.setScaleType(TCEffectPlayerConstant.ScaleType.FIT_CENTER);
```

## 3、播放控制

### 开始播放

只支持播放 sdcard 本地视频资源， 如果您使用的网络视频资源， 先下载到本地再播放。

```java
String localPath = /sdcard/Android/${packageName}/files/tep_cool_ss.mp4
mPlayerView.startPlay(localPath)
```

### 暂停播放

```java
mPlayerView.pause()
```

### 继续播放

```java
mPlayerView.resume()
```

### 停止播放

 当不需要继续使用播放器时，需要停止播放，释放占用的资源。

```java
mPlayerView.stopPlay(true)
```

## 4、融合动画配置

实现Vap融合动画，需要实现 IFetchResource 接口，如果是图片类型需要返回对应的Bitmap，如果是文字需要返回对应的String。
```java
mPlayerView.setFetchResource(new IFetchResource() {
    @Override
    public void fetchImage(Resource resource, IFetchResourceImgResult result) {
        String index = resource.id;
        // 后续可以根据图层 index 的值，来选择你要替换返回的图片 Bitmap 资源
        // 如果想跳过指定图层不替换的话，可以返回 null
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inScaled = false;
        Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.test, options);
        // 回调结果出去
        result.fetch(bitmap);
    }
    @Override
    public void fetchText(Resource resource, IFetchResourceTxtResult result) {
        String index = resource.id;
        // 根据图层 index 的值，来选择你要替换返回的文字 String 即可
        TCEffectText tcEffectText = new TCEffectText();
        tcEffectText.text = "test";
//                    tcEffectText.color = Color.YELLOW;
//                    tcEffectText.alignment = TCEffectText.TEXT_ALIGNMENT_RIGHT;
        tcEffectText.fontStyle = "bold";
        result.loadTextForPlayer(tcEffectText);
    }
    @Override
    public void releaseResource(List<Resource> resources) {
        // 资源释放通知
        for (Resource resource : resources) {
            if (resource.bitmap != null) resource.bitmap.recycle();
        }
    }
});
```

监听Vap动画自定义资源被点击的事件，需要注册 OnResourceClickListener 监听:
```java
mPlayerView.setOnResourceClickListener(new OnResourceClickListener() {
    @Override
    public void onClick(Resource resource) {
        // 根据点击的资源类型来做展示处理
        if (resource.srcType.equals(Resource.SrcType.TXT)) {
            // 如果是 TXT 类型，则 id 字段是其图层id，text是其当时被替换的文本
            tvTest.setText(resource.text);
        } else {
            // 如果是 IMG 类型，则 id 字段是其图层id，bitmap是其当时被替换的图片
            ivTest.setImageBitmap(resource.bitmap);
        }
    }
});
```


## 5、播放监听

可以在开始播放之前通过调用 `setPlayListener` 方法来设置动画播放状态监听：

```java
// 设置播放状态回调
playerView.setPlayListener(new TCEffectAnimView.IAnimPlayListener() {
    @Override
    public void onPlayStart() {
        // 动画开始播放
    }

    @Override
    public void onPlayEnd() {
        // 动画结束播放
    }

    @Override
    public void onPlayError(int errorCode) {
        // 动画播放失败
    }
});
```

1. 如果你需要获取当前正在播放的动画信息，可以在 `onPlayStart()` 方法中(或者该方法执行之后)调用 `getTCAnimInfo()`方法来获取到 `TCEffectAnimInfo` 对象实例，进而获取到当前播放动画的类型、时长、宽高等信息。
2. `onPlayEvent()` 方法会回调动画播放中的事件，回调线程不保证都在主线程中。

# 常见问题

## 播放失败

如过在播放过程中出现下面的日志：

```xml
License checked failed! tceffect player license required!
```

请检查是否申请礼物动画特效 License，并进行了初始化注册。

## 提取运行日志

默认情况下， 礼物动画特效SDK 会保存运行日志，如果测试过程中出现问题，可以提取日志反馈给腾讯云客服。

### Android 端

特效播放器的日志保存在目录： /sdcard/Android/data/${your_packagename}/files/TCMediaLog ， 日志文件按照日期命名，把 TCMediaLog 文件夹导出即可。

![image-20240806165900560](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/android_log.png)

### iOS端

特效播放器的日志保存沙箱 Documents/TCMedialog 文件夹

1、导出沙箱文件，操作： 打开XCode-> Window -> Devices and Simulators

<img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/ios_container.png" alt="image-20240806170453328" style="zoom: 50%;" />

2、提取 AppData/Documents/TCMedialog 文件夹

<img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/ios_log.png" style="zoom:50%;" />

**没有日志文件？？**

请检查是否通过 TCMediaXBase#setLogEnable 传入 false 关闭了日志，默认文件日志是开启的。


## 常见错误码

| 错误码      | 描述        |
|----------|-----------|
| -10001  | 动画资源解封装失败，请优先检查播放的文件是否是 .mp4   |
| -10002  | 动画解码失败 |
| -10003   | 内部创建解码线程失败，请优先检查设备内存是否不足 |
| -10004 | 解析动画文件中的配置信息失败，检查动画文件转换时填写的 licenseKey 和 sdk 设置的licenseKey 是否一致    |
| -10005 | 融合动画准备资源失败，请检查 setFetchResource() 接口实现是否正确   |
| -10006 | 开始播放时，传入的动画文件路径有误，请检查该路径对应的文件是否存在   |
| -10007 | 动画视频编码格式是h265，在当前设备上不支持   |
| -10008 | 开始播放时，传入的动画文件路径为空，请检查   |
| -10009 | license 过期，请检查license有效期，以及license 、packageName 是否匹配   |
| -10011 | mp4动画 播放失败，详情见 errorMsg  |
| -10012 | 缺失一些必备依赖导致动画播放失败，缺失的依赖详情详情见 errorMsg                            |
| -20000 | 其他异常导致的播放失败，详情见 errorMsg   |

如果还是无法解决您的问题，请提供日志文件我们来排查，日志文件的提取详见上面