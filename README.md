# 腾讯云视立方·礼物动画特效 Vap Pro SDK

简体中文 | [English](./README_en.md)

**VAP 已升级为腾讯云视立方·礼物动画特效 Vap Pro SDK**
本仓库的开源 VAP 已升级为腾讯云官方版本 **[礼物动画特效 Vap Pro SDK](https://github.com/tencent/vap)**（Android / iOS，需 [申请 License](https://tceffect-license.tmf.qq.com/)，免费且永久有效）。

开源代码与 MIT 协议保持有效，已接入方可继续使用；新接入与需要官方能力保障的场景，建议直接采用 Vap Pro SDK。

商业化场景（素材加密、软解码播放、多动画同播、后台播放等）可进一步升级 **[礼物动画特效 企业版 SDK](https://cloud.tencent.com/document/product/616/116459)**。

## Vap Pro SDK 简介

腾讯云视立方·礼物动画特效 Vap Pro SDK 是腾讯云推出的礼物动画实现和播放方案。在开源 VAP 基础上补齐基础可用性和 Bug 修复，如：Alpha 还原、机型兼容、官方维护。

### 播放效果对比

同一素材在开源 VAP 与 Vap Pro SDK 下的实机播放对比：

| 开源 VAP | 礼物动画特效 Vap Pro SDK |
| -------- | ------------------------ |
| ![vap_open](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_open.gif) | ![vap_pro_sdk](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_pro_sdk.gif) |
| Alpha 还原精度不足：画面边缘发灰、发暗，出现灰边与暗角 | Alpha 精确还原：色彩饱满通透，边缘干净，无灰边、无暗角 |

开源 VAP 在 Alpha 通道还原上存在精度损失，动画主体边缘容易产生灰边（Gray Edges）与色彩镶边（Color Fringing），整体观感发灰、发暗；
Vap Pro SDK 针对 Alpha 还原做了专项优化，可准确还原半透明边缘，画面色彩通透、边缘干净，显著提升礼物动画的视觉品质与观感。

> 旧 VAP（Video Animation Player）项目请参考 [Introduction.md](./Introduction.md)。
>


## 版本选型

| 版本 | 获取方式 | 定位 |
| ---- | -------- | ---- |
| **腾讯云视立方·礼物动画特效 Vap Pro SDK** | 参考本文档接入 | 在开源 VAP 基础上补齐基础可用性和 Bug 修复，如：Alpha 还原、机型兼容、官方维护。 |
| **腾讯云视立方·礼物动画特效 企业版 SDK** | [腾讯云礼物动画特效 企业版 SDK](https://cloud.tencent.com/document/product/616/116459) | 商业级特效播放方案：素材加密、软解码播放、多动画同播、后台播放、工具链与官方专业技术服务。 |

## 礼物动画特效 企业版 SDK 优势

如果您有素材加密、软解码播放、多动画同播、后台播放等能力诉求，强烈建议进一步升级 **[礼物动画特效 企业版 SDK](https://cloud.tencent.com/document/product/616/116459)**。

### 礼物动画特效 企业版 SDK 播放演示

| 直播大动画播放 | 32 个头像框流畅播放 |
| -------------- | ------------------- |
| ![mp4_gift_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/mp4_gift_play.gif) | ![tcmp4_grid_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/tcmp4_grid_play.gif) |
| 直播间礼物大动画全屏播放，画面细腻、透明边缘干净、播放稳定流畅 | 32 路头像框小动画同屏并发播放，多路并行依然稳定流畅，无卡顿、无掉帧 |

| 分类 | 能力项 | 礼物动画特效 Vap Pro SDK | 礼物动画特效 企业版 SDK | 说明 |
| ---- | ------ | ----------- | ---------- | ---- |
| **解码与播放** | 软硬解自动切换（失败降级） | 不提供，硬解失败即失败 | 硬解优先 + 运行时失败自动降级软解 | 提升大分辨率、低端机与复杂机型下的播放成功率 |
| **内容安全** | 资源 / 动画文件加密（防盗版、防篡改） | 不提供 | 完整，资源不可二次提取 | 保护特效素材的内容资产 |
| **平台与服务** | 技术支持与 SLA | 腾讯云专业团队维护 | 工单响应 + SLA + 版本维护 | 腾讯云专业团队提供技术支持 |
| **画质与兼容性** | 多小动画同时播放（40+ 头像框 + 1 进场大动画） | 有限 | 完整 | 支持大动画 VAP 搭配小动画（tcmp4）使用，性能指标优异 |
| **播放控制** | 后台播放（切后台继续播放） | 有限 | 完整支持 | 直播、语聊房等常驻场景 |
| **格式与工具链** | 素材制作工具 | 开源 VapTool | 官方提供专业的礼物制作工具链 | 支持多格式素材转换（SVGA / PAG / Lottie / WebP / PNG 序列） |

口径说明：`完整` = 能力齐备并经过适配与验证；`有限` = 能力存在但有限制或已知缺陷；`不提供` = 版本内不具备该能力。

企业版能力项以 [腾讯云视立方·礼物动画特效「功能概述」](https://cloud.tencent.com/document/product/616/116459) 为准。

> 说明：以上 GIF 经过压缩与降帧处理，实际播放效果更清晰、更流畅。
>


## 三步升级到 Vap Pro SDK

1. **申请 License**：打开 [License 申请页](https://tceffect-license.tmf.qq.com/)，获取永久有效的 License 字符串（免费）。
2. **下载 SDK**：Android / iOS 接入文档见 [Android](./Android) 与 [iOS](./iOS) 目录。
3. **替换播放与融合接口**：按 [MIGRATION.md](./MIGRATION.md) 操作，**历史素材与 VapTool 产出的素材可直接复用**。

## 平台支持

| 平台 | Vap Pro SDK | 企业版 SDK |
| ---- | ----------- | ---------- |
| Android | [新用户接入文档](./Android)<br />[旧用户升级文档](./MIGRATION.md) | [Android 端接入文档](https://cloud.tencent.com/document/product/616/116472) |
| iOS | [新用户接入文档](./iOS)<br />[旧用户升级文档](./MIGRATION.md) | [iOS 端接入文档](https://cloud.tencent.com/document/product/616/116474) |
| Web / H5 | 社区版，见 [web](./web) | 不提供 |
| Flutter | 不提供 | [Flutter 端接入文档](https://cloud.tencent.com/document/product/616/123945) |

素材制作工具：[VapTool](./tool)（工具使用说明在 tool 目录下，**继续可用**，产出的素材可直接被 Vap Pro / 企业版播放）

播放预览工具：[Mac](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_mac_1.2.0.zip)、[Windows](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_1.2.0.exe)

## 已接入 APP

![app](https://github.com/Tencent/vap/assets/3285051/3e5c9ce1-f654-413e-8c5e-ecb2088ed3fe)

## Issue 与反馈

VAP 已升级为礼物动画特效 Vap Pro SDK，问题反馈建议按以下渠道进行：

- **礼物动画特效 Vap Pro SDK** 的技术讨论，可在本仓库 Issue 中进行。
- **礼物动画特效 企业版 SDK** 的使用问题，请通过 [腾讯客服](https://kf.qq.com/) 或 [填写工单](https://console.cloud.tencent.com/workorder/category)（登录腾讯云）与我们联系。

## License

VAP is under the MIT license. See the [LICENSE](./LICENSE.txt) file for details.

注意：本仓库的 MIT 许可仅覆盖开源 VAP 源码。**礼物动画特效 Vap Pro SDK 与企业版 SDK 为腾讯云商业产品，需 License 授权后使用，不适用 MIT 许可。**
