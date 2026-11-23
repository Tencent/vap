<h1 align="center">
  OHOS-VAP
</h1>

<p align="center">
 <a href="./README.md">English</a> | <a href="./README_zh.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com"><img src="https://img.shields.io/badge/license-Apache%202.0-blue?style=flat-square or later-orange" alt="License"></a>
  <a><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"/></a>
</p>


在数字娱乐和在线互动的时代，视觉效果的精美程度直接影响用户体验。`OHOS-VAP` 是一个基于 `OpenHarmony` 运用 `OpenGL` 技术和特殊算法打造的强大动画粒子特效渲染组件。它不仅能够为应用程序提供令人惊叹的动画效果，更为用户创造了一种身临其境的视觉享受。

<div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
<img loading="lazy" width="200px" src='./imgs/1.gif' />
<img loading="lazy" width="200px" src='./imgs/2.gif' />
<img loading="lazy" width="200px" src='./imgs/5.gif' />
<img loading="lazy" width="200px" src='./imgs/4.gif' />
</div>

## 主要特征

- 相比Webp, Apng动图方案，具有高压缩率(素材更小)、硬件解码(解码更快)的优点.
- 相比Lottie，能实现更复杂的动画效果(比如粒子特效)
- 高性能渲染：凭借 OpenGL 的强大能力，OHOS-VAP 实现了高效的粒子特效渲染，确保流畅的用户体验，适用于各种设备。
- 易于集成：OHOS-VAP 设计简洁，易于与现有项目集成，帮助开发者快速实现酷炫的动画效果，提升应用的吸引力。
- 多平台支持：兼容多个设备，无论是手机、平板还是电脑，OHOS-VAP 都能提供一致的视觉效果，助力跨终端应用开发。

## 应用场景

- 直播间特效：在各大短视频平台中如抖音，快手，得物，企鹅电竞，利用 OHOS-VAP 为直播间增添炫酷的礼物特效，提升观众的互动体验，增加直播的趣味性。
- 电商活动推广：在游戏领域及电商平台的活动中，使用 OHOS-VAP 实现令人惊叹的产品展示效果，吸引用户眼球，推动销售转化。
- 游戏体验提升：为游戏场景增添粒子特效，提升整体游戏体验，让玩家沉浸在更为生动的虚拟世界中。
  ![apps](./imgs/icon.png)

## 构建依赖

- IDE版本：DevEco Studio 5.0.1.403
- SDK版本：ohos_sdk_public 5.0.0 (API Version 12 Release)
- 对于开发人员可以调用`this.xComponentContext.play()`接口来实现自定义视频传参路径（支持网路URL）

### C/C++层目录结构

```
├─include				# 遮罩 融合 渲染器 工具类头文件存放
│  ├─mask
│  ├─mix
│  ├─render
│  └─util
├─manager 				# xcomponent 生命周期管理
├─mask 					# 遮罩的实现
├─mix 					# 融合实现
├─napi					# Napi 层功能的封装
├─render				# 渲染器的实现
├─types   				# 接口声明
│  └─libvap	# so文件接口声明
└─util					# 工具类的实现0
```
## 源码下载
1. 本项目依赖 json 库，通过`git submodule`引入，下载代码时需加上`--recursive`参数。
```shell
git clone --recursive https://gitcode.com/openharmony-tpc/openharmony_tpc_samples.git
```
2. 开始编译项目。

## 快速使用
1. api模式 可参考示例代码 [api模式](./示例代码.ets)
2. 组件模式 可参考示例代码 [组件模式](./组件模式.ets),使用更便捷


### 头文件引入

在使用文件中进行头文件的引入

```typescript
import { VAPPlayer,MixData } from '@ohos/vap';
```

### 定义 VAPPlayer 组件

```typescript
private vapPlayer: VAPPlayer | undefined = undefined;
@State buttonEnabled: boolean = true; // 该状态为控制按钮是否可以点击
@State src: string = "/storage/Users/currentUser/Documents/1.mp4"; // 该路径可为网络路径
```

### 配置网络资源下载路径
```typescript
// 具体使用可参考示例代码
// 获取沙箱路径
let context : Context = getContext(this) as Context
let dir = context.filesDir
```
### 界面

