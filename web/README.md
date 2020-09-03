# Web VAP 


## 简介
VAP是企鹅电竞官网实现融合礼物特效的组件，将图片/文字与原始mp4视频融合在一起，支持透明度


### 一、使用 🔧

1、引入
``` bash
# 引入web/vap下的组件
import Vap from 'vap'
```

2、创建实例
``` bash
# init
let vap = new Vap(options)
```

3、实例方法
``` bash
# 实例方法
1、on(): 绑定h5 video事件  如on('playering', function() {// do some thing})
2、destroy()：销毁实例，清除video、canvas等
```

4、实例参数

参数名 | 含义
---- | --- 
container | dom容器
src |  mp4视频地址
config | 配置json对象（详情见下文）
width | 宽度
height | 高度
fps | 动画播放帧数（可用：15、20、30、60）
ext（无固定名） | 融合参数（和json配置文件中保持一致）

### 二、素材
内容格式固定，使用VAP素材生成工具生成

### 三、实现原理

使用webgl texture获取video和图片/文字的纹理，并在shader中进行自定义融合，




