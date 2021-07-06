# VAP


[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://opensource.org/licenses/MIT)

VAP(Video Animation Player) is a fantastic animation player. It can play video with alpha channel.

* Compared with Webp or Apng animation, it has the advantages of high compression rate (smaller material) and hardware decoding.


* Compared with Lottie, it can achieve more complex animation effects (such as particle effects)


More detail: [Introduction.md](./Introduction.md)


Demo show：

[Web demo](https://egame.qq.com/vap)

![](./images/anim1.gif)

And VAP can also merge custom attributes (such as user name, avatar) into the animation.

![](./images/anim2.gif)



## Performance


-|file size|decoder|effects support
---|---|---|---
Lottie|can't generate|software decoder|not support particle effects
GIF|4.6M|software decoder|only support 8 bit color format
Apng|10.6M|software decoder|all support
Webp|9.2M|software decoder|all support
mp4|1.5M|hardware decoder|not support alpha channel
VAP|***1.5M***|***hardware decoder***|***all support***


More detail: [Introduction.md](./Introduction.md)


## Platform support

Platform：[Android](./Android), [iOS](./iOS), [web](./web). 

Generation tool：[VapTool](./tool)

Preview tool：[Mac](https://github.com/Tencent/vap/releases/download/VapPreview0.1.0/vap-player-0.1.0.dmg), [Windows](https://github.com/Tencent/vap/releases/download/VapPreview0.1.0/vap-player_0.1.0.exe)


## Issue

If you have some problems with VAP, you can post issues. Developer will check often.

## FAQ

[FAQ](https://github.com/Tencent/vap/wiki/FAQ)

## License

VAP is under the MIT license. See the [LICENSE](./LICENSE.txt) file for details.
