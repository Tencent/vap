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


In the era of digital entertainment and online interaction, the quality of visual effects directly impacts user experience. `OHOS-VAP` is a powerful animation particle effect rendering component built on `OpenHarmony` using `OpenGL` technology and specialized algorithms. Not only does it provide stunning animation effects for applications, but it also creates an immersive visual experience for users.

<div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
<img loading="lazy" width="200px" src='./imgs/1.gif' />
<img loading="lazy" width="200px" src='./imgs/2.gif' />
<img loading="lazy" width="200px" src='./imgs/5.gif' />
<img loading="lazy" width="200px" src='./imgs/4.gif' />
</div>

## Key Features

- Compared to Webp and Apng animation schemes, it offers high compression rates (smaller assets) and hardware decoding (faster decoding) advantages.
- Compared to Lottie, it can achieve more complex animation effects (like particle effects).
- High-performance rendering: With the powerful capabilities of OpenGL, OHOS-VAP achieves efficient particle effect rendering, ensuring a smooth user experience across various devices.
- Easy integration: OHOS-VAP has a simple design, making it easy to integrate with existing projects, helping developers quickly implement stunning animation effects and enhance application appeal.
- Multi-platform support: Compatible with multiple devices, whether on phones, tablets, or computers, OHOS-VAP can provide consistent visual effects, facilitating cross-terminal application development.

## Application Scenarios

- Live broadcast effects: On major short video platforms such as Douyin, Kuaishou, and others, use OHOS-VAP to add cool gift effects to live broadcasts, enhancing audience interaction and increasing the fun of the broadcast.
- E-commerce promotional activities: In gaming and e-commerce platform events, use OHOS-VAP to achieve stunning product display effects, attract users' attention, and drive sales conversions.
- Game experience enhancement: Add particle effects to game scenes to enhance overall gaming experience, immersing players in a more vivid virtual world.
  ![apps](./imgs/icon.png)

## Build Dependencies

- IDE Version: DevEco Studio 5.0.1.403
- SDK Version: ohos_sdk_public 5.0.0 (API Version 12 Release)
- Developers can call the `this.xComponentContext.play()` interface to implement custom video parameter paths (supports network URLs).

### C/C++ Layer Directory Structure

```
├─include				# Mask, Mix, Renderer, Utility class header files storage
│  ├─mask
│  ├─mix
│  ├─render
│  └─util
├─manager 				# xcomponent life cycle management
├─mask 					# Implementation of masking
├─mix 					# Implementation of mixing
├─napi					# Napi layer function encapsulation
├─render				# Implementation of the renderer
├─types   				# Interface declarations
│  └─libvap	# so file interface declarations
└─util					# Implementation of utility classes
```

## Source code download
1. This project relies on json library, which is introduced by `git submodule`, and `--recursive` parameter should be added when downloading code.
```shell
git clone --recursive https://gitcode.com/openharmony-tpc/openharmony_tpc_samples.git
```
2. Start compiling the project.

## Quick Start
1. For API mode, refer to the example code [API Mode](./示例代码.ets)
2. For component mode, refer to the example code [Component Mode](./组件模式.ets), for easier use.

### Importing Header Files

Import header files in the usage file.

```typescript
import { VAPPlayer,MixData } from '@ohos/vap';
```

### Define VAPPlayer Component

```typescript
private vapPlayer: VAPPlayer | undefined = undefined;
@State buttonEnabled: boolean = true; // This state controls whether the button can be clicked
@State src: string = "/storage/Users/currentUser/Documents/1.mp4"; // This path can be a network path
```

### Configure Network Resource Download Path
```typescript
// For specific usage, refer to the example code
// Get sandbox path
let context : Context = getContext(this) as Context
let dir = context.filesDir
```

### Interface

```typescript
private xComponentId: string = 'xcomponentId_' + util.generateRandomUUID()
XComponent({
  id: this.xComponentId, // Unique identifier
  type: 'surface',
  libraryname: 'vap'
})
  .onLoad((xComponentContext?: object | Record<string, () => void>) => {
    if (xComponentContext) {
      this.vapPlayer = new VAPPlayer(this.xComponentId)
      this.vapPlayer.setContext(xComponentContext)
      this.vapPlayer.sandDir = dir // Set storage path
    }
  })
  .backgroundColor(Color.Transparent)
  .height('100%')
  .visibility(this.buttonEnabled ? Visibility.Hidden: Visibility.Visible)
  .width('80%')
```

### Set Video Alignment Mode

  Set the video alignment mode through the `setFitType` interface (supports FIT_XY, FIT_CENTER, CENTER_CROP)
![](./imgs/crop.png)

  **This interface needs to be used before `play`.**

```typescript
this.vapPlayer?.setFitType(fitType)
```

### Usage

#### Using the Play Interface
Customizing the order of merged animation information requires specifying `tag`, which is the information specified during video creation, accessible via `this.vapPlayer.getVideoInfo(uri)`. 
When the merged information is text, you can configure the text alignment, color, and size.
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

#### Using Pause

```typescript
this.vapPlayer?.pause()
```

#### Using Stop

```typescript
this.vapPlayer?.stop()
```

#### Listening for Gestures

- During animation playback, if the clickable area is tapped and a merged animation resource is clicked, a callback will return that resource (string).
- **This interface needs to be used before `play`.**
```typescript
this.vapPlayer?.on('click', (state)=>{
  if(state) {
    console.log('js get onClick: ' + state)
  }
})
```

#### Listening for Playback Lifecycle Changes
**This interface needs to be used before `play`.**
```typescript
this.vapPlayer?.on('stateChange', (state, ret)=>{
  if(state) {
    console.log('js get on: ' + state)
    if(ret)
      console.log('js get on frame: ' + JSON.stringify(ret))
  }
})
```

- Callback parameter `state` reflects the current playback status.
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
- Parameter `ret`, when `state` is `RENDER` or `START`, returns the `AnimConfig` object.
- Parameter `ret`, when `state` is `FAILED`, reflects the current error code.
- Parameter `ret`, other statuses will be `undefined`.

#### Application Exit Background

```typescript
  onPageHide(): void {
    console.log('[LIFECYCLE-Page] onPageHide');
    this.vapPlayer?.stop()
  }
```
You can call the `onPageHide` method in the page lifecycle.

#### Compatibility Mode for Legacy Videos (alphaplayer symmetrical videos)
```typescript
this.vapPlayer?.setVideoMode(VideoMode.VIDEO_MODE_SPLIT_HORIZONTAL)
```
For older videos, it is recommended to call this interface. **This interface needs to be used before `play`.**

### **Constraints and Limitations**
Passes in the following versions:
- DevEco Studio 5.0(5.0.3.810), SDK: API12(5.0.0.60)

### **Permissions Setup**

* **No configuration required if the video file is confirmed to be in the sandbox.**
* Add permissions in the application module's `module.json5`, for example: `entry\src\main\module.json5`
* `READ_MEDIA` to read files in the user's directory (like documents); `WRITE_MEDIA` (to download to the user's directory); `INTERNET` to download network files.

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

## Compile Build

- After creating the project successfully, to build run `Build -> Build Hap(s)/APP(s) -> build App(s) ` option.
- The `/entry/build/default/outputs` will generate a `hap` package.
- Sign and install the generated `hap` package.

## Test Demo

Click the `Play` button to test animation effects, and click again to enter loop playback.
