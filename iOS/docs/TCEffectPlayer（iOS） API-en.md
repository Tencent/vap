### TCMediaXBase class

### getInstance

**Description**

Get the singleton instance of TCMediaXBase.

**Interface**

```objective-c
+ (instancetype)getInstance;
```

**Parameter description**

None

### setLicense

**Description**

Set License

**Interface**

```objective-c
- (void)setLicense:(NSString *)license
          callback:(nullable TCMediaXLicenseCallback)callback;
```

**Parameter description**

| Parameter name | Type                    | Description           |
| -------------- | ----------------------- | --------------------- |
| license        | NSString                | License string        |
| callback       | TCMediaXLicenseCallback | Verification result callback |

Callback declaration:

```objective-c
typedef void(^TCMediaXLicenseCallback)(int errCode, NSString * _Nullable message);
```

License verification error code:

```objective-c
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

### setLogEnable

**Description**

Whether to enable Log output, default is on.

On Android, logs are saved in the /sdcard/Android/data/packagename/files/TCMediaX directory; on iOS, they are saved in the Documents/TCMediaX directory of the sandbox. You can upload the logs in this directory to your business backend as needed to locate online user issues.

**Interface**

```objective-c
- (void)setLogEnable:(BOOL)enabled;
```

### getSdkVersion

**Description**

Get the current SDK version.

**Interface**

```objective-c
- (NSString *)getSdkVersion;
```

## 

## TCEffectAnimView class

### initWithFrame

**Description**

Create TCEffectAnimView.

**Interface**

```objective-c
- (instancetype)initWithFrame:(CGRect)frame;
```

**Parameter description**

frame: The frame of the View object.

### startPlay

**Description**

Start the player.

**Interface**

```objective-c
- (void)startPlay:(NSString *)url;
```

**Parameter description**

url is the video resource address.

Only local video resources are supported. If you are using network video resources, download them locally before playing.

### setVideoMode

**Description**

Set the alignment of the alpha and rgb areas of the mp4 animation.

**Interface**

```objective-c
- (void)setVideoMode:(TCEPVAPVideoFrameTextureBlendMode)mode;
```

**Parameter description**

mode supports the following formats:

| Enumeration value                     | Meaning                                     |
| ------------------------------------- | ------------------------------------------- |
| TCEPVAPVFTextureBlendMode_None        | Ordinary mp4 file                           |
| TCEPVAPVFTextureBlendMode_AlphaLeft   | Align left and right (alpha left\rgb right) |
| TCEPVAPVFTextureBlendMode_AlphaTop    | Align top and bottom (alpha top\rgb bottom) |
| TCEPVAPVFTextureBlendMode_AlphaRight  | Align left and right (rgb left\alpha right) |
| TCEPVAPVFTextureBlendMode_AlphaBottom | Align top and bottom (rgb top\alpha bottom) |

### setEffectPlayerConfig

**Description**

Set the special effect player parameters. It needs to be called before starting playback.

**Interface**

```objective-c
- (void)setEffectPlayerConfig:(TCEffectConfig *)config;
```

**Parameter description**

Refer to the TCEffectConfig class.

### setRenderMode

**Description**

Set the alignment

**Interface**

```objective-c
- (void)setRenderMode:(TCEPVPViewContentMode)renderMode;
```

**Parameter description**

renderMode supports the following formats:

| Enumeration value                 | Meaning                                                      |
| --------------------------------- | ------------------------------------------------------------ |
| TCEPVPViewContentModeScaleToFill  | The content is stretched to fill the entire view, which may be distorted. Default value. |
| TCEPVPViewContentModeAspectFit    | The content keeps its original aspect ratio and scales to be fully displayed, possibly with blank areas. |
| TCEPVPViewContentModeAspectFill   | The content keeps its original aspect ratio and scales to fill the view, possibly cropping some content. |

### effectPlayerDelegate

**Description**

TCEPAnimViewDelegate supports setting animation special effect player playback event callbacks, fusion animation information, etc.

**Playback callback interface**

```objective-c
// Animation start playback callback
- (void)tcePlayerStart:(ITCEffectPlayer *)player;

// Animation end playback callback
- (void)tcePlayerEnd:(ITCEffectPlayer *)player;

// Animation playback error callback
- (void)tcePlayerError:(ITCEffectPlayer *)player error:(NSError *)error;

// Player event notification
- (void)onPlayEvent:(ITCEffectPlayer *)player
              event:(int)EvtID
          withParam:(NSDictionary *)param;
```

**Fusion animation information replacement interface**

```objective-c
// Replace the text placeholder in the fusion animation resource configuration, supporting properties such as the alignment and color of the configuration file.
- (TCEffectText *)loadTextForPlayer:(ITCEffectPlayer *)player
                           withTag:(NSString *)tag;


// Replace the image information in the fusion animation resource
// Get the tag corresponding to the current image: NSString *tag = context[TCEPContextSourceTypeImageIndex];
- (void)loadImageForPlayer:(ITCEffectPlayer *)player
                   context:(NSDictionary *)context
                completion:(void(^)(UIImage *image,
                                    NSError *error))completionBlock;
```

**Fusion animation click callback interface**

```objective-c
// Fusion animation resource click event callback
- (void)tcePlayerTagTouchBegan:(ITCEffectPlayer *)player tag:(NSString *)tag;
```

### setRenderRotation

**Description**

Set the animation rotation direction.

**Interface**

```objective-c
- (void)setRenderRotation:(TCEP_Enum_Type_HomeOrientation)rotation;
```

**Parameter description**

rotation supports the following formats:

| Enumeration value                     | Meaning                                                      |
| ------------------------------------- | ------------------------------------------------------------ |
| TCEP_HOME_ORIENTATION_RIGHT           | HOME key is on the right, landscape mode.                    |
| TCEP_HOME_ORIENTATION_DOWN            | HOME key is at the bottom, the most common portrait live streaming mode on mobile |
| TCEP_HOME_ORIENTATION_LEFT            | HOME key is on the left, landscape mode.                     |
| TCEPVAPVFTextureBlendMode_AlphaRight  | HOME key is at the top, portrait live streaming.             |

### isPlaying

**Description**

Return whether the special effect player is playing

**Interface**

```objective-c
- (BOOL)isPlaying;
```

### resume

**Description**

Resume special effect animation playback

**Interface**

```objective-c
- (void)resume;
```

### pause

**Description**

Pause special effect animation playback

**Interface**

```objective-c
- (void)pause;
```


### seekTo

**Description**

Jump to the specified position to start playing

Note:
1. This method can only be called after startPlay(), otherwise it will not take effect
2. This interface is effective for tcmp4 animations, or mp4 animations played when vapEngineType is set to TCEPCodecTypeVODPlayer

time: Jump to the specified duration to start playing, in milliseconds


**Interface**

```objective-c
- (void)seek:(float)time;
```

### seekProgress

**Description**

Jump to the specified position to start playing

Note:
1. This method can only be called after startPlay(), otherwise it will not take effect
2. This interface is effective for mp4 animations, or mp4 animations played when vapEngineType is set to TCEPCodecTypeVODPlayer
3. The input parameter progress has a value range of [0.0-1.0], and values outside this range will not take effect

progress: Jump to the specified percentage of the animation duration to start playing, in percentage, with a value range of: [0.0-1.0]

**Interface**

```objective-c
- (void)seekProgress:(float)progress;
```


### setLoop

**Description**

Set loop playback.

YES: indicates loop playback;

NO: indicates loop playback is turned off;

**Interface**

```objective-c
- (void)setLoop:(BOOL)loop;
```

### setLoopCount

**Description**

Set the number of loop playbacks.

loopCount: indicates the number of loop playbacks. When loopCount <= 0, it indicates infinite loop playback; when loopCount = n (n >= 1), it indicates playing from the beginning to the end, for a total of n times

Note:
1. The default value of loopCount is 1, that is, when this method is not actively called externally, the animation is played only once and then ends
2. The setLoop method internally calls the current method, that is, when isLoop = true, it is equivalent to calling setLoopCount(-1); and when isLoop = false, it is equivalent to calling setLoopCount(1); therefore, these two methods affect each other, and the later call will override the previous one.

**Interface**

```objective-c
- (void)setLoopCount:(int)loopCount;
```

### setDuration

**Description**

Set how long the animation takes to finish playing. After setting, the playback speed is automatically adjusted during subsequent animation playback to ensure that the animation ends within the specified duration.

That is: if the set duration exceeds the original animation duration, the animation will play slowly; if it is less than the original animation duration, it will fast forward.

Note:
1. Currently, this only applies to animations in tcmp4 format
2. The current method and the setRate method for setting the playback speed are mutually exclusive; the later call will override the earlier one

durationInMilliSec: The duration to be set, in milliseconds

**Interface**

```objective-c
- (void)setDuration:(long)durationInMilliSec;
```


### stopPlay

**Description**

Stop playback.

**Interface**

```objective-c
- (void)stopPlay;
```

### setMute

**Description**

Set whether to play silently.

YES: play silently;

NO: play non-silently;

**Interface**

```objective-c
- (void)setMute:(BOOL)bEnable;
```

### getTCAnimInfo

**Description**

Get the information corresponding to the currently playing animation and return a TCEffectAnimInfo instance. For details, see TCEffectAnimInfo

Note: This method must be called within the IAnimPlayListener#onPlayStart() method, or after this method is executed, to obtain the information of the current animation; otherwise it returns null

**Interface**

```objective-c
- (nullable TCEffectAnimInfo *)getAnimInfo;
```

## TCEffectConfig class

**Note: The following features require the Tencent Cloud RT-Cube Gift AR Enterprise Edition SDK and an Enterprise License authorization. [Click here](https://cloud.tencent.com/document/product/616/116459) for details.**

**Description**

Construct the special effect player configuration. Supported properties:

1. vapEngineType(CodecType type): It has three values, namely:

- TCEPCodecTypeAVPlayer, the default playback engine of the animation special effects player.
- TCEPCodecTypeVODPlayer, the Tencent Cloud Player SDK playback engine.


```objective-c
// Set playback configuration, a non-essential step
TCEffectConfig *config = [[TCEffectConfig alloc] init];
[self.alphaAnimView setEffectPlayerConfig:config];

