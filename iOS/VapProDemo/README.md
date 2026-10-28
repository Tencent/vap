# VapProDemo (iOS)

iOS 端 VAP Pro Demo，使用**本地集成 SDK** 和 **License 离线鉴权**，用于演示和测试 `TCEffectAnimView` 的 **mp4** 播放能力。

## 功能

 播放测试界面，仅测试 mp4 资源：

- `startPlay` / `pause` / `resume` / `stopPlay`
- Codec：AVPlayer / VODPlayer
- Rate：0.5x / 1.0x / 1.5x / 2.0x
- Rotation：0° / 90° / 180° / 270°
- ScaleType：Fit / Fill / Stretch
- Loop / Mute
- 融合资源（图片 / 文本）
- Snapshot 截图
- 切换动画资源（循环切换）

## 工程结构

```
VapProDemo/
├── Podfile                              # 本地 podspec 集成 SDK + Masonry
├── sdk/                                 # 本地 SDK（podspec 与 xcframework 同目录）
│   ├── TCMediaX/
│   │   ├── TCMediaX.podspec
│   │   └── TCMediaX.xcframework
│   ├── TCEffectPlayer/
│   │   ├── TCEffectPlayer.podspec
│   │   └── TCEffectPlayer.xcframework
│   └── YTCommonXMagic/
│       ├── YTCommonXMagic.podspec
│       └── YTCommonXMagic.xcframework
├── VapProDemo.xcodeproj/
└── VapProDemo/
    ├── AppDelegate.{h,m}                # License 鉴权入口
    ├── SceneDelegate.{h,m}
    ├── ViewController.{h,m}             # mp4 测试界面
    ├── BackgroundView.{h,m}             # 棋盘格背景
    ├── main.m
    ├── Info.plist
    ├── Assets.xcassets/
    ├── Base.lproj/
    │   ├── LaunchScreen.storyboard
    │   └── Main.storyboard
    └── Resource/                        # mp4 测试资源 + 融合头像图
        ├── demo.mp4
        ├── vap_car_ronghe.mp4
        └── vap_king_ronghe.mp4
```

## 本地 SDK 集成方式

3 个 xcframework 已随工程一起放在 `VapProDemo/sdk/` 下，并通过同目录的本地 `podspec` 以 `vendored_frameworks` 方式接入；Podfile 中用 `pod 'XXX', :path => 'sdk/XXX'` 引用。

CocoaPods 仅做工程链接工作，SDK 本身**完全来自本地**，不走网络。

### 构建步骤

```bash
cd vap/iOS/VapProDemo
pod install
open VapProDemo.xcworkspace
```

然后在 Xcode 中选择模拟器或真机运行即可。

> **注意**：在 Xcode 中请打开 `VapProDemo.xcworkspace`（CocoaPods 产物），而不是 `VapProDemo.xcodeproj`。

## License 鉴权

参考 `TCMediaX/demo` 的 `TCMXMenuConfigManager`，在 `AppDelegate.m` 中：

```objc
[[TCMediaXBase getInstance] setLogEnable:YES];
[[TCMediaXBase getInstance] setLicense:sLicenseV2
                              callback:^(int errCode, NSString *msg) {
    NSLog(@"TCMediaX license result: errCode: %d, msg: %@", errCode, msg);
}];
```

### Bundle Identifier 必须匹配

Demo 内置的 `sLicenseV2` 绑定的 bundle id 为：

```
com.tencent.tcmediax.demo
```

`VapProDemo.xcodeproj` 中的 `PRODUCT_BUNDLE_IDENTIFIER` 已固定为该值，**请勿修改**；替换为自己的 License 时请同步修改 bundle id。

## mp4 测试资源

内置于 `VapProDemo/Resource/`：

| 文件名 | 用途 |
|-|-|
| demo.mp4 | 常规 VAP 动画 |
| vap_car_ronghe.mp4 | 带融合资源（图片 + 文本） |
| vap_king_ronghe.mp4 | 带融合资源 |

点击顶部"切换动画"按钮循环切换当前测试文件。
