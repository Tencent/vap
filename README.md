# 腾讯云视立方·礼物动画特效 Vap Pro SDK

简体中文 | [English](./README_en.md)

本仓库的开源 VAP 已升级为腾讯云官方 **礼物动画特效 Vap Pro SDK**（Android / iOS，需免费 [申请 License](https://tceffect-license.tmf.qq.com/)）和 **[礼物动画特效 企业版 SDK](https://cloud.tencent.com/document/product/616/116459)**。

开源代码与 MIT 协议保持有效，已接入方可继续使用，[点击查看](https://github.com/Tencent/vap/tree/vap_open_source)旧版本 VAP；新接入与需要官方能力保障的场景，建议直接采用 Vap Pro SDK。

## Vap Pro SDK 简介

腾讯云视立方·礼物动画特效 Vap Pro SDK 是腾讯云推出的礼物动画实现和播放方案。在开源 VAP 基础上补齐基础可用性和 Bug 修复，如：Alpha 还原、机型兼容、官方维护。

### 播放效果对比

同一素材在开源 VAP 与 Vap Pro SDK 下的实机播放对比：

| 开源 VAP 播放 | 礼物动画特效 Vap Pro 播放 |
| -------- | ------------------------ |
| <img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_light.gif" alt="开源 VAP 播放" width="300" height="649"> | <img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/vap_pro_light_new.gif" alt="礼物动画特效 Vap Pro 播放" width="300" height="649"> |
| Alpha 还原精度不足：画面发灰、发暗，出现灰边与暗角 | Alpha 精确还原：色彩饱满通透，边缘干净，无灰边、无暗角 |

开源 VAP 在 Alpha 通道还原上存在精度损失，动画主体边缘容易产生灰边（Gray Edges）与色彩镶边（Color Fringing），整体观感发灰、发暗；
Vap Pro SDK 针对 Alpha 还原做了专项优化，可准确还原半透明边缘，画面色彩通透、边缘干净，显著提升礼物动画的视觉品质与观感。

> 旧 VAP（Video Animation Player）项目请参考 [Introduction.md](./Introduction.md)。
>

## 升级到 Vap Pro SDK

1. **申请 License**：打开 [License 申请页](https://tceffect-license.tmf.qq.com/)，获取永久有效的 License 字符串（免费）。
2. **下载 SDK**：Android / iOS 接入文档见 [Android](./Android) 与 [iOS](./iOS) 目录。
3. **替换播放与融合接口**：按 [MIGRATION.md](./MIGRATION.md) 操作，**历史素材与 VapTool 产出的素材可直接复用**。

## 平台支持

| 平台     | Vap Pro SDK                                                  | 企业版 SDK                                                   |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Android  | [新用户接入文档](./Android)<br />[旧用户升级文档](./MIGRATION.md) | [Android 端接入文档](https://cloud.tencent.com/document/product/616/116472) |
| iOS      | [新用户接入文档](./iOS)<br />[旧用户升级文档](./MIGRATION.md) | [iOS 端接入文档](https://cloud.tencent.com/document/product/616/116474) |
| Web / H5 | 社区版，见 [web](./web)                                      | 不提供                                                       |
| Flutter  | 不提供                                                       | [Flutter 端接入文档](https://cloud.tencent.com/document/product/616/123945) |

素材制作工具：[VapTool](./tool)（工具使用说明在 tool 目录下，**继续可用**，产出的素材可直接被 Vap Pro / 企业版播放）

播放预览工具：[Mac](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_mac_1.2.0.zip)、[Windows](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_1.2.0.exe)

## 礼物动画特效企业版 SDK - 支持素材加密、软解码播放、多动画同播



如果您有素材加密、软解码播放、多动画同播、后台播放等能力诉求，强烈建议进一步升级 **[礼物动画特效 企业版 SDK](https://cloud.tencent.com/document/product/616/116459)**。

### 礼物动画特效 企业版 SDK 播放演示

| 直播大动画播放 | 32 个头像框流畅播放 |
| -------------- | ------------------- |
| ![mp4_gift_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/mp4_gift_play.gif) | ![tcmp4_grid_play](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/tcmp4_grid_play.gif) |
| 直播间礼物大动画全屏播放，画面细腻、透明边缘干净、播放稳定流畅 | 32 路头像框小动画同屏并发播放，多路并行依然稳定流畅，无卡顿、无掉帧 |

<table>
<thead>
<tr><th>分类</th><th>能力项</th><th>礼物动画特效 Vap Pro SDK</th><th>礼物动画特效 企业版 SDK</th><th>说明</th></tr>
</thead>
<tbody>
<tr><td rowspan="2"><b>解码与播放</b></td><td>硬解码播放</td><td align="center">✅</td><td align="center">✅</td><td>使用设备硬件解码播放</td></tr>
<tr><td>软硬解自动切换（失败降级）</td><td align="center">❌</td><td align="center">✅</td><td>企业版硬解优先，运行时失败自动降级软解，提升大分辨率、低端机与复杂机型下的播放成功率</td></tr>
<tr><td><b>内容安全</b></td><td>资源 / 动画文件加密（防盗版、防篡改）</td><td align="center">❌</td><td align="center">✅</td><td>企业版资源不可二次提取，保护特效素材的内容资产</td></tr>
<tr><td><b>画质与兼容性</b></td><td>多小动画同时播放（40+ 头像框 + 1 进场大动画）</td><td align="center">⚠️</td><td align="center">✅</td><td>企业版支持大动画 VAP 搭配小动画（tcmp4）使用，性能指标优异</td></tr>
<tr><td rowspan="4"><b>播放控制</b></td><td>后台播放（切后台继续播放）</td><td align="center">❌</td><td align="center">✅</td><td>直播、语聊房等常驻场景</td></tr>
<tr><td>setLoop</td><td align="center">✅</td><td align="center">✅</td><td>循环播放</td></tr>
<tr><td>seekTo</td><td align="center">✅</td><td align="center">✅</td><td>跳转到指定位置播放</td></tr>
<tr><td>尾帧停留</td><td align="center">❌</td><td align="center">✅</td><td>播放结束保留尾帧画面</td></tr>
<tr><td rowspan="2"><b>融合动画</b></td><td>融合动画特效动态更新</td><td align="center">❌</td><td align="center">✅</td><td>支持播放过程中动态更新融合动画信息</td></tr>
<tr><td>融合文字支持字体颜色 / 大小 / 对齐自定义</td><td align="center">❌</td><td align="center">✅</td><td>支持字体颜色 / 大小 / 对齐方式自定义</td></tr>
<tr><td><b>播放性能</b></td><td>高性能播放（低端机性能 / 内存 / 耗电优化）</td><td align="center">⚠️</td><td align="center">✅</td><td>低端机性能 / 内存 / 耗电优化</td></tr>
<tr><td rowspan="3"><b>平台与服务</b></td><td>技术支持与 SLA</td><td align="center">❌</td><td align="center">✅</td><td>Vap Pro 由腾讯云专业团队维护；企业版提供工单响应 + SLA + 版本维护</td></tr>
<tr><td>业务即时对接群</td><td align="center">❌</td><td align="center">✅</td><td>企业版支持企业微信群及时对接</td></tr>
<tr><td>定向发包</td><td align="center">❌</td><td align="center">✅</td><td>修复问题，定向提供 SDK</td></tr>
<tr><td><b>格式与工具链</b></td><td>官方专业素材制作工具</td><td align="center">❌</td><td align="center">✅</td><td>Vap Pro 提供开源 VapTool；企业版提供官方专业工具链，支持多格式转换（SVGA / PAG / Lottie / WebP / PNG 序列）</td></tr>
<tr><td><b>License 授权</b></td><td>多 App 批量授权</td><td align="center">❌</td><td align="center">✅</td><td>支持批量授权，支持马甲包</td></tr>
</tbody>
</table>

图例：✅ 支持　⚠️ 部分支持（能力存在但有限制或已知缺陷）　❌ 不支持

企业版能力项以 [腾讯云视立方·礼物动画特效「功能概述」](https://cloud.tencent.com/document/product/616/116459) 为准。

> 说明：以上 GIF 经过压缩与降帧处理，实际播放效果更清晰、更流畅。
>

## 已接入 APP

![app](https://github.com/Tencent/vap/assets/3285051/3e5c9ce1-f654-413e-8c5e-ecb2088ed3fe)

## Issue 与反馈

VAP 已升级为礼物动画特效 Vap Pro SDK，问题反馈建议按以下渠道进行：

- 礼物动画特效 Vap Pro SDK 的技术讨论，可在本仓库 Issue 中进行。
- 礼物动画特效 企业版 SDK的使用问题，请通过 [腾讯客服](https://kf.qq.com/) 或 [填写工单](https://console.cloud.tencent.com/workorder/category)（登录腾讯云）与我们联系。

## License

VAP is under the MIT license. See the [LICENSE](./LICENSE.txt) file for details.

注意：本仓库的 MIT 许可仅覆盖开源 VAP 源码。**礼物动画特效 Vap Pro SDK 与企业版 SDK 为腾讯云商业产品，需 License 授权后使用，不适用 MIT 许可。**
