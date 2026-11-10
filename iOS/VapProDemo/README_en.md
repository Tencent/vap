# VapProDemo (iOS)

English | [简体中文](./README.md)

The VAP Pro iOS demo uses a **locally integrated SDK** and **offline License authentication** to demonstrate and test the **mp4** playback capabilities of `TCEffectAnimView`.

## Features

A playback test screen that uses only mp4 assets:

- `startPlay` / `pause` / `resume` / `stopPlay`
- Codec: AVPlayer / VODPlayer
- Rate: 0.5x / 1.0x / 1.5x / 2.0x
- Rotation: 0° / 90° / 180° / 270°
- ScaleType: Fit / Fill / Stretch
- Loop / Mute
- Fusion assets (image / text)
- Snapshot
- Switch animation asset (cycle through)

## Project Structure

```
VapProDemo/
├── Podfile                              # Local podspec SDK integration + Masonry
├── sdk/                                 # Local SDK (podspec and xcframework in the same directory)
│   ├── TCMediaX/
│   │   ├── TCMediaX.podspec
│   │   └── TCMediaX.xcframework
│   └── TCEffectPlayer/
│       ├── TCEffectPlayer.podspec
│       └── TCEffectPlayer.xcframework
├── VapProDemo.xcodeproj/
└── VapProDemo/
    ├── AppDelegate.{h,m}                # License authentication entry point
    ├── SceneDelegate.{h,m}
    ├── ViewController.{h,m}             # mp4 test screen
    ├── BackgroundView.{h,m}             # Checkerboard background
    ├── main.m
    ├── Info.plist
    ├── Assets.xcassets/
    ├── Base.lproj/
    │   ├── LaunchScreen.storyboard
    │   └── Main.storyboard
    └── Resource/                        # mp4 test assets + fusion avatar images
        ├── demo.mp4
        ├── vap_car_ronghe.mp4
        └── vap_king_ronghe.mp4
```

## Local SDK Integration

The two xcframeworks are shipped with the project under `VapProDemo/sdk/`. Each is integrated through a local `podspec` in the same directory using `vendored_frameworks`, referenced from the Podfile with `pod 'XXX', :path => 'sdk/XXX'`.

CocoaPods only handles project linking; the SDK itself is **entirely local** and is not downloaded over the network.

### Build Steps

```bash
cd vap/iOS/VapProDemo
pod install
open VapProDemo.xcworkspace
```

Then select a simulator or a physical device in Xcode and run.

> **Note**: In Xcode, open `VapProDemo.xcworkspace` (the CocoaPods output), **not** `VapProDemo.xcodeproj`.

## License Authentication

Following `TCMXMenuConfigManager` in `TCMediaX/demo`, in `AppDelegate.m`:

```objc
[[TCMediaXBase getInstance] setLogEnable:YES];
[[TCMediaXBase getInstance] setLicense:sLicenseV2
                              callback:^(int errCode, NSString *msg) {
    NSLog(@"TCMediaX license result: errCode: %d, msg: %@", errCode, msg);
}];
```

### Bundle Identifier Must Match

The `sLicenseV2` bundled with the demo is bound to the bundle identifier:

```
com.yunxiao.dev.tcmediax.demo
```

`PRODUCT_BUNDLE_IDENTIFIER` in `VapProDemo.xcodeproj` is fixed to this value. **Do not change it**; when replacing the License with your own, update the bundle identifier accordingly.

## mp4 Test Assets

Bundled in `VapProDemo/Resource/`:

| File | Purpose |
| ---- | ------- |
| demo.mp4 | Standard VAP animation |
| vap_car_ronghe.mp4 | With fusion assets (image + text) |
| vap_king_ronghe.mp4 | With fusion assets |

Tap the "Switch Animation" button at the top to cycle through the current test file.
