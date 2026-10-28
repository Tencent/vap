# Introduction to Tencent Cloud RT-Cube Gift AR Vap Pro SDK

The Tencent Cloud RT-Cube Gift AR Vap Pro SDK (hereinafter referred to as the Gift AR SDK) is used to play cool video animations, and is commonly used to display cool gift-sending animations in live streaming rooms.

The following shows the playback effects of the original template video and the fused animation:

| Original template video                                      | Fused playback effect                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_temlate.gif) | ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_vapx_car.gif) |

# Integration Guide

#### **Manual Integration**

1. Download [MediaX_iOS_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_iOS_Vap_Pro_SDK_Latest.zip). After the download is complete, unzip it to obtain the SDK library files.

2. To use TCEffectPlayer, you need to integrate the following frameworks:

​	SDK libraries:

- TCMediaX.xcframework

- TCEffectPlayer.xcframework

- YTCommonXMagic.framework

  
  
  System libraries:
  
- libz.tab

- libc++.tbd

- AVFoundation.framework

  

  ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/ios_build_phases_3.0_vap_pro.png)

![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/res/ios_project_general_3.0_vap_pro.png)

2. Set Other Linker Flags

​	In "Build Settings" - "Other Linker Flags" - set "-ObjC"

# Apply for License Authorization

## Apply for a license

[Click to open](https://tceffect-license.tmf.qq.com/) the Tencent Cloud RT-Cube Gift AR VAP Pro SDK license application page. After the application is approved, you will obtain a permanently authorized License string. Please be sure to keep it safe.

## Initialize and register the license

After the application is approved, you will receive a License string (already base64-encoded). Pass it directly into the following interface to complete the license verification.

```objc
#import <TCMediaX/TCMediaX.h>
@interface AppDelegate ()
@end
  
@implementation AppDelegate

// When using, replace LICENSE with the License string you obtained
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

License verification error codes:

```objc
typedef NS_ENUM(NSInteger, TCMediaXLicenceCheckErrorCode) {
    TMXLicenseV2Ok                          = 0,    // Success
    TMXLicenseV2NotSet                      = -1,   // setLicense has not been called yet
    TMXLicenseV2JsonError                   = -2,   // envelope or plaintext JSON parsing failed
    TMXLicenseV2DownloadError               = -3,   // Reserved enumeration value
    TMXLicenseV2ContentEmpty                = -4,   // Input parameter is empty
    TMXLicenseV2PackageNotMatch             = -5,   // packageName / bundleId does not match
    TMXLicenseV2Expired                     = -6,   // Reserved enumeration value
    TMXLicenseV2SignatureError              = -7,   // RSA signature verification failed
    TMXLicenseV2FeatureNotSupported         = -8,   // feature is not in the authorized list
    TMXLicenseV2DecodeError                 = -9,   // AES decryption failed
    TMXLicenseV2Base64Error                 = -10,  // Outer/inner base64 decoding failed
};

```

## Log Management

You can enable saving logs to a file by calling TCMediaXBase#setLogEnable. On Android, logs are saved in the /sdcard/Android/data/packagename/files/TCMediaX directory; on iOS, they are saved in the Documents/TCMediaX directory of the sandbox. You can upload the logs in this directory to your business backend as needed to locate online user issues.

# Using the Gift AR SDK TCEffectPlayer

## 1. Initialize TCEffectAnimView

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

## 2. Add alphaAnimView and layout

```objc
// Add alphaAnimView
[self.view addSubview:self.alphaAnimView];

// Layout
self.alphaAnimView.frame = self.view.bounds;
```

## 3. Get video resources and play

```objc
 [self.alphaAnimView startPlay:mp4Url];
```

## 4. Fusion animation configuration

To implement fusion animation, you need to implement the TCEffectAnimViewDelegate proxy method.

#### Fusion animation text replacement

- Replace text and specify the alignment, color, and boldness of the text. Use the loadTextForPlayer interface. This interface is recommended.

- To replace only plain text, you can use the textContentForPlayer interface.

``` objc
// Replace text and specify the alignment, color, and boldness of the text. Use the loadTextForPlayer interface. This interface is recommended.
- (TCEffectText *)loadTextForPlayer:(ITCEffectPlayer *)player
                            withTag:(NSString *)tag {
    if (tag != nil && [tag isEqualToString:@"name"]) {
        TCEffectText *effectText = [[TCEffectText alloc] init];
        effectText.text = @"reText";
        // TCEPTextAlignmentLeft = 0,     ///< indicates left alignment of text
        // TCEPTextAlignmentCenter = 1,   ///< indicates center alignment of text
        // TCEPTextAlignmentRight = 2     ///< indicates right alignment of text
        effectText.alignment = TCEPTextAlignmentLeft; 
        //effectText.fontStyle = @"bold";
        //effectText.color = [UIColor blackColor];
        return effectText;;
    }
    return nil;
}

//To replace only plain text, you can use the textContentForPlayer interface. This interface has been deprecated and is not recommended. It is recommended to use loadTextForPlayer:withTag
- (NSString *)textContentForPlayer:(ITCEffectPlayer *)player
                           withTag:(NSString *)tag {
    NSDictionary *extraInfo = @{@"tag1" : @"tuiad_vap_car",
                                @"[sTxt1]" : @"I am the strongest king"};
    return extraInfo[tag];
}
```

#### Fusion animation image replacement

After obtaining the tag value, return the corresponding UIImage. The fusion animation player does not handle the conversion process internally, so you need to handle it yourself in this method.

```objc
- (void)loadImageForPlayer:(ITCEffectPlayer *)player
                   context:(NSDictionary *)context
                completion:(void(^)(UIImage *image,
                                    NSError *error))completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the tag corresponding to the image that needs to be replaced, and then return the image based on the tag
        NSString *tag = context[TCEPContextSourceTypeImageIndex];   
        ...
        // Download and cache the image
        if (image) {
            completionBlock(image, nil);
        } else {
            completionBlock(nil, error);
        }
        }];
    });
}