```

Note:

1. Currently, the playback configuration can only be set by calling the setEffectPlayerConfig method before the player starts. Modifying the configuration after playback starts is not supported.
2. The two currently supported vapEngineTypes are only effective for MP4 animations.
3. If vapEngineType is set to TCEPCodecTypeVODPlayer, you also need to separately introduce the Tencent Cloud Player SDK, and apply for and register its corresponding license.

2. freezeFrame is used to set the animation freeze frame. The current optional values are:

- FRAME_NONE: Default value, turns off the freezeFrame capability, and the player pauses and disappears after playing normally.

- FRAME_FIRST: After playback finishes, it restarts playback and pauses when the next first frame appears.

- FRAME_LAST: After the first playback finishes, the screen stays on the last frame.


## TCEffectAnimInfo
**Description**

Store the information of the currently playing animation

**Property description**

| Property name | Type                  | Description                                                  |
| ------------- | --------------------- | ------------------------------------------------------------ |
| type          | TCEPAnimResourceType  | Current animation type, values: TCEPAnimResourceTypeMP4 for MP4 type resources and TCEPAnimResourceTypeTCMP4 for TCMP4 type resources. |
| duration      | long                  | Animation duration, in milliseconds                          |
| width         | int                   | Animation width                                              |
| height        | int                   | Animation height                                             |
| encryptLevel  | TCEPEncryptLevelType  | The advanced encryption type of the current animation. If the value is TCEffectAnimInfo#ENCRYPT_LEVEL_NONE, it means there is no advanced encryption; otherwise, it means advanced encryption is applied. |


## TCEffectText
**Description**

Fusion animation replacement text style data class

**Property description**

| Property name | Type     | Description                                                  |
| ------------- | -------- | ------------------------------------------------------------ |
| text          | NSString | The final text content to be replaced and displayed           |
| color         | UIColor  | Text color, format required: ARGB, such as 0xFFFFFFFF         |
| fontStyle     | NSString | Text display style, possible values: "bold" for bold, default size if not specified |
| alignment     | int      | Text alignment mode, possible values: TCEPTextAlignmentNone (default value, keeping the SDK default alignment), TCEPTextAlignmentLeft (left-aligned), TCEPTextAlignmentCenter (centered), TCEPTextAlignmentRight (right-aligned) |
| fontSize      | CGFloat  | Text size, in px; if a text size is set (value greater than 0), the internal automatic scaling strategy will be disabled, and the specified text size will be enforced. This may result in the text being too large to be fully displayed. |
