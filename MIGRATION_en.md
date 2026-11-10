# Migration Guide: Open-Source VAP → Gift AR Vap Pro SDK

English | [简体中文](./MIGRATION.md)

This guide is for teams that have already integrated the open-source VAP and want to migrate to the official Tencent Cloud **Gift AR Vap Pro SDK** **at low cost**.

For an API-level comparison, see [API_MIGRATION_en.md](./docs/API_MIGRATION_en.md).

---

## 0. Before You Migrate

| Item | Description |
| ---- | ----------- |
| Open-source repository status | Open-source VAP has been upgraded to Tencent Cloud RT-Cube · Gift AR Vap Pro SDK; the MIT license remains valid and the open-source code can still be used |
| Asset compatibility | The VAP mp4 + `vapc` config BOX protocol is preserved, so **existing assets play directly** |
| Asset authoring tool | `tool/` (VapTool) remains available, and the assets it produces can be played directly by Gift AR Vap Pro SDK |
| License | Gift AR Vap Pro SDK **requires applying for and registering a License before playback** (free, perpetual); unauthorized playback returns `-10009` |
| Platforms | Gift AR Vap Pro SDK currently supports Android / iOS |
| Capability boundary | Gift AR Vap Pro SDK only adds baseline usability; encryption, automatic software/hardware decode switching, background playback and more are [Enterprise SDK capabilities](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android) |

## 1. Apply for a License (Required, First Step)

1. Open the [License application page](https://tceffect-license.tmf.qq.com/);
2. Fill in the application information (the Android package name / iOS Bundle ID must match the final released app);
3. After submission you will receive a **perpetual** License string — keep it safe.

> The License is bound to the package name / Bundle ID. A mismatch triggers `LicenseV2PackageNotMatch(-5)` or `-100202`.

## 2. Download and Integrate the SDK

| Platform | Download | Integration guide |
| -------- | -------- | ----------------- |
| Android | [MediaX_Android_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_Android_Vap_Pro_SDK_Latest.zip) | [Android/README_en.md](./Android/README_en.md) |
| iOS | [MediaX_iOS_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_iOS_Vap_Pro_SDK_Latest.zip) | [iOS/README_en.md](./iOS/README_en.md) |

Android requires both `TCEffectPlayer_x.x.x` and `TCMediaX_x.x.x` (**the version numbers must match**);
iOS requires `TCMediaX.xcframework` and `TCEffectPlayer.xcframework`, plus `Other Linker Flags: -ObjC`.

## 3. Upgrade VAP to Vap Pro SDK

See the detailed [API migration comparison](./docs/API_MIGRATION_en.md).

## 4. Web Platform

The official Gift AR offering currently **supports Android / iOS only**; there is no Web version of Vap Pro. For Web:

- Continue using the community edition code in this repository's [web/](./web) (MIT, free to use);
- For commercial gift animation requirements on Web, contact us via [Tencent Cloud official channels](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android).

## 5. Migration Checklist

- [ ] License application succeeded, and the package name / Bundle ID matches the released app
- [ ] Android: the two aar versions match, `abiFilters` is configured, ProGuard rules are added
- [ ] iOS: the two frameworks are integrated, system libraries are added, `-ObjC` is set
- [ ] License initialization completes before playback, `setLicense` callback returns `errCode = 0`
- [ ] Existing assets (mp4 + vapc) play correctly
- [ ] Fusion animation (image / text) replacement works as expected
- [ ] Playback status callbacks and error handling are integrated (including error-code fallbacks)
- [ ] Sampling tests on low-end / older devices pass
- [ ] Log switch and upload policy confirmed (`TCMediaXBase#setLogEnable`)

## 6. Upgrade to the Enterprise SDK

If you have the following requirements, we strongly recommend upgrading to [Tencent Cloud RT-Cube · Gift AR Enterprise SDK](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android):

| Requirement | Gift AR Vap Pro SDK | Gift AR Enterprise SDK |
| ----------- | ------------------- | ---------------------- |
| Asset / animation file encryption (anti-piracy, anti-tampering) | Not provided | Fully supported |
| Background playback | Not provided | Fully supported |
| Auto software/hardware decode switch (fallback) | Not provided | Fully supported |
| Mac simulator architecture support | Not provided | Fully supported |
| Official asset toolchain and technical support SLA | Not provided | Full technical support and service |

## 7. Getting Help

- Official documentation: [Tencent Cloud RT-Cube · Gift AR](https://trtc.io/document/70595?product=beautyar&menulabel=core%20sdk&platform=android)
- License application: <https://tceffect-license.tmf.qq.com/>
- Common error codes and log extraction: see the "FAQ" sections in [Android/README_en.md](./Android/README_en.md) and [iOS/README_en.md](./iOS/README_en.md)
