# OHOS-VAP

---

## 简介

---

腾讯vap的OpenHarmony版本，提供高性能，炫酷视频动画播放

## 下载安装

```bash
ohpm install @ohos/vap
```

## 接口

---
| 接口           | 功能            |
|--------------|---------------|
| play         | 播放            |
| pause        | 暂停            |
| stop         | 停止            |
| on           | 监听生命周期/手势     |
| setFitType   | 设置视频对齐方式      |
| setVideoMode | 设置视频格式（兼容老视频） |
| getVideoInfo | 获取融合动画配置信息    |
 详细使用可参考  [demo工程](https://gitcode.com/openharmony-tpc/openharmony_tpc_samples/tree/master/vap)

## 使用

---

### 头文件引入

在应用文件中添加头文件

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
XComponent({
  id: 'xcomponentId', // 唯一标识
  type: 'surface',
  libraryname: 'vap'
})
  .onLoad((xComponentContext?: object | Record<string, () => void>) => {
    if (xComponentContext) {
      this.vapPlayer = new VAPPlayer
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

## 兼容老视频（alphaplayer 对称的视频）
```typescript
this.vapPlayer?.setVideoMode(VideoMode.VIDEO_MODE_SPLIT_HORIZONTAL)
```
对于老视频推荐调用这个接口，**接口需要在`play`之前使用**

## 约束与限制

---

在下述版本通过
- DevEco Studio 5.0(5.0.3.810), SDK: API12(5.0.0.60)

## 权限设置

---

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
