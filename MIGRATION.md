# 升级指南：开源 VAP → 礼物动画特效 Vap Pro SDK

本指南面向已接入开源 VAP 的团队，目标是**低成本**升级到腾讯云官方版本 **礼物动画特效 Vap Pro SDK**。

接口级对照请见 [API_MIGRATION.md](./docs/API_MIGRATION.md)。

---

## 0. 迁移前须知

| 项 | 说明 |
| --- | --- |
| 开源仓库状态 | 开源 VAP 已升级为腾讯云视立方·礼物动画特效 Vap Pro SDK；MIT 协议有效，开源代码可继续使用 |
| 素材兼容性 | VAP 的 mp4 + `vapc` 配置 BOX 协议延续，**历史素材可直接播放** |
| 素材工具 | `tool/`（VapTool）继续可用，产出的素材可直接被 礼物动画特效 Vap Pro SDK 播放 |
| License | 礼物动画特效 Vap Pro SDK **必须申请并注册 License 后才能播放**（免费、永久有效）；未授权会报 `-10009` |
| 平台 | 礼物动画特效 Vap Pro SDK 当前提供 Android / iOS |
| 能力边界 | 礼物动画特效 Vap Pro SDK 仅补齐基础可用性；加密、软硬解自动切换、后台播放等属于[企业版能力](https://cloud.tencent.com/document/product/616/116459) |

## 1. 申请 License（必做，第一步）

1. 打开 [License 申请页](https://tceffect-license.tmf.qq.com/)；
2. 填写应用信息（Android 包名 / iOS Bundle ID 需与最终上架应用一致）；
3. 提交后获得一段 **永久有效** 的 License 字符串，妥善保存。

> License 与包名 / Bundle ID 绑定，包名不一致会触发 `LicenseV2PackageNotMatch(-5)` 或 `-100202`。

## 2. 下载并集成 SDK

| 平台 | 下载 | 集成文档 |
| ---- | ---- | -------- |
| Android | [MediaX_Android_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_Android_Vap_Pro_SDK_Latest.zip) | [Android/README.md](./Android/README.md) |
| iOS | [MediaX_iOS_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_iOS_Vap_Pro_SDK_Latest.zip) | [iOS/README.md](./iOS/README.md) |

Android 需同时引入 `TCEffectPlayer_vap_pro_x.x.x`、`TCMediaX_x.x.x`、`xmagic-auth_x.x.x`（**三者版本号必须一致**）；
iOS 需引入 `TCMediaX.xcframework`、`TCEffectPlayer.xcframework`、`YTCommonXMagic.framework`，并设置 `Other Linker Flags: -ObjC`。

## 3. VAP 升级到 Vap Pro SDK

请参考详细的 [API 升级对照教程](./docs/API_MIGRATION.md)。

## 4. Web 端说明

礼物动画特效官方当前**仅提供 Android / iOS**，无 Web 版 Vap Pro。Web 端建议：

- 继续使用本仓库 [web/](./web) 的社区版代码（MIT，可自由使用）；
- Web 端商业化动画特效需求，请通过 [腾讯云官方渠道](https://cloud.tencent.com/document/product/616/116459) 咨询。

## 5. 迁移验收清单

- [ ] License 申请成功，且包名 / Bundle ID 与上线应用一致
- [ ] Android：三个 aar 版本一致，abiFilters 已配置，混淆规则已添加
- [ ] iOS：三个 framework 已引入，系统库已添加，`-ObjC` 已设置
- [ ] License 初始化在播放前完成，`setLicense` 回调 `errCode = 0`
- [ ] 历史素材（mp4 + vapc）可正常播放
- [ ] 融合动画（图片 / 文字）替换结果正确
- [ ] 播放状态回调与错误处理接入完成（含错误码兜底）
- [ ] 低端机 / 老旧机型抽样验证通过
- [ ] 日志开关与上传策略确认（`TCMediaXBase#setLogEnable`）

## 6. 升级到企业版

若存在以下需求，强烈建议升级 [腾讯云视立方·礼物动画特效 企业版 SDK](https://cloud.tencent.com/document/product/616/116459)：

| 需求 | 礼物动画特效 Vap Pro SDK | 礼物动画特效 企业版 SDK |
| ---- | ----------------- | ------ |
| 素材 / 动画文件加密（防盗版、防篡改） | 不提供 | 完整支持 |
| 后台播放 | 不提供 | 完整支持 |
| 软硬解自动切换（失败降级） | 不提供 | 完整支持 |
| Mac 模拟器架构支持 | 不提供 | 完整支持 |
| 官方素材工具链与技术支持 SLA | 不提供 | 完整技术支持与服务 |

## 7. 获取帮助

- 官方文档：[腾讯云视立方·礼物动画特效](https://cloud.tencent.com/document/product/616/116459)
- License 申请：<https://tceffect-license.tmf.qq.com/>
- 常见错误码与日志提取：见 [Android/README.md](./Android/README.md)、[iOS/README.md](./iOS/README.md)「常见问题」章节
