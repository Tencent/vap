# API 升级对照：开源 VAP → 礼物动画特效 Vap Pro SDK

本文只做**接口级对照**，升级流程请见 [MIGRATION.md](../MIGRATION.md)。
Vap Pro 侧以仓库内的官方 API 文档为准：

- Android：[Android/docs/TCEffectPlayer（Android） API-zh-CN.md](../Android/docs/TCEffectPlayer（Android）%20API-zh-CN.md)（英文版见同目录 `API-en.md`）
- iOS：[iOS/docs/TCEffectPlayer（iOS） API-zh-CN.md](../iOS/docs/TCEffectPlayer（iOS）%20API-zh-CN.md)（英文版见同目录 `API-en.md`）

---

## 1. 概念映射

| 开源 VAP | 礼物动画特效 Vap Pro SDK | 说明 |
| -------- | ----------- | ---- |
| `AnimView`（Android） / `UIView+VAP`（iOS） | `TCEffectAnimView` | 播放容器 |
| `AnimConfig` / `QGVAPConfigModel`（vapc 解析结果） | `TCEffectConfig` / `getTCAnimInfo()` | 动画配置与信息 |
| 融合 tag（`[sImg1]`、`[sTxt1]`） | `resource.id` / `resource.tag` | 融合图层标识 |
| 融合素材（图片 / 文字） | `Resource`（`SrcType.IMG` / `SrcType.TXT`） | 融合资源对象 |
| 硬解（VideoToolbox / MediaCodec） | 硬解（VideoToolbox / MediaCodec） | [礼物动画特效企业版](https://cloud.tencent.com/document/product/616/116459)支持软解播 |

## 2. 前置差异：License 初始化（开源无此步骤）

Vap Pro **必须先申请并注册 License**，否则播放失败（Android `-10009` / iOS `-10009`，日志 `License checked failed! tceffect player license required!`）。

| 平台 | 接口 |
| ---- | ---- |
| Android | `TCMediaXBase.getInstance().setLicense(Context, String license, ILicenseCallback)` |
| iOS | `[[TCMediaXBase getInstance] setLicense:(NSString *)license callback:(TCMediaXLicenseCallback)callback]` |

**Android**

```java
TCMediaXBase.getInstance().setLicense(appContext, license, new ILicenseCallback() {
    @Override
    public void onResult(int errCode, String msg) {
        Log.d(TAG, "TCMediaX license result: errCode: " + errCode + ", msg: " + msg);
    }
});
```

**iOS**

```objc
[[TCMediaXBase getInstance] setLicense:LICENSE callback:^(int errCode, NSString * _Nullable message) {
    NSLog(@"setLicense callback errCode:%d, message:%@", errCode, message);
}];
```

建议在 Application / AppDelegate 启动时完成，且**早于任何播放调用**。

## 3. Android 接口对照

| 能力 | 开源 VAP | 礼物动画特效 Vap Pro SDK |
| ---- | -------- | ----------- |
| 布局声明 | `<com.tencent.qgame.animplayer.AnimView>` | `<com.tencent.tcmediax.tceffectplayer.api.TCEffectAnimView>` |
| 初始化 | `animView = findViewById(R.id.player)` | `mPlayerView = findViewById(R.id.video_view)` |
| 开始播放 | `animView.startPlay(file)` | `mPlayerView.startPlay(localPath)`（**仅本地文件**） |
| 暂停 | `animView.stopPlay()`（依版本） | `mPlayerView.pause()` |
| 继续播放 | 重新 `startPlay` | `mPlayerView.resume()` |
| 停止并释放 | `animView.stopPlay()` | `mPlayerView.stopPlay(true)` |
| 播放回调 | `IAnimListener`（`onVideoConfigReady` / `onVideoStart` / `onVideoComplete` / `onVideoDestroy` / `onFailed`） | `setPlayListener(TCEffectAnimView.IAnimPlayListener)`（`onPlayStart` / `onPlayEnd` / `onPlayError`） |
| 缩放对齐 | `setScaleType(ScaleType.FIT_XY)` | `setScaleType(TCEffectPlayerConstant.ScaleType)`（`FIT_XY` / `FIT_CENTER` / `CENTER_CROP`，默认 `FIT_CENTER`） |
| Alpha 布局 | 由素材 vapc 声明 | `setVideoMode(TCEffectPlayerConstant.VideoMode)`（`SPLIT_HORIZONTAL` / `SPLIT_VERTICAL` / …`_REVERSE` / `NONE`） |
| 图片融合 | `AnimView` 的 `loadVapImageWithURL` / 图片加载回调 | `setFetchResource(IFetchResource#fetchImage)` → `result.fetch(bitmap)` |
| 文字融合 | `contentForVapTag` 返回字符串 | `setFetchResource(IFetchResource#fetchText)` → `result.loadTextForPlayer(TCEffectText)`（支持 `text` / `color` / `alignment` / `fontStyle`） |
| 融合资源释放 | 无 | `IFetchResource#releaseResource(List<Resource>)` |
| 融合点击事件 | 手势识别（需业务自行命中判断） | `setOnResourceClickListener(OnResourceClickListener#onClick(Resource))` |
| 循环 / Seek | 依版本 | `setLoop` / `setLoopCount` / `seekTo` / `seekProgress` |
| 静音 | 依版本 | `setMute` |
| 动画信息 | `AnimConfig` | `getTCAnimInfo()`（`TCEffectAnimInfo`） |
| 生命周期 | 依版本 | `onDestroy` |
| License | 无 | `TCMediaXBase#setLicense`（**必做**） |

**最小示例**

```java
// 开源 VAP
AnimView animView = findViewById(R.id.player);
animView.startPlay(file);

// Vap Pro
TCEffectAnimView mPlayerView = findViewById(R.id.video_view);
mPlayerView.setScaleType(TCEffectPlayerConstant.ScaleType.FIT_CENTER);
mPlayerView.setPlayListener(new TCEffectAnimView.IAnimPlayListener() {
    @Override public void onPlayStart() {}
    @Override public void onPlayEnd() {}
    @Override public void onPlayError(int errorCode) {}
});
mPlayerView.startPlay(localMp4Path);  // localMp4Path 为本地文件路径
```

## 4. iOS 接口对照

| 能力 | 开源 VAP | 礼物动画特效 Vap Pro SDK |
| ---- | -------- | ----------- |
| 创建视图 | `[UIView playHWDMp4:]`（category）/ `QGVAPWrapView` | `[[TCEffectAnimView alloc] init]` |
| 布局 | `QGVAPWrapView` + `contentMode` | `setRenderMode(TCEPVPViewContentMode)`（`ScaleToFill` / `AspectFit` / `AspectFill`） |
| 开始播放 | `playHWDMp4:path` | `startPlay:`（**仅本地文件**） |
| 暂停 / 继续 | 依版本 | `pause` / `resume` |
| 停止并释放 | 依版本 | `stopPlay` |
| 静音 | 依版本 | `setMute:` |
| 循环 | 依版本 | `setLoop:` |
| 播放回调 | `viewDidStartPlayMP4` / `viewDidFinishPlayMP4` / `viewDidStopPlayMP4` / `viewDidFailPlayMP4` / `viewDidPlayMP4AtFrame` | `TCEffectAnimViewDelegate`（`effectPlayerDelegate`） |
| Alpha 布局 | 由素材 vapc 声明 | `setVideoMode:(TCEPVAPVideoFrameTextureBlendMode)`（`AlphaLeft` / `AlphaTop` / `AlphaRight` / `AlphaBottom` / `None`） |
| 文字融合 | `contentForVapTag:resource:`（返回字符串） | `loadTextForPlayer:withTag:`（返回 `TCEffectText`，支持 `text` / `alignment` / `color` / `fontStyle`） |
| 图片融合 | `loadVapImageWithURL:context:completion:` | `loadImageForPlayer:context:completion:`（`tag = context[TCEPContextSourceTypeImageIndex]`，图片下载与缓存由业务自行处理） |
| 融合点击事件 | `addVapTapGesture:` / `addVapGesture:callback:` | `tcePlayerTagTouchBegan:tag:` |
| 退后台行为 | `hwd_enterBackgroundOP`（Stop / PauseAndResume） | 不支持后台播放（**企业版支持，[点击查看](https://cloud.tencent.com/document/product/616/116459)**） |
| License | 无 | `[[TCMediaXBase getInstance] setLicense:callback:]`（**必做**） |

**最小示例**

```objc
// 开源 VAP
[mp4View playHWDMp4:resPath];

// Vap Pro
self.alphaAnimView = [[TCEffectAnimView alloc] init];
self.alphaAnimView.effectPlayerDelegate = self;
[self.alphaAnimView setRenderMode:TCEPVPViewContentModeScaleToFill];
[self.view addSubview:self.alphaAnimView];
self.alphaAnimView.frame = self.view.bounds;
[self.alphaAnimView startPlay:mp4Url];   // mp4Url 为本地文件路径
```

## 5. 错误码速查

| 错误码 | Android | iOS |
| ------ | ------- | --- |
| -10001 | 资源解封装失败（确认是 .mp4） | MediaExtractor 异常 |
| -10002 | 动画解码失败 | MediaCodec 异常 |
| -10003 | 创建解码线程失败（内存不足） | 创建线程失败 |
| -10004 | 配置信息解析失败（licenseKey 不一致） | render 创建失败 |
| -10005 | 融合资源准备失败（检查 setFetchResource） | 配置解析失败 |
| -10006 | 播放路径有误 | 文件无法读取 |
| -10007 | h265 不支持 | h265 不支持 |
| -10008 | 播放路径为空 | 参数非法 |
| -10009 | license 过期 / 不匹配 | license 不合法 |
| -10010 | — | 模拟器不支持 |
| -10011 / -10012 / -20000 | 播放失败 / 缺失依赖 / 其他异常 | — |
| -10013 | — | vap_pro 版本不支持 PAG / TEPG 播放 |
| -100200 ~ -100206 | — | 签名校验失败、解密失败、BundleID/PackageName 不一致、资源过期、JSON 字段不正确、boxType 不支持、vapx 融合资源获取失败 |
