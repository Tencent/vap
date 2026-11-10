# API Migration Comparison: Open-Source VAP → Gift AR Vap Pro SDK

English | [简体中文](./API_MIGRATION.md)

This document provides an **API-level comparison** only. For the migration workflow, see [MIGRATION_en.md](../MIGRATION_en.md).
For the Vap Pro side, the official API references in this repository are authoritative:

- Android: [Android/docs/TCEffectPlayer（Android） API-en.md](../Android/docs/TCEffectPlayer（Android）%20API-en.md) (for the Chinese version, see `API-zh-CN.md` in the same directory)
- iOS: [iOS/docs/TCEffectPlayer（iOS） API-en.md](../iOS/docs/TCEffectPlayer（iOS）%20API-en.md) (for the Chinese version, see `API-zh-CN.md` in the same directory)

---

## 1. Concept Mapping

| Open-source VAP | Gift AR Vap Pro SDK | Notes |
| --------------- | ------------------- | ----- |
| `AnimView` (Android) / `UIView+VAP` (iOS) | `TCEffectAnimView` | Playback container |
| `AnimConfig` / `QGVAPConfigModel` (vapc parsing result) | `TCEffectConfig` / `getTCAnimInfo()` | Animation configuration and information |
| Fusion tag (`[sImg1]`, `[sTxt1]`) | `resource.id` / `resource.tag` | Fusion layer identifier |
| Fusion asset (image / text) | `Resource` (`SrcType.IMG` / `SrcType.TXT`) | Fusion resource object |
| Hardware decoding (VideoToolbox / MediaCodec) | Hardware decoding (VideoToolbox / MediaCodec) | [Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android) also supports software-decoding playback |

## 2. Prerequisite Difference: License Initialization (Not Required in Open-Source VAP)

Vap Pro **requires applying for and registering a License first**; otherwise playback fails (Android `-10009` / iOS `-10009`, with the log `License checked failed! tceffect player license required!`).

| Platform | API |
| -------- | --- |
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

It is recommended to complete this during Application / AppDelegate startup, **before any playback call**.

## 3. Android API Comparison

| Capability | Open-source VAP | Gift AR Vap Pro SDK |
| ---------- | --------------- | ------------------- |
| Layout declaration | `<com.tencent.qgame.animplayer.AnimView>` | `<com.tencent.tcmediax.tceffectplayer.api.TCEffectAnimView>` |
| Initialization | `animView = findViewById(R.id.player)` | `mPlayerView = findViewById(R.id.video_view)` |
| Start playback | `animView.startPlay(file)` | `mPlayerView.startPlay(localPath)` (**local files only**) |
| Pause | `animView.stopPlay()` (version-dependent) | `mPlayerView.pause()` |
| Resume | Call `startPlay` again | `mPlayerView.resume()` |
| Stop and release | `animView.stopPlay()` | `mPlayerView.stopPlay(true)` |
| Playback callbacks | `IAnimListener` (`onVideoConfigReady` / `onVideoStart` / `onVideoComplete` / `onVideoDestroy` / `onFailed`) | `setPlayListener(TCEffectAnimView.IAnimPlayListener)` (`onPlayStart` / `onPlayEnd` / `onPlayError`) |
| Scale mode | `setScaleType(ScaleType.FIT_XY)` | `setScaleType(TCEffectPlayerConstant.ScaleType)` (`FIT_XY` / `FIT_CENTER` / `CENTER_CROP`, default `FIT_CENTER`) |
| Alpha layout | Declared by the asset's vapc | `setVideoMode(TCEffectPlayerConstant.VideoMode)` (`SPLIT_HORIZONTAL` / `SPLIT_VERTICAL` / …`_REVERSE` / `NONE`) |
| Image fusion | `AnimView`'s `loadVapImageWithURL` / image loading callback | `setFetchResource(IFetchResource#fetchImage)` → `result.fetch(bitmap)` |
| Text fusion | `contentForVapTag` returns a string | `setFetchResource(IFetchResource#fetchText)` → `result.loadTextForPlayer(TCEffectText)` (supports `text` / `color` / `alignment` / `fontStyle`) |
| Fusion resource release | N/A | `IFetchResource#releaseResource(List<Resource>)` |
| Fusion click events | Gesture recognition (hit testing must be implemented by the app) | `setOnResourceClickListener(OnResourceClickListener#onClick(Resource))` |
| Loop / Seek | Version-dependent | `setLoop` / `setLoopCount` / `seekTo` / `seekProgress` |
| Mute | Version-dependent | `setMute` |
| Animation information | `AnimConfig` | `getTCAnimInfo()` (`TCEffectAnimInfo`) |
| Lifecycle | Version-dependent | `onDestroy` |
| License | N/A | `TCMediaXBase#setLicense` (**required**) |

