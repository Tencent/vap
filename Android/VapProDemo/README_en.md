# VapProDemo

English | [简体中文](./README.md)

The VAP Pro Android demo (locally integrated SDK + offline License authentication), used to demonstrate and test the **mp4** playback capabilities of `TCEffectAnimView`.

## Features

This demo keeps only **mp4** playback test items, covering the following APIs:

- `startPlay` / `pause` / `resume` / `stopPlay`
- `setScaleType`: `FIT_CENTER` / `CENTER_CROP` / `FIT_XY` / `FIT_START` / `FIT_END`
- `setRenderRotation`: -180 / -90 / 0 / 90 / 180 / 270 / 360 / 450 / 540 / 630
- `setRate` (playback speed): 0.5x ~ 3.0x
- `setLoop` / `setMute`
- `setConfig`: switch Codec (`TC_MPLAYER` / `TC_MCODEC`)
- `setVideoMode`: normal mode / `VIDEO_MODE_NONE` (automatically switched based on the asset file name)
- `setFetchResource`: fusion image / text
- `setOnResourceClickListener`: fusion resource click callback
- `snapshot`: capture a screenshot

## Project Structure

```
VapProDemo/
├── build.gradle
├── settings.gradle
├── gradle.properties
├── gradle/wrapper/...
├── gradlew / gradlew.bat
└── app/
    ├── build.gradle                     # Integrates the AARs under libs/ via fileTree
    ├── proguard-rules.pro
    ├── libs/                            # Local SDK AARs
    │   ├── TCMediaX_3.5.0.29003.aar
    │   └── TCEffectPlayer_3.5.0.29003.aar
    └── src/main/
        ├── AndroidManifest.xml
        ├── java/com/tencent/vappro/demo/
        │   ├── DemoApplication.java
        │   ├── TCMediaXLicenseService.java   # License authentication
        │   ├── ui/TCEffectPlayerApiTestActivity.java
        │   ├── util/{AnimFiles,Utils}.java
        │   └── view/{BackgroundView,BorderView}.java
        ├── assets/                      # mp4 test assets
        └── res/
            ├── drawable-v24/ic_launcher_foreground.xml
            ├── drawable/ic_launcher_background.xml
            ├── drawable-xxhdpi/{demo_avatar_car,demo_avatar_earphone,demo_btn_back_gray}.png
            ├── layout/activity_api_test.xml
            ├── mipmap-*/
            └── values/{colors,strings,themes}.xml
```

## Local SDK Integration

In `app/build.gradle`:

```gradle
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.aar'])
    ...
}
```

The `libs/` directory comes from `vap/Android/sdk/*.aar`.

## License Authentication

`TCMediaXLicenseService.init()` is called from `DemoApplication.onCreate()`. It performs a one-time offline verification using the License string via `TCMediaXBase.setLicense(context, sLicenseV2, callback)`:

```java
TCMediaXBase.getInstance().setLogEnable(DemoApplication.getAppContext(), true);
TCMediaXBase.getInstance().setLicense(DemoApplication.getAppContext(), sLicenseV2, mLicenseCallback);
```

### applicationId Must Match

The `sLicenseV2` bundled with the demo is bound to the package name:

```
com.tencent.tcmediax.demo
```

Therefore `applicationId` in `app/build.gradle` is fixed to this value. **Do not change it**, or authentication will fail.

When replacing the License with your own, also update `applicationId` to the package name bound to the new License.

## Build and Run

1. Open this project directory in Android Studio.
2. On first launch the IDE creates `local.properties` pointing to your local Android SDK (or create it manually: `sdk.dir=/your/android/sdk/path`).
3. After Gradle Sync completes, run the `app` module.

## mp4 Test Assets

Bundled in `app/src/main/assets/`. On first launch they are copied to the app's external storage directory `/Android/data/<pkg>/files/vappro/`:

| File | Purpose |
| ---- | ------- |
| demo.mp4 | Standard VAP animation |
| vap_car_ronghe.mp4 | With fusion assets (image + text) |
| vap_king_ronghe.mp4 | With fusion assets |

Tap the "Switch Animation" button at the top to cycle through the test files.
