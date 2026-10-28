# Tencent Cloud RT-Cube · Gift AR Vap Pro SDK

English | [简体中文](./README.md)

**VAP has been upgraded to Tencent Cloud RT-Cube · Gift AR Vap Pro SDK**

The open-source VAP in this repository has been upgraded to the official Tencent Cloud edition **[Gift AR Vap Pro SDK](https://github.com/tencent/vap)** (Android / iOS; a free, perpetual [License](https://tceffect-license.tmf.qq.com/) is required).

The open-source code and the MIT license remain valid, and existing integrations can keep using them; for new integrations and scenarios that require official support, we recommend adopting Vap Pro SDK directly.

For commercial scenarios (asset encryption, software decoding playback, concurrent playback of multiple animations, background playback, and more), you can further upgrade to **[Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android)**.

## About Vap Pro SDK

Tencent Cloud RT-Cube · Gift AR Vap Pro SDK is Tencent Cloud's implementation and playback solution for gift animations. Built on the open-source VAP, it adds essential usability and bug fixes: alpha restoration, device compatibility, and official maintenance.

### Playback Effect Comparison

The same asset played by the open-source VAP vs. Vap Pro SDK on a real device:

| Open-source VAP | Gift AR Vap Pro SDK |
| --------------- | ------------------- |
| ![vap_open](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_open.gif) | ![vap_pro_sdk](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_pro_sdk.gif) |
| Insufficient alpha restoration accuracy: edges look grayish and dark, with gray edges and dark corners | Accurate alpha restoration: rich, lifelike colors with clean edges, no gray edges or dark corners |

The open-source VAP loses precision in alpha channel restoration, which easily produces gray edges and color fringing around the animation subject, making the overall look grayish and dark.
Gift AR Vap Pro SDK includes targeted optimizations for alpha restoration: it can accurately restore semi-transparent edges, delivering lifelike colors and clean edges that significantly improve the visual quality of gift animations.

> For the legacy VAP (Video Animation Player) project, see [Introduction.md](./Introduction.md).

## Version Selection

| Version | How to get | Positioning |
| ------- | ---------- | ----------- |
| **Tencent Cloud RT-Cube · Gift AR Vap Pro SDK** | Follow this document to integrate | Open-source VAP plus basic usability and bug fixes: alpha restoration, device compatibility, official maintenance. |
| **Tencent Cloud RT-Cube · Gift AR Enterprise SDK** | [Tencent Cloud Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android) | Commercial-grade effect playback solution: asset encryption, software decoding playback, concurrent playback of multiple animations, background playback, toolchain and official professional technical service. |

## Advantages of Gift AR Enterprise SDK

If you need asset encryption, software decoding playback, concurrent playback of multiple animations, background playback, and similar capabilities, we strongly recommend further upgrading to **[Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android)**.

### Gift AR Enterprise SDK Playback Demo

| Large live-streaming animation playback | Smooth playback of 32 avatar frames |
| --------------------------------------- | ----------------------------------- |
| ![mp4_gift_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/mp4_gift_play.gif) | ![tcmp4_grid_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/tcmp4_grid_play.gif) |
| A large live-streaming gift animation played full screen: fine detail, clean transparent edges, stable and smooth playback | 32 avatar-frame animations played concurrently on one screen: stable and smooth even with many streams in parallel, no stutter and no frame drops |

| Category | Capability | Gift AR Vap Pro SDK | Gift AR Enterprise SDK | Notes |
| -------- | ---------- | ------------------- | ---------------------- | ----- |
| **Decoding & Playback** | Auto software/hardware decode switch (fallback) | Not provided; playback fails if hardware decoding fails | Hardware decoding first, with automatic runtime fallback to software decoding | Improves playback success rate for large resolutions, low-end devices and complex devices |
| **Content Security** | Asset / animation file encryption (anti-piracy, anti-tampering) | Not provided | Full; assets cannot be extracted | Protects the content assets of effect materials |
| **Platform & Service** | Technical support and SLA | Maintained by the Tencent Cloud professional team | Ticket response + SLA + version maintenance | Technical support provided by the Tencent Cloud professional team |
| **Image Quality & Compatibility** | Concurrent playback of multiple small animations (40+ avatar frames + 1 large entrance animation) | Limited | Full | Supports a large VAP animation combined with small animations (tcmp4), with excellent performance metrics |
| **Playback Control** | Background playback (continue after switching to background) | Limited | Full support | Resident scenarios such as live streaming and voice chat rooms |
| **Formats & Toolchain** | Asset authoring tool | Open-source VapTool | Official professional gift authoring toolchain | Supports multi-format asset conversion (SVGA / PAG / Lottie / WebP / PNG sequence) |

Legend: `Full` = capability complete and verified through adaptation; `Limited` = capability exists but with constraints or known defects; `Not provided` = not available in this version.

Enterprise capabilities follow [Tencent Cloud RT-Cube · Gift AR - Feature Overview](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android).

> Note: The GIFs above are compressed and downsampled; actual playback is clearer and smoother.

## Upgrade to Vap Pro SDK in Three Steps

1. **Apply for a License**: open the [License application page](https://tceffect-license.tmf.qq.com/) and obtain a perpetual License string (free).
2. **Download the SDK**: Android / iOS integration guides are in the [Android](./Android) and [iOS](./iOS) directories.
3. **Replace playback and fusion APIs**: follow [MIGRATION.md](./MIGRATION.md). **Existing assets and assets produced by VapTool can be reused directly.**

## Platform Support

| Platform | Vap Pro SDK | Enterprise SDK |
| -------- | ----------- | -------------- |
| Android | [Integration guide for new users](./Android)<br />[Upgrade guide for existing users](./MIGRATION.md) | [Android integration guide](https://trtc.io/document/70531?product=beautyar&menulabel=core%20sdk&platform=android) |
| iOS | [Integration guide for new users](./iOS)<br />[Upgrade guide for existing users](./MIGRATION.md) | [iOS integration guide](https://trtc.io/document/70537?product=beautyar&menulabel=core%20sdk&platform=ios) |
| Web / H5 | Community edition, see [web](./web) | Not provided |
| Flutter | Not provided | [Flutter integration guide](https://trtc.io/document/73975?product=beautyar&menulabel=core%20sdk&platform=flutter) |

Asset authoring tool: [VapTool](./tool) (usage instructions are in the tool directory; it **remains usable**, and the assets it produces can be played directly by Vap Pro / Enterprise SDK)

Preview tool: [Mac](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_mac_1.2.0.zip), [Windows](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_1.2.0.exe)

## Apps Using VAP

![app](https://github.com/Tencent/vap/assets/3285051/3e5c9ce1-f654-413e-8c5e-ecb2088ed3fe)

## Issue and Feedback

VAP has been upgraded to Gift AR Vap Pro SDK; we recommend the following channels for feedback:

- **Gift AR Vap Pro SDK** technical discussions can continue in this repository's issues.
- For **Gift AR Enterprise SDK** usage problems, please contact us through [Tencent Cloud support](https://kf.qq.com/) or by [submitting a ticket](https://console.cloud.tencent.com/workorder/category) (log in to Tencent Cloud).

## License

VAP is under the MIT license. See the [LICENSE](./LICENSE.txt) file for details.

Note: The MIT license of this repository covers only the open-source VAP source code. **Gift AR Vap Pro SDK and Enterprise SDK are Tencent Cloud commercial products and require a License; the MIT license does not apply to them.**