**Minimal example**

```java
// Open-source VAP
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
mPlayerView.startPlay(localMp4Path);  // localMp4Path is a local file path
```

## 4. iOS API Comparison

| Capability | Open-source VAP | Gift AR Vap Pro SDK |
| ---------- | --------------- | ------------------- |
| Create view | `[UIView playHWDMp4:]` (category) / `QGVAPWrapView` | `[[TCEffectAnimView alloc] init]` |
| Layout | `QGVAPWrapView` + `contentMode` | `setRenderMode(TCEPVPViewContentMode)` (`ScaleToFill` / `AspectFit` / `AspectFill`) |
| Start playback | `playHWDMp4:path` | `startPlay:` (**local files only**) |
| Pause / Resume | Version-dependent | `pause` / `resume` |
| Stop and release | Version-dependent | `stopPlay` |
| Mute | Version-dependent | `setMute:` |
| Loop | Version-dependent | `setLoop:` |
| Playback callbacks | `viewDidStartPlayMP4` / `viewDidFinishPlayMP4` / `viewDidStopPlayMP4` / `viewDidFailPlayMP4` / `viewDidPlayMP4AtFrame` | `TCEffectAnimViewDelegate` (`effectPlayerDelegate`) |
| Alpha layout | Declared by the asset's vapc | `setVideoMode:(TCEPVAPVideoFrameTextureBlendMode)` (`AlphaLeft` / `AlphaTop` / `AlphaRight` / `AlphaBottom` / `None`) |
| Text fusion | `contentForVapTag:resource:` (returns a string) | `loadTextForPlayer:withTag:` (returns `TCEffectText`, supports `text` / `alignment` / `color` / `fontStyle`) |
| Image fusion | `loadVapImageWithURL:context:completion:` | `loadImageForPlayer:context:completion:` (`tag = context[TCEPContextSourceTypeImageIndex]`; image download and caching are handled by the app) |
| Fusion click events | `addVapTapGesture:` / `addVapGesture:callback:` | `tcePlayerTagTouchBegan:tag:` |
| Background behavior | `hwd_enterBackgroundOP` (Stop / PauseAndResume) | Background playback not supported (**supported by the Enterprise SDK, [learn more](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android)**) |
| License | N/A | `[[TCMediaXBase getInstance] setLicense:callback:]` (**required**) |

**Minimal example**

```objc
// Open-source VAP
[mp4View playHWDMp4:resPath];

// Vap Pro
self.alphaAnimView = [[TCEffectAnimView alloc] init];
self.alphaAnimView.effectPlayerDelegate = self;
[self.alphaAnimView setRenderMode:TCEPVPViewContentModeScaleToFill];
[self.view addSubview:self.alphaAnimView];
self.alphaAnimView.frame = self.view.bounds;
[self.alphaAnimView startPlay:mp4Url];   // mp4Url is a local file path
```

## 5. Error Code Quick Reference

| Code | Android | iOS |
| ---- | ------- | --- |
| -10001 | Asset demuxing failed (verify it is an .mp4) | MediaExtractor exception |
| -10002 | Animation decoding failed | MediaCodec exception |
| -10003 | Failed to create decoding thread (out of memory) | Failed to create thread |
| -10004 | Config parsing failed (licenseKey mismatch) | Render creation failed |
| -10005 | Fusion resource preparation failed (check `setFetchResource`) | Config parsing failed |
| -10006 | Invalid playback path | File cannot be read |
| -10007 | h265 not supported | h265 not supported |
| -10008 | Playback path is empty | Invalid parameter |
| -10009 | License expired / mismatched | Invalid license |
| -10010 | — | Simulator not supported |
| -10011 / -10012 / -20000 | Playback failure / missing dependency / other exceptions | — |
| -10013 | — | vap_pro version does not support PAG / TEPG playback |
| -100200 ~ -100206 | — | Signature verification failed, decryption failed, BundleID/PackageName mismatch, asset expired, incorrect JSON field, unsupported boxType, failed to fetch vapx fusion resources |
