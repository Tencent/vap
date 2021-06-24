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
