# Tencent Cloud RT-Cube · Gift AR Vap Pro SDK

English | [简体中文](./README.md)

The open-source VAP in this repository has been upgraded to the official Tencent Cloud **Gift AR Vap Pro SDK** (Android / iOS; you need to [apply for a License](https://tceffect-license.tmf.qq.com/) free of charge) and **[Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android)**.

The open-source code and the MIT license remain valid, and existing integrations can keep using them; [click here](https://github.com/Tencent/vap/tree/vap_open_source) for the legacy VAP. For new integrations and scenarios that require official support, we recommend adopting Vap Pro SDK directly.

## About Vap Pro SDK

Tencent Cloud RT-Cube · Gift AR Vap Pro SDK is Tencent Cloud's implementation and playback solution for gift animations. Built on the open-source VAP, it adds essential usability and bug fixes: alpha restoration, device compatibility, and official maintenance.

### Playback Effect Comparison

The same asset played by the open-source VAP vs. Vap Pro SDK on a real device:

| Open-source VAP playback | Gift AR Vap Pro SDK playback |
| ------------------------ | ---------------------------- |
| <img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_light.gif" alt="Open-source VAP playback" width="300" height="649"> | <img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_pro_light_new.gif" alt="Gift AR Vap Pro SDK playback" width="300" height="649"> |
| Insufficient alpha restoration accuracy: the picture looks grayish and dark, with gray edges and dark corners | Accurate alpha restoration: rich, lifelike colors with clean edges, no gray edges and no dark corners |

The open-source VAP loses precision in alpha channel restoration, which easily produces gray edges (Gray Edges) and color fringing (Color Fringing) around the animation subject, making the overall look grayish and dark.
Gift AR Vap Pro SDK includes targeted optimizations for alpha restoration: it can accurately restore semi-transparent edges, delivering lifelike colors and clean edges that significantly improve the visual quality of gift animations.

> For the legacy VAP (Video Animation Player) project, see [Introduction_en.md](./Introduction_en.md).
>

## Upgrade to Vap Pro SDK

1. **Apply for a License**: open the [License application page](https://tceffect-license.tmf.qq.com/) and obtain a perpetual License string (free).
2. **Download the SDK**: Android / iOS integration guides are in the [Android](./Android) and [iOS](./iOS) directories.
3. **Replace playback and fusion APIs**: follow [MIGRATION_en.md](./MIGRATION_en.md). **Existing assets and assets produced by VapTool can be reused directly.**

## Platform Support

| Platform | Vap Pro SDK | Enterprise SDK |
| -------- | ----------- | -------------- |
| Android | [Integration guide for new users](./Android/README_en.md)<br />[Upgrade guide for existing users](./MIGRATION_en.md) | [Android integration guide](https://trtc.io/document/70531?product=beautyar&menulabel=core%20sdk&platform=android) |
| iOS | [Integration guide for new users](./iOS/README_en.md)<br />[Upgrade guide for existing users](./MIGRATION_en.md) | [iOS integration guide](https://trtc.io/document/70537?product=beautyar&menulabel=core%20sdk&platform=ios) |
| Web / H5 | Community edition, see [web](./web) | Not provided |
| Flutter | Not provided | [Flutter integration guide](https://trtc.io/document/73975?product=beautyar&menulabel=core%20sdk&platform=flutter) |

Asset authoring tool: [VapTool](./tool) (usage instructions are in the tool directory; it **remains usable**, and the assets it produces can be played directly by Vap Pro / Enterprise SDK)

Preview tool: [Mac](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_mac_1.2.0.zip), [Windows](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_1.2.0.exe)

## Gift AR Enterprise SDK — Asset Encryption, Software Decoding Playback, Concurrent Animation Playback



If you need asset encryption, software decoding playback, concurrent playback of multiple animations, background playback, and similar capabilities, we strongly recommend further upgrading to **[Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android)**.

### Gift AR Enterprise SDK Playback Demo

| Large live-streaming animation playback | Smooth playback of 32 avatar frames |
| --------------------------------------- | ----------------------------------- |
| ![mp4_gift_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/mp4_gift_play.gif) | ![tcmp4_grid_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/tcmp4_grid_play.gif) |
| A large live-streaming gift animation played full screen: fine detail, clean transparent edges, stable and smooth playback | 32 avatar-frame animations played concurrently on one screen: stable and smooth even with many streams in parallel, no stutter and no frame drops |

<table>
<thead>
<tr><th>Category</th><th>Capability</th><th>Gift AR Vap Pro SDK</th><th>Gift AR Enterprise SDK</th><th>Notes</th></tr>
</thead>
<tbody>
<tr><td rowspan="2"><b>Decoding &amp; Playback</b></td><td>Hardware decoding playback</td><td align="center">✅</td><td align="center">✅</td><td>Playback using the device hardware decoder</td></tr>
<tr><td>Auto software/hardware decode switch (fallback)</td><td align="center">❌</td><td align="center">✅</td><td>Enterprise: hardware decoding first, with automatic runtime fallback to software decoding; improves playback success rate for large resolutions, low-end devices and complex devices</td></tr>
<tr><td><b>Content Security</b></td><td>Asset / animation file encryption (anti-piracy, anti-tampering)</td><td align="center">❌</td><td align="center">✅</td><td>Enterprise: assets cannot be extracted, protecting the content assets of effect materials</td></tr>
<tr><td><b>Image Quality &amp; Compatibility</b></td><td>Concurrent playback of multiple small animations (40+ avatar frames + 1 large entrance animation)</td><td align="center">⚠️</td><td align="center">✅</td><td>Enterprise supports a large VAP animation combined with small animations (tcmp4), with excellent performance metrics</td></tr>
<tr><td rowspan="4"><b>Playback Control</b></td><td>Background playback (continue after switching to background)</td><td align="center">❌</td><td align="center">✅</td><td>Resident scenarios such as live streaming and voice chat rooms</td></tr>
<tr><td>setLoop</td><td align="center">✅</td><td align="center">✅</td><td>Loop playback</td></tr>
<tr><td>seekTo</td><td align="center">✅</td><td align="center">✅</td><td>Seek to a specified position and play</td></tr>
<tr><td>Last-frame freeze</td><td align="center">❌</td><td align="center">✅</td><td>Keep the last frame on screen when playback ends</td></tr>
<tr><td rowspan="2"><b>Fusion Animation</b></td><td>Dynamic update of fusion animation elements</td><td align="center">❌</td><td align="center">✅</td><td>Fusion elements can be updated dynamically during playback</td></tr>
<tr><td>Fusion text customization (font color / size / alignment)</td><td align="center">❌</td><td align="center">✅</td><td>Supports custom font color, size and alignment</td></tr>
<tr><td><b>Playback Performance</b></td><td>High-performance playback (optimizations for low-end devices: performance / memory / power)</td><td align="center">⚠️</td><td align="center">✅</td><td>Optimized performance, memory and power consumption on low-end devices</td></tr>
<tr><td rowspan="3"><b>Platform &amp; Service</b></td><td>Technical support and SLA</td><td align="center">❌</td><td align="center">✅</td><td>Vap Pro is maintained by the Tencent Cloud professional team; Enterprise provides ticket response + SLA + version maintenance</td></tr>
<tr><td>Dedicated business support group</td><td align="center">❌</td><td align="center">✅</td><td>Enterprise supports timely communication via a WeCom group</td></tr>
<tr><td>Targeted SDK release</td><td align="center">❌</td><td align="center">✅</td><td>Targeted SDK delivery for bug fixes</td></tr>
<tr><td><b>Formats &amp; Toolchain</b></td><td>Official professional asset authoring tool</td><td align="center">❌</td><td align="center">✅</td><td>Vap Pro ships the open-source VapTool; Enterprise provides the official professional toolchain, supporting multi-format conversion (SVGA / PAG / Lottie / WebP / PNG sequence)</td></tr>
<tr><td><b>License &amp; Authorization</b></td><td>Bulk authorization for multiple apps</td><td align="center">❌</td><td align="center">✅</td><td>Supports bulk authorization and clone apps</td></tr>
</tbody>
</table>

Legend: ✅ Supported　⚠️ Partially supported (with constraints or known defects)　❌ Not supported

Enterprise capabilities follow [Tencent Cloud RT-Cube · Gift AR - Feature Overview](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android).

> Note: The GIFs above are compressed and downsampled; actual playback is clearer and smoother.
>

## Apps Using VAP

![app](https://github.com/Tencent/vap/assets/3285051/3e5c9ce1-f654-413e-8c5e-ecb2088ed3fe)

## Issue and Feedback

VAP has been upgraded to Gift AR Vap Pro SDK; we recommend the following channels for feedback:

- **Gift AR Vap Pro SDK** technical discussions can continue in this repository's issues.
- For **Gift AR Enterprise SDK** usage problems, please contact us through [Tencent Cloud support](https://kf.qq.com/) or by [submitting a ticket](https://console.cloud.tencent.com/workorder/category) (log in to Tencent Cloud).

## License

VAP is under the MIT license. See the [LICENSE](./LICENSE.txt) file for details.

Note: The MIT license of this repository covers only the open-source VAP source code. **Gift AR Vap Pro SDK and Enterprise SDK are Tencent Cloud commercial products and require a License; the MIT license does not apply to them.**
