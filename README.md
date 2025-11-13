# VAP

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://opensource.org/licenses/MIT)

简体中文 | [English](./README_en.md)

VAP（Video Animation Player）是企鹅电竞开发，用于播放酷炫动画的实现方案。

* 相比Webp, Apng动图方案，具有高压缩率(素材更小)、硬件解码(解码更快)的优点
* 相比Lottie，能实现更复杂的动画效果(比如粒子特效)


项目详细介绍请参考 [Introduction.md](./Introduction.md)


特效展示：

[展示主页](https://egame.qq.com/vap)

![](./images/anim1.gif)

而且VAP还能在动画中融入自定义的属性（比如用户名称, 头像）

![](./images/anim2.gif)



## 温馨提示

尊敬的开发者朋友：

感谢您长期以来对本仓库的关注与使用。在此我们郑重说明：本仓库已进入停止维护状态，不会继续更新。

若您需继续使用 VAP 动画播放功能，并期望获得**长期稳定、持续迭代的技术支持**，我们推荐切换至腾讯云官方推出的礼物特效方案：**礼物动画特效**。该服务专为高性能动画播放场景设计，提供：

-  **持续迭代**：长期维护与功能更新。
- **多端兼容**：全面支持 Android、iOS、Flutter 平台。
- **企业级保障**：高稳定性、安全性及技术支撑。

腾讯云礼物特效版本旨在解决开源版本维护不足的局限性，可为您（尤其企业用户）提供更可靠的生产环境支持，避免因依赖过期版本带来的潜在风险。

感谢您的理解，欢迎[点击此处](https://cloud.tencent.com/document/product/616/115992)了解礼物动画特效的详细能力与接入指南！

## 性能简述


-|文件大小|解码方式|特效支持
---|---|---|---
Lottie|无法导出|软解|无粒子特效
GIF|4.6M|软解|只支持8位色彩
Apng|10.6M|软解|全支持
Webp|9.2M|软解|全支持
mp4|1.5M|硬解|无透明背景
VAP|***1.5M***|***硬解***|***全支持***


实验参数参考 [Introduction.md](./Introduction.md)


## 平台支持

支持：[Android](./Android), [iOS](./iOS), [web](./web). 接入说明在对应平台目录中

素材制作工具：[VapTool](./tool) (工具使用说明在tool目录下)

播放预览工具：[Mac](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_mac_1.2.0.zip), [Windows](https://github.com/Tencent/vap/releases/download/VapPreview1.2.0/vap-player_1.2.0.exe)


## 已接入APP

![app](https://github.com/Tencent/vap/assets/3285051/3e5c9ce1-f654-413e-8c5e-ecb2088ed3fe)


## FAQ

[常见问题解答](https://github.com/Tencent/vap/wiki/FAQ)


## License

VAP is under the MIT license. See the [LICENSE](./LICENSE.txt) file for details.