```typescript
private xComponentId: string = 'xcomponentId_' + util.generateRandomUUID()
XComponent({
  id: this.xComponentId, // 唯一标识
  type: 'surface',
  libraryname: 'vap'
})
  .onLoad((xComponentContext?: object | Record<string, () => void>) => {
    if (xComponentContext) {
      this.vapPlayer = new VAPPlayer(this.xComponentId)
      this.vapPlayer.setContext(xComponentContext)
      this.vapPlayer.sandDir = dir // 设置存储路径
    }
  })
  .backgroundColor(Color.Transparent)
  .height('100%')
  .visibility(this.buttonEnabled ? Visibility.Hidden: Visibility.Visible)
  .width('80%')
```
### 设置视频对齐方式

  通过`setFitType`这个接口设置视频对齐方式（支持FIT_XY,FIT_CENTER,CENTER_CROP）
![](./imgs/crop.png)

  **接口需要在`play`之前使用**

```typescript
this.vapPlayer?.setFitType(fitType)
```

### 使用

#### 播放接口 Play 的使用
融合动画信息顺序自定义，需要指定 `tag`, `tag` 为视频制作时指定，该信息可通过`this.vapPlayer.getVideoInfo(uri)`
当融合信息为字体时，可配置字体的对齐，颜色，大小
```typescript
let opts: Array<MixData> = [{
  tag: 'sImg1',
  imgUri: getContext(this).filesDir + '/head1.png'
}, {
  tag: 'abc',
  txt: "星河Harmony NEXT",
  imgUri: getContext(this).filesDir + '/head1.png'
}, {
  tag: 'sTxt1',
  txt: "星河Harmony NEXT",
  textAlign: this.textAlign,
  fontWeight: this.fontWeight,
  color: this.color
}];
this.buttonEnabled = false;

this.vapPlayer?.play(getContext(this).filesDir + "/vapx.mp4", opts, () => {
  this.buttonEnabled = true;
});
```

#### 暂停的使用

```typescript
this.vapPlayer?.pause()
```

#### 停止的使用

```typescript
this.vapPlayer?.stop()
```

#### 监听手势

- 在动画播放过程中点击播放区域，如果点击到融合动画资源，回调会返回该资源（字符串）
- **接口需要在`play`之前使用**
```typescript
this.vapPlayer?.on('click', (state)=>{
  if(state) {
    console.log('js get onClick: ' + state)
  }
})
```

#### 监听播放生命周期变化
**接口需要在`play`之前使用**
```typescript
this.vapPlayer?.on('stateChange', (state, ret)=>{
  if(state) {
    console.log('js get on: ' + state)
    if(ret)
      console.log('js get on frame: ' + JSON.stringify(ret))
  }
})
```

- 回调参数 `state` 反应当前播放的状态
```typescript
enum VapState {
  UNKNOWN,
  READY,
  START,
  RENDER,
  COMPLETE,
  DESTROY,
  FAILED
}
```
- 参数 `ret` ，当 `state` 为 `RENDER` 或 `START` 返回 `AnimConfig` 对象
- 参数 `ret` ，当 `state` 为 `FAILED` 反应当前的错误码
- 参数 `ret` ，其余状态为 `undefined`

#### 应用退出后台

```typescript
  onPageHide(): void {
    console.log('[LIFECYCLE-Page] onPageHide');
    this.vapPlayer?.stop()
  }
```
可在页面的生命周期中调用`onPageHide`方法

#### 兼容老视频（alphaplayer 对称的视频）
```typescript
this.vapPlayer?.setVideoMode(VideoMode.VIDEO_MODE_SPLIT_HORIZONTAL)
```
对于老视频推荐调用这个接口，**接口需要在`play`之前使用**

### **约束与限制**
在下述版本通过
- DevEco Studio 5.0(5.0.3.810), SDK: API12(5.0.0.60)

### **权限设置**

* **如果确定视频文件在沙箱中则不必配置**
* 在应用模块的`module.json5`中添加权限， 例如：`entry\src\main\module.json5`
* `READ_MEDIA` 读取用户目录下的文件（比如 文档）； `WRITE_MEDIA`（下载到用户目录下）；`INTERNET` 下载网络文件

```json
"requestPermissions": [
{
"name": 'ohos.permission.READ_MEDIA',
"reason": '$string:read_file',
"usedScene": {
"abilities": [
"EntryAbility"
],
"when": "always"
}
},
{
"name": 'ohos.permission.WRITE_MEDIA',
"reason": '$string:read_file',
"usedScene": {
"abilities": [
"EntryAbility"
],
"when": "always"
}
},
{
"name": "ohos.permission.INTERNET"
}
]
```

## 编译构建

- 工程创建成功后，构建请运行 `Build -> Build Hap(s)/APP(s) -> build App(s) `选项
- `/entry/build/default/outputs` 生成 `hap` 包
- 签名安装生成的 `hap` 包

## 测试demo

点击 `Play` 按钮，测试动画效果，再次点击进入循环播放
