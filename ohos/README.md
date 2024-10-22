<h1 align="center">
  OHOS-VAP
</h1>

<p align="center">
 <a href="./README.md">English</a> | <a href="docs/README.es.md">Spanish</a> | <a href="docs/README.de.md">German</a> | 
<a href="docs/README.fr.md">French</a> | <a href="./README_zh.md">简体中文</a> |  <a href="docs/README.ja.md">日本語</a> 
</p>

<p align="center">
  <a href="https://github.com"><img src="https://img.shields.io/badge/LICENSE-LGPLv2.1 or later-orange" alt="License"></a>
  <a><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"/></a>
</p>

In the era of digital entertainment and online interaction, the quality of visual effects directly impacts user experience. `OHOS-VAP` is a powerful animation particle effect rendering component built on `OpenHarmony`, utilizing `OpenGL` technology and special algorithms. It not only provides stunning animation effects for applications but also creates an immersive visual experience for users.

<div style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
<img loading="lazy" width="150px" src='./imgs/1.gif' />
<img loading="lazy" width="150px" src='./imgs/3.gif' />
<img loading="lazy" width="150px" src='./imgs/4.gif' />
<img loading="lazy" width="150px" src='./imgs/5.gif' />
</div>

### Key Features

- Compared to Webp and Apng animated image formats, it offers advantages such as higher compression rates (smaller file sizes) and hardware decoding (faster decoding).
- Compared to Lottie, it can achieve more complex animation effects (such as particle effects).
- High-performance rendering: With the powerful capabilities of OpenGL, OHOS-VAP achieves efficient particle effect rendering, ensuring a smooth user experience across various devices.
- Easy integration: OHOS-VAP features a simple design that allows for easy integration with existing projects, helping developers quickly implement stunning animation effects and enhance the appeal of their applications.
- Multi-platform support: Compatible with multiple devices, whether it's a smartphone, tablet, or computer, OHOS-VAP can provide consistent visual effects, aiding cross-terminal application development.

### Application Scenarios

- Live Room Effects: On major short video platforms such as Douyin, Kuaishou, Dewu, and Penguin Esports, use OHOS-VAP to add cool gift effects to live rooms, enhancing audience interaction and increasing the fun of live broadcasts.
- E-commerce Promotion: In the gaming sector and on e-commerce platforms, use OHOS-VAP to create stunning product display effects that attract user attention and drive sales conversions.
- Enhanced Gaming Experience: Add particle effects to game scenes, improving the overall gaming experience and immersing players in a more vivid virtual world.
  ![apps](./imgs/icon.png)

### Build Dependencies

- IDE Version: DevEco Studio 5.0.1.403
- SDK Version: ohos_sdk_public 5.0.0 (API Version 12 Release)
- Store a video file named `1.mp4` in the specified path on the terminal device: `/storage/Users/currentUser/Documents` (**demo video is stored in the `video_demo` directory at the root**).
- Developers can call the `this.xComponentContext.play()` interface to implement custom video parameter paths (supports network URLs).

#### C/C++ Layer Directory Structure

```
├─include				# Header files for masks, mixing, renderers, and utility classes
│  ├─mask
│  ├─mix
│  ├─render
│  └─util
├─manager 				# xcomponent lifecycle management
├─mask 					# Implementation of masks
├─mix 					# Implementation of mixing
├─napi					# Napi layer functionality encapsulation
├─render				# Implementation of renderers
├─types   				# Interface declarations
│  └─libvap	# Interface declarations for so files
└─util					# Implementation of utility classes
```

### Building the Project to Generate a Har Package

To start the project, first run the command to generate a Har package as shown below.

#### Run the following command in the IDE's Terminal

```bash
hvigorw assembleHar --mode module -p module=vap_module@default -p product=default -p buildMode=release --no-daemon
```

This will generate a Har package in the directory `.\vap_module\build\default\outputs\default\vap_module.har`.

### Starting the Project

For testers, the project can be quickly started by connecting the device in the IDE and clicking a button to launch it.

Follow the official process to add signature information to correctly install the test application on the terminal device.

### Reference Steps

For developers, the generated Har package can be imported into other projects.

#### Run the following command in the IDE's Terminal

