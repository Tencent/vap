## iOS 1.0.19

**bugfix**

- 修复mp4解析length为0异常。

## iOS 1.0.18

**bugfix**

- 修复部分渲染宏与GPUImage冲突。

## iOS 1.0.17

**bugfix**

- 修复mp4解析length异常。

## iOS 1.0.16

**bugfix**

- MTLRenderCommandEncoder释放前需要调用endEncoding方法。
- 修改QGMP4FrameHWDecoder在解码停止调用onInputEnd为_onInputEnd，即将停止任务立即执行，避免在低端机上解码性能太差，停止任务未及时执行导致finishFrameIndex设置有误陷入渲染死循环。

## iOS 1.0.15

**bugfix**

- 修改SRGB格式的图像渲染后颜色变深[#issue124](https://github.com/Tencent/vap/issues/124)

**feature**

- UIView(VAP)及QGVAPWrapView 增加setMute接口，设置是否静音播放素材，注：在播放开始时进行设置，播放过程中设置无效，循环播放则设置后的下一次播放开始生效

## iOS 1.0.14

**bugfix**

- 修改vap 取默认帧率的逻辑，添加从vapc box获取帧率操作，若vapc box取到帧率为0，则继续沿用旧有的逻辑，即利用帧数与时长计算帧率
- 修复MP4Parser解析box长度逻辑不完成导致解析box异常，无法播放素材问题[#issue133](https://github.com/Tencent/vap/issues/133)
- UIView(VAP) 增加enableOldVersion接口，若素材非vap工具制作（不包含vapc box），则必须在播放前调用此接口设置enable，才可播放


## iOS 1.0.13

**feature**

- 暂停时音频播放跟随暂停

**bugfix**

- 修复AVAudioPlayer被释放后可能导致野指针crash的问题




## iOS 1.0.12

**bugfix**

- 修复暂停时CPU上升的问题（在退后台的场景下会导致CPU上涨约1s然后下降，形成一个尖刺）



## iOS 1.0.11

**feature**

- UIView(VAP) 新增 hwd_enterBackgroundOP，退后台时可以控制是暂停/结束行为[#issue102](https://github.com/Tencent/vap/issues/102)
- QGVAPWrapView 补齐 stop/pause/resume功能，并修改了方法的命名



## iOS 1.0.10

**bugfix**

- 解决退后台后回复可能出现花屏的问题



## iOS 1.0.9

**feature**

- 添加VTSession失效时的重建逻辑（Seek关键帧，解码并丢弃，直到当前帧）
- 将VAP默认行为由退后台时结束播放改为退后台时暂停，进入前台时恢复
