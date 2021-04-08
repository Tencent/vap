# iOS VAP 


## 简介
VAP是企鹅电竞实现大礼物特效的高性能组件，基于H.264硬解码实现动画渲染，解决了透明通道的问题，同时支持更加灵活的附加元素融合能力。

### 一）快速集成
##### --以下四种方式任选一种即可
1. 源码集成
    - 直接拷贝iOS/QGVAPlayer/QGVAPlayer/下的Classes和Shaders文件夹到工程即可

2. 使用framework
    - 打开iOS/QGVAPlayer/QGVAPlayer.xcodeproj,编译出包后引入工程。（注意编译的架构）

3. 子工程集成
    - demo即子工程集成，iOS/QGVAPlayerDemo/QGVAPlayerDemo.xcodeproj可查看demo项目配置
    1）拷贝iOS/QGVAPlayer到合适位置，将QGVAPlayer.xcodeproj拖到工程内
    2）target->build setting中设置Header Search Paths。
    3）target->general添加embedded  bianries
    4) target->build phases中添加Target Dependecies, Link Binary with Libraries
    5) 完成

4. pods集成
    1）podfile中添加：pod 'QGVAPlayer', :git => '远程库地址', :tag => '1.0.4'
    2）在工程中合适的位置add file，将Shaders下的metal文件添加进去，⚠️⚠️注意不要拷贝（如果不添加引用的话会导致metal着色器不被编译进default.mtllib）！

### 二）组件使用
    - 组件对外的接口是基于UIView的category实现的，因此理论上任意view可以播放特效 
    
```
    1)通用接口(具体参考demo中 - (void)playMP4;的实现)

    NSString *resPath = @"xxx";//mp4文件路径
    [mp4View playHWDMp4:resPath];//在view上播放该特效，按该view的大小进行渲染
``` 

```
    2)代理回调

    - (void)viewDidStartPlayMP4:(VAPView *)container {
    }

    - (void)viewDidFinishPlayMP4:(NSInteger)totalFrameCount view:(UIView *)container {
        //note:在子线程被调用
    }
 
    - (void)viewDidPlayMP4AtFrame:(QGMP4AnimatedImageFrame *)frame view:(UIView *)container {
        //note:在子线程被调用
    }

    - (void)viewDidStopPlayMP4:(NSInteger)lastFrameIndex view:(UIView *)container {
        //note:在子线程被调用
        dispatch_async(dispatch_get_main_queue(), ^{
            //do something
        });
    }

    - (BOOL)shouldStartPlayMP4:(VAPView *)container config:(QGVAPConfigModel *)config {
        return YES;
    }

    - (void)viewDidFailPlayMP4:(NSError *)error {
        NSLog(@"%@", error.userInfo);
    }
```

```
    3)手势识别

    [mp4View addVapTapGesture:^(UIGestureRecognizer *gestureRecognizer, BOOL insideSource, QGVAPSourceDisplayItem *source) {
        NSLog(@"click");
    }];
    [mp4View addVapGesture:[UILongPressGestureRecognizer new] callback:^(UIGestureRecognizer *gestureRecognizer, BOOL insideSource, QGVAPSourceDisplayItem *source) {
        NSLog(@"long press");
    }];
```

```
    4) contentMode 支持
//note: 导入 QGVAPWrapView.h 头文件。通过创建 `QGVAPWrapView` 作为播放特效的 View。可以设置其`contentMode`属性。
QGVAPWrapView *wrapView = [[QGVAPWrapView alloc] initWithFrame:self.view.bounds];
wrapView.contentMode = QGVAPWrapViewContentModeAspectFit;
[self.view addSubview:wrapView];
```