```bash
ohpm install .\vap_module\build\default\outputs\default\vap_module.har
```
Install the previously generated Har package.

### Quick Start
- Refer to the example code `.\示例代码.ets`, and note that the example needs to have internet access to run correctly the first time.

#### Importing Header Files

In the usage file, import the header files as follows:

```typescript
import { VAPPlayer } from 'vap_module';
import { MixInputData } from 'vap_module';
```

#### Defining the VAPPlayer Component

```typescript
private vapPlayer: VAPPlayer | undefined = undefined;
@State buttonEnabled: boolean = true; // This state controls whether the button can be clicked
@State src: string = "/storage/Users/currentUser/Documents/1.mp4"; // This path can be a network path
```

#### Mixing Interface Declaration

```typescript
class MixInputDataBean implements MixInputData {
  constructor(txt?: string, imgUri?: string) {
    this.txt = txt || '';
    this.imgUri = imgUri || '';
  }

  txt: string;
  imgUri: string;
}
```

#### Configuring the Network Resource Download Path

```typescript
// For specific usage, refer to the example code
// Get the sandbox path
let context: Context = getContext(this) as Context;
let dir = context.filesDir;
```

#### Interface

```typescript
XComponent({
  id: 'xcomponentId', // Unique identifier
  type: 'surface',
  libraryname: 'vap'
})
  .onLoad((xComponentContext?: object | Record<string, () => void>) => {
    if (xComponentContext) {
      this.vapPlayer = new VAPPlayer();
      this.vapPlayer.setContext(xComponentContext);
      this.vapPlayer.sandDir = dir; // Set storage path
    }
  })
  .backgroundColor(Color.Transparent)
  .height('100%')
  .visibility(this.buttonEnabled ? Visibility.Hidden : Visibility.Visible)
  .width('80%');
```

#### Calling Interfaces (e.g., Button Click Events)

```typescript
this.vapPlayer?.play(this.src, opts, () => {
  this.buttonEnabled = true;
});
```

#### Usage

##### Using the Play Interface

```typescript
let opts: Array<MixInputDataBean> = new Array();
let opt: MixInputDataBean = new MixInputDataBean();
opt.txt = "星河Harmony NEXT";
opt.imgUri = "/storage/Users/currentUser/Documents/1.png"; // Ensure there is a 1.png resource in the documents directory
opts.push(opt);
opts.push(opt);
opts.push(opt);
this.buttonEnabled = false;
this.vapPlayer?.play("/storage/Users/currentUser/Documents/1.mp4", opts, () => {
  this.buttonEnabled = true;
});
```

##### Using Pause

```typescript
this.vapPlayer?.pause();
```

##### Using Stop

```typescript
this.vapPlayer?.stop();
```

##### Listening for Gestures

- During animation playback, if the play area is clicked and a mixed animation resource is clicked, the callback will return that resource (as a string).
```typescript
this.vapPlayer?.on('click', (state) => {
  if (state) {
    console.log('js get onClick: ' + state);
  }
});
```

##### Listening for Playback Lifecycle Changes

```typescript
this.vapPlayer?.on('stateChange', (state, ret) => {
  if (state) {
    console.log('js get on: ' + state);
    if (ret) {
      console.log('js get on frame: ' + JSON.stringify(ret));
    }
  }
});
```

- The callback parameter `state` reflects the current playback status.
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
- Parameter `ret`: When `state` is `RENDER` or `START`, it returns an `AnimConfig` object.
- Parameter `ret`: When `state` is `FAILED`, it reflects the current error code.
- Parameter `ret`: For other states, it will be `undefined`.

```typescript
onPageHide(): void {
  console.log('[LIFECYCLE-Page] onPageHide');
  this.vapPlayer?.stop();
}
```
You can call the onPageHide method in the page lifecycle

#### **Permission Settings**

**Note on Permission Settings**

Permissions need to be added in the application's module `module.json5`, for example: `entry\src\main\module.json5`.

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

### Compilation and Build

- After successfully creating the project, to build, run `Build -> Build Hap(s)/APP(s) -> build App(s)` option.
- The `hap` package will be generated in `/entry/build/default/outputs`.
- Sign and install the generated `hap` package.

### Test Demo

Click the `Play` button to test the animation effect, and click again to enter loop playback.