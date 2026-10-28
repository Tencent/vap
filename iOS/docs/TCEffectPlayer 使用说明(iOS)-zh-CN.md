# 腾讯云视立方·礼物动画特效  Vap Pro SDK 简介

腾讯云视立方·礼物动画特效  Vap Pro SDK （以下简称：礼物动画特效 SDK）用于播放酷炫的视频动画，常见用于直播间里显示酷炫的送礼动画。

下面是原始模板视频播放和融合后播放的动画效果展示：

| 原始模板视频                                                 | 融合后播放效果                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_temlate.gif) | ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_vapx_car.gif) |

# 集成指引

#### **手动集成**

1、下载 [MediaX_iOS_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_iOS_Vap_Pro_SDK_Latest.zip) ，下载完成后进行解压获取到 SDK 库文件。

2、使用 TCEffectPlayer 需要集成下面的 framework：

​	SDK库：

- TCMediaX.xcframework

- TCEffectPlayer.xcframework

- YTCommonXMagic.framework
  
  
  系统库：
  
- libz.tab

- libc++.tbd

- AVFoundation.framework

  

  ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/ios_build_phases_3.0_vap_pro.png)

![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/ios_project_general_3.0_vap_pro.png)

2、设置Other linker Flags 

​	在“Build Settings” - “Other linker Flags ” -设置“-ObjC”

# 申请授权 License

## 申请license

[点击打开](https://tceffect-license.tmf.qq.com/) 腾讯云视立方·礼物动画特效 VAP Pro SDK 授权申请页面，申请成功后，您将获取到一个永久授权的 License 字符串，请务必妥善保存。

## 初始化注册license

申请成功后，您将获得一段 License  字符串（已经过 base64 编码），直接传入下面的接口即可完成 License 校验。

```objc
#import <TCMediaX/TCMediaX.h>
@interface AppDelegate ()
@end
  
@implementation AppDelegate

// 使用时替换 LICENSE 为申请到的 License 字符串
static NSString *LICENSE = @"license";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[TCMediaXBase getInstance] setLicense:LICENSE callback:^(int errCode, NSString * _Nullable message) {
        NSLog(@"setLicense callback errCode:%d, message:%@", errCode, message);
    }];
    return YES;
}

@end
```

License 校验错误码：

```java
typedef NS_ENUM(NSInteger, TCMediaXLicenceCheckErrorCode) {
    TMXLicenseV2Ok                          = 0,    // 成功
    TMXLicenseV2NotSet                      = -1,   // 还没有调用过 setLicense
    TMXLicenseV2JsonError                   = -2,   // envelope 或明文 JSON 解析失败
    TMXLicenseV2DownloadError               = -3,   // 保留枚举值
    TMXLicenseV2ContentEmpty                = -4,   // 入参空
    TMXLicenseV2PackageNotMatch             = -5,   // packageName / bundleId 不匹配
    TMXLicenseV2Expired                     = -6,   // 保留枚举值
    TMXLicenseV2SignatureError              = -7,   // RSA 验签失败
    TMXLicenseV2FeatureNotSupported         = -8,   // feature 不在授权列表
    TMXLicenseV2DecodeError                 = -9,   // AES 解密失败
    TMXLicenseV2Base64Error                 = -10,  // 外层/内层 base64 解码失败
};

```

## 日志管理

可以通过调用 TCMediaXBase#setLogEnable 开启日志保存到文件，Android 端保存在 /sdcard/Android/data/packagename/files/TCMediaX 目录，iOS端保存在sandbox的Documents/TCMediaX目录，您可以根据业务需要把此目录的日志上传到业务后台，用于定位线上用户问题。

# 礼物动画特效 SDK TCEffectPlayer 使用

## 1、初始化TCEffectAnimView

```objc
- (TCEffectAnimView *)alphaAnimView {
    if (!_alphaAnimView) {
        _alphaAnimView = [[TCEffectAnimView alloc] init];
        _alphaAnimView.backgroundColor = [UIColor clearColor];
        _alphaAnimView.effectPlayerDelegate = self;
        _alphaAnimView.loop = YES;
        [_alphaAnimView setRenderMode:TCEPVPViewContentModeScaleToFill];
    }
    return _alphaAnimView;
}
```

## 2、添加alphaAnimView并布局

```objc
// 添加alphaAnimView
[self.view addSubview:self.alphaAnimView];

//布局
self.alphaAnimView.frame = self.view.bounds;
```

## 3、获取视频资源并进行播放

```objc
 [self.alphaAnimView startPlay:mp4Url];
```

## 4、融合动画配置

实现融合动画，需要实现 TCEffectAnimViewDelegate 代理方法。

#### 融合动画文字替换

- 替换文本，同时指定文本的对齐方式、颜色、是否粗体，使用 loadTextForPlayer 接口，推荐使用此接口。

- 只替换普通文本，可以使用 textContentForPlayer 接口。

``` objc
// 替换文本，同时指定文本的对齐方式、颜色、是否粗体，使用 loadTextForPlayer 接口，推荐使用此接口
- (TCEffectText *)loadTextForPlayer:(ITCEffectPlayer *)player
                            withTag:(NSString *)tag {
    if (tag != nil && [tag isEqualToString:@"name"]) {
        TCEffectText *effectText = [[TCEffectText alloc] init];
        effectText.text = @"reText";
        // TCEPTextAlignmentLeft = 0,     ///< 表示文字左对齐
        // TCEPTextAlignmentCenter = 1,   ///< 表示文字居中对齐
        // TCEPTextAlignmentRight = 2     ///< 表示文字右对齐
        effectText.alignment = TCEPTextAlignmentLeft; 
        //effectText.fontStyle = @"bold";
        //effectText.color = [UIColor blackColor];
        return effectText;;
    }
    return nil;
}

//只替换普通文本，可以使用 textContentForPlayer 接口， 此接口已经废弃，不建议使用，推荐使用loadTextForPlayer:withTag
- (NSString *)textContentForPlayer:(ITCEffectPlayer *)player
                           withTag:(NSString *)tag {
    NSDictionary *extraInfo = @{@"tag1" : @"tuiad_vap_car",
                                @"[sTxt1]" : @"最强王者就是我"};
    return extraInfo[tag];
}
```

#### 融合动画图片替换

通过获取 tag 值后返回对应的UIImage ，融合动画播放器内部不处理转换过程，需要在此方法里自行处理

```objc
- (void)loadImageForPlayer:(ITCEffectPlayer *)player
                   context:(NSDictionary *)context
                completion:(void(^)(UIImage *image,
                                    NSError *error))completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取到当前需要替换的图片对应的 tag，然后根据 tag 返回图片
        NSString *tag = context[TCEPContextSourceTypeImageIndex];   
        ...
        // 下载并缓存图片
        if (image) {
            completionBlock(image, nil);
        } else {
            completionBlock(nil, error);
        }
        }];
    });
}

```

监听动画自定义资源被点击的事件，以tag来区分不同的融合动画区域

```objc
- (void)tcePlayerTagTouchBegan:(ITCEffectPlayer *)player tag:(NSString *)tag {
    NSString *content = [NSString stringWithFormat:@"点击了:%@",tag];
    [self.view tuiad_alert:content];
}
```

## 4、开始播放

只支持播放本地视频资源， 如果您使用的网络视频资源， 先下载到本地再播放。

```objc
NSString *mp4Url = @"xxx/xxx/tuiad_vapx_cool_sss.mp4"];
[self.alphaAnimView startPlay:mp4Url];
```

### 暂停播放

```objc
[self.alphaAnimView pause];
```

### 继续播放

```objc
[self.alphaAnimView resume];
```

### 停止播放

 当不需要继续使用播放器时，需要停止播放，释放占用的资源。

```objc
[self.alphaAnimView stopPlay];
```
###  静音播放
 ```objc
 [self.alphaAnimView setMute:YES];
 ```

###  循环播放

 ```objc
 [self.alphaAnimView setLoop:YES];
 ```


# 常见问题

## 播放失败

如过在播放过程中出现下面的日志：

```xml
License checked failed! tceffect player license required!
```

请检查是否申请礼物动画特效SDK  License，并进行了初始化注册。

## 提取运行日志

默认情况下， 礼物动画特效SDK  会保存运行日志，如果测试过程中出现问题，可以提取日志反馈给腾讯云客服。

### Android 端

特效播放器的日志保存在目录： /sdcard/Android/data/${your_packagename}/files/TCMediaLog ， 日志文件按照日期命名，把 TCMediaLog 文件夹导出即可。

![image-20240806165900560](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/android_log.png)

### iOS端

特效播放器的日志保存沙箱 Documents/TCMedialog 文件夹

1、导出沙箱文件，操作： 打开XCode-> Window -> Devices and Simulators

<img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/ios_container.png" alt="image-20240806170453328" style="zoom: 50%;" />

2、提取 AppData/Documents/TCMedialog 文件夹

<img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/ios_log.png" style="zoom:50%;" />

**没有日志文件？？**

请检查是否通过 TCMediaXBase#setLogEnable 传入 false 关闭了日志，默认文件日志是开启的。


## 常见错误码

| 错误码      | 描述        |
|----------|-----------|
| -10003   | 创建线程失败 |
| -10004 | render创建失败    |
| -10005 | 配置解析失败   |
| -10006 | 文件无法读取   |
| -10007 | 动画视频编码格式是h265，在当前设备上不支持   |
| -10008 | 参数非法   |
| -10009 | license不合法   |
| -10010 | 模拟器不支持   |
| -100200 | 签名校验失败   |
| -100201 | 解密数据失败   |
| -100202 | BundleID 或者 PackageName 不一致   |
| -100203 | 资源过期   |
| -100204 | JSON字段不正确   |
| -100205 | boxType 类型不支持   |
| -100206 | vapx 融合动画资源获取失败   |



如果还是无法解决您的问题，请提供日志文件我们来排查，日志文件的提取详见上面
