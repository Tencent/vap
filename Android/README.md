## Android VAP

使用kotlin实现，Java代码也可以直接引用，使用样例可以参考demo


* 代码编写

AnimView 视频显示使用的view
IAnimListener 视频播放过程中的回调方法


代码样例

```kotlin
private fun init() {
    // 获取视频播放 AnimView
    animView = (AnimView) findViewById(R.id.player);
    // 开始播放动画文件
    animView.startPlay(file)
}
```

* IAnimListener 说明

ps:所有回调都在VAP工作线程中

```kotlin
interface IAnimListener {
    /**
     * 配置准备好后回调
     * @return true 继续播放 false 结束播放
     */
    fun onVideoConfigReady(config: AnimConfig): Boolean {
        return true // 默认继续播放
    }
    
    /**
     * 开始播放
     */
    fun onVideoStart()


    /**
     * 视频渲染每一帧时的回调
     * @param frameIndex 帧索引
     */
    fun onVideoRender(frameIndex: Int, config: AnimConfig?)

    /**
     * 视频播放结束(失败也会回调onComplete)
     */
    fun onVideoComplete()

    /**
     * 播放器被销毁情况下会调用onVideoDestroy
     */
    fun onVideoDestroy()

    /**
     * 失败回调
     * 一次播放时可能会调用多次，建议onFailed只做错误上报
     * @param errorType 错误类型
     * @param errorMsg 错误消息
     */
    fun onFailed(errorType: Int, errorMsg: String?)
}

```

### VAP融合动画

实现VAP融合动画，需要实现 IFetchResource 接口，如果是图片类型需要返回对应的Bitmap，如果是文字需要返回对应的String，Demo：AnimVapxDemoActivity 里有详细实现说明

```kotlin
interface IFetchResource {
    // 获取图片 (暂时不支持Bitmap.Config.ALPHA_8 主要是因为一些机型opengl兼容问题)
    fun fetchImage(resource: Resource, result:(Bitmap?) -> Unit)

    // 获取文字
    fun fetchText(resource: Resource, result:(String?) -> Unit)

    // 资源释放通知
    fun releaseResource(resources: List<Resource>)
}
```

监听Vapx动画自定义资源被点击的事件，需要注册 OnResourceClickListener 监听

```kotlin
interface OnResourceClickListener {
    // 返回被点击的资源
    fun onClick(resource: Resource)
}
```


### 引入方式

maven方式引入

```gradle
repositories {
    jcenter()
}

dependencies {
    implementation "com.egame.vap:animplayer:2.0.8"
}
```

aar引入

需要自己打包animplayer项目为aar（PlayerProj/animplayer）