```

Listen for the event that an animation custom resource is clicked, and use tag to distinguish different fusion animation areas

```objc
- (void)tcePlayerTagTouchBegan:(ITCEffectPlayer *)player tag:(NSString *)tag {
    NSString *content = [NSString stringWithFormat:@"Clicked:%@",tag];
    [self.view tuiad_alert:content];
}
```

## 4. Start playing

Only local video resources are supported. If you are using network video resources, download them locally before playing.

```objc
NSString *mp4Url = @"xxx/xxx/tuiad_vapx_cool_sss.mp4"];
[self.alphaAnimView startPlay:mp4Url];
```

### Pause playback

```objc
[self.alphaAnimView pause];
```

### Resume playback

```objc
[self.alphaAnimView resume];
```

### Stop playback

 When you no longer need to use the player, you need to stop playback and release the occupied resources.

```objc
[self.alphaAnimView stopPlay];
```
###  Play silently
 ```objc
 [self.alphaAnimView setMute:YES];
 ```

###  Loop

 ```objc
 [self.alphaAnimView setLoop:YES];
 ```


# Frequently Asked Questions

## Playback failed

If the following log appears during playback:

```xml
License checked failed! tceffect player license required!
```

Please check whether you have applied for the Gift AR SDK License and completed the initialization registration.

## Extract the running log

By default, the Gift AR SDK saves running logs. If a problem occurs during testing, you can extract the logs and send them to Tencent Cloud customer service.

### Android side

The special effects player logs are saved in the directory: /sdcard/Android/data/${your_packagename}/files/TCMediaLog. The log files are named by date; just export the TCMediaLog folder.

![image-20240806165900560](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/android_log.png)

### iOS side

The special effects player logs are saved in the sandbox Documents/TCMedialog folder

1. Export the sandbox file, operation: Open XCode -> Window -> Devices and Simulators

<img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/ios_container.png" alt="image-20240806170453328" style="zoom: 50%;" />

2. Extract the AppData/Documents/TCMedialog folder

<img src="https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/png/ios_log.png" style="zoom:50%;" />

**No log file??**

Please check whether the log is disabled by passing false through TCMediaXBase#setLogEnable. File logging is enabled by default.


## Common Error Codes

| Error Code | Description |
|----------|-----------|
| -10003   | Thread creation failed |
| -10004 | Render creation failed    |
| -10005 | Configuration parsing failed   |
| -10006 | File cannot be read   |
| -10007 | The animation video encoding format is h265, which is not supported on the current device   |
| -10008 | Invalid parameter   |
| -10009 | Illegal license   |
| -10010 | Emulator not supported   |
| -100200 | Signature verification failed   |
| -100201 | Data decryption failed   |
| -100202 | BundleID or PackageName does not match   |
| -100203 | Resource expired   |
| -100204 | Incorrect JSON field   |
| -100205 | Unsupported boxType   |
| -100206 | Vapx fusion animation resource acquisition failed   |




If you still cannot solve your problem, please provide the log file for us to troubleshoot. See above for details on extracting the log file.
