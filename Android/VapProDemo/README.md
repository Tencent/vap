# VapProDemo

VAP Pro Android 端 Demo（本地集成 SDK + License 离线鉴权），用于演示和测试 `TCEffectAnimView` 的 **mp4** 播放能力。

## 功能

本 Demo 仅保留 **mp4** 格式的播放测试项，可测试以下 API：

- `startPlay` / `pause` / `resume` / `stopPlay`
- `setScaleType`：`FIT_CENTER` / `CENTER_CROP` / `FIT_XY` / `FIT_START` / `FIT_END`
- `setRenderRotation`：-180 / -90 / 0 / 90 / 180 / 270 / 360 / 450 / 540 / 630
- `setRate`（倍速）：0.5x ~ 3.0x
- `setLoop` / `setMute`
- `setConfig`：切换 Codec（`TC_MPLAYER` / `TC_MCODEC`）
- `setVideoMode`：常规模式 / `VIDEO_MODE_NONE`（自动根据资源文件名切换）
- `setFetchResource`：融合图片 / 文本
- `setOnResourceClickListener`：融合资源点击回调
- `snapshot`：截图

## 工程结构

```
VapProDemo/
├── build.gradle
├── settings.gradle
├── gradle.properties
├── gradle/wrapper/...
├── gradlew / gradlew.bat
└── app/
    ├── build.gradle                     # 使用 fileTree 本地集成 libs/ 下的 AAR
    ├── proguard-rules.pro
    ├── libs/                            # 本地 SDK AAR
    │   ├── TCMediaX_3.5.0.29002.aar
    │   ├── TCEffectPlayer_vap_pro_3.5.0.29002.aar
    │   └── xmagic-auth_3.5.0.29002.aar
    └── src/main/
        ├── AndroidManifest.xml
        ├── java/com/tencent/vappro/demo/
        │   ├── DemoApplication.java
        │   ├── TCMediaXLicenseService.java   # License 鉴权
        │   ├── ui/TCEffectPlayerApiTestActivity.java
        │   ├── util/{AnimFiles,Utils}.java
        │   └── view/{BackgroundView,BorderView}.java
        ├── assets/                      # mp4 测试资源
        └── res/
            ├── drawable-v24/ic_launcher_foreground.xml
            ├── drawable/ic_launcher_background.xml
            ├── drawable-xxhdpi/{demo_avatar_car,demo_avatar_earphone,demo_btn_back_gray}.png
            ├── layout/activity_api_test.xml
            ├── mipmap-*/
            └── values/{colors,strings,themes}.xml
```

## SDK 本地集成

在 `app/build.gradle` 中：

```gradle
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.aar'])
    ...
}
```

`libs/` 目录来自：`vap/Android/sdk/*.aar`

## License 鉴权

`TCMediaXLicenseService.init()` 在 `DemoApplication.onCreate()` 中被调用，使用 License字符串通过 `TCMediaXBase.setLicense(context, sLicenseV2, callback)` 一次性离线完成校验：

```java
TCMediaXBase.getInstance().setLogEnable(DemoApplication.getAppContext(), true);
TCMediaXBase.getInstance().setLicense(DemoApplication.getAppContext(), sLicenseV2, mLicenseCallback);
```

### applicationId 必须匹配

Demo 内置的 `sLicenseV2` 绑定的包名为：

```
com.tencent.tcmediax.demo
```

因此 `app/build.gradle` 中的 `applicationId` 已固定为该值，**请勿修改**，否则鉴权会失败。

替换为自己的 License 时，请同时修改 `applicationId` 为新 License 绑定的包名。

## 构建运行

1. 用 Android Studio 打开本工程目录。
2. 首次打开时 IDE 会自动创建 `local.properties`，指向本机 Android SDK 路径（也可手工创建：`sdk.dir=/your/android/sdk/path`）。
3. Gradle Sync 完成后，直接 Run `app`。

## mp4 测试资源

内置于 `app/src/main/assets/`，首次启动会拷贝到应用外部存储目录 `/Android/data/<pkg>/files/vappro/`：

| 文件名 | 用途 |
|-|-|
| demo.mp4 | 常规 VAP 动画 |
| vap_car_ronghe.mp4 | 带融合资源（图片 + 文本） |
| vap_king_ronghe.mp4 | 带融合资源 |

点击顶部"切换动画"按钮循环切换当前测试文件。
