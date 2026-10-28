### TCMediaXBase class

### getInstance

**Description**

Get the singleton instance of TCMediaXBase.

**Interface**

```dart
public static TCMediaXBase getInstance()
```

**Parameter description**

None

### setLicense

**Description**

Set License

**Interface**

```dart
public void setLicense(Context context, String license, ILicenseCallback callback)
```

**Parameter description**

| Parameter name | Type             | Description         |
| -------------- | ---------------- | ------------------- |
| context        | Context          | Application context |
| license        | String           | License string      |
| callback       | ILicenseCallback | Verification result callback |

Callback declaration:

```java
public interface ILicenseCallback {
void onResult(final int errCode, final String msg);
}
```

License Verification error code:

```java
public interface TCLicenceErrorCode {
    int LicenseV2Ok = 0;                                  // Success
    int LicenseV2NotSet = -1;                             // setLicense has not been called yet
    int LicenseV2JsonError = -2;                          // JSON parsing failed
    int LicenseV2DownloadError = -3;                      // Download failed
    int LicenseV2ContentEmpty = -4;                       // Input parameter is empty
    int LicenseV2PackageNotMatch = -5;                    // packageName / bundleId does not match
    int LicenseV2Expired = -6;                            // License expired
    int LicenseV2SignatureError = -7;                     // RSA signature verification failed
    int LicenseV2FeatureNotSupported = -8;                // feature is not in the authorized list
    int LicenseV2DecodeError = -9;                        // AES decryption failed
    int LicenseV2Base64Error = -10;                       // Outer/inner base64 decoding failed
}
```

### setLogEnable

**Description**

Whether to enable Log output, default is on.

The Android side is saved in the /sdcard/Android/data/packagename/files/TCMediaX directory, and the iOS side is saved in the Documents/TCMediaX directory of the sandbox. You can upload the logs of this directory to the business background according to business needs to locate online user problems.

**Interface**

```dart
public void setLogEnable(Context context, boolean enable)
```

## TCEffectAnimView class

### startPlay

**Description**

Start the player.

**Interface**

```java
public int startPlay(String playUrl)
```

**Parameter Description**

playUrl is the video resource address.

Only supports playing local video resources on sdcard. If you use network video resources, download them locally before playing.

### setVideoMode

**Description**

Set the alignment of the alpha and rgb areas of the tep animation.

**Interface**

```java
public void setVideoMode(TCEffectPlayerConstant.VideoMode mode)
```

**Parameter Description**

mode supports the following formats:

| Enumeration value                                            | Meaning                                     |
| ------------------------------------------------------------ | ------------------------------------------- |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_NONE             | Ordinary mp4 file                           |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_HORIZONTAL | Align left and right (alpha left\rgb right) |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_VERTICAL   | Align top and bottom (alpha top\rgb bottom) |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE | Align left and right (rgb left\alpha right) |
| TCEffectPlayerConstant.VideoMode#VIDEO_MODE_SPLIT_VERTICAL_REVERSE | Align top and bottom (rgb top\alpha bottom) |

### setConfig

**Description**

Set the special effect player parameters, which needs to be called before starting playback.

**Interface**

```java
public void setConfig(TCEffectConfig config)
```

**Parameter Description**

Refer to TCEffectConfig class.

### setScaleType

**Description**

Set the alignment

**Interface**

```java
public void setScaleType(TCEffectPlayerConstant.ScaleType type)
```

**Parameter Description**

type supports the following formats:

| Enumeration value                            | Meaning                                                      |
| -------------------------------------------- | ------------------------------------------------------------ |
| TCEffectPlayerConstant.ScaleType.FIT_XY      | Fill the entire layout completely, default value             |
| TCEffectPlayerConstant.ScaleType.FIT_CENTER  | Display completely in the middle of the layout according to the video ratio |
| TCEffectPlayerConstant.ScaleType.CENTER_CROP | Fill the layout completely according to the video ratio (excess parts are not displayed) |

### setFetchResource

**Description**

Set the resources of the fused animation

**Interface**

```java
public void setFetchResource(IFetchResource fetchResource)
```

**Parameter Description**

IFetchResource interface:

```java
public interface IFetchResource {
// Get image
void fetchImage(Resource resource, IFetchResourceImgResult result);

// Get text
void fetchText(Resource resource, IFetchResourceTxtResult result);

// Resource release notification
void releaseResource(List<Resource> resources);
}
```

resource.tag is the tag (subscript) of the fusion animation, which can be used to determine the tag and pass in different text or image resources.

### setOnResourceClickListener

**Description**

Set the resource click event of the fusion animation.

**Interface**

```java
public void setOnResourceClickListener(OnResourceClickListener listener)
```

**Parameter Description**

OnResourceClickListener interface:

```java
public interface OnResourceClickListener {

void onClick(Resource resource);
}
```

Use resource.tag to distinguish the resources of the fusion animation.

### setRenderRotation

**Description**

Set the rotation angle of the fusion animation selection, supporting 0, 90, 180, 270, 360 degrees.

**Interface**

```java
public void setRenderRotation(int rotation)
```

### isPlaying

**Description**

Return whether the special effect player is playing

**Interface**

```java
public boolean isPlaying()
```

### resume

**Description**

Resume special effect animation playback

**Interface**

```java
public void resume()
```

### pause

**Description**

Pause special effect animation playback

**Interface**

```java
public void pause()
```


### seekTo

**Description**

Jump to the specified position to start playing.

Note:
1. This method can only be called after startPlay(), otherwise it will not take effect.
2. This interface is effective for mp4 animations or mp4 animations played with TCEffectConfig.CodecType.TX_LITEAV_SDK set.

milliSec: To start playing from the specified duration, in milliseconds.


**Interface**

```java
public void seekTo(long milliSec)
```

### seekProgress
**Description**

Jump to the specified position to start playing.

Note:
1. This method can only be called after startPlay(), otherwise it will not take effect.
2. This interface is effective for tcmp4 animations or mp4 animations played with TCEffectConfig.CodecType.TX_LITEAV_SDK set.
3. The input parameter progress has a value range of [0.0-1.0], and values outside this range will not take effect.

progress: Start playing from the specified percentage of the animation duration, in percentage, with a value range of [0.0-1.0].

**Interface**

```java
public void seekProgress(float progress)
```


### setLoop

**Description**

Set loop playback.

true: indicates loop playback;

false: indicates loop playback is turned off;

**Interface**

```java
public void setLoop(boolean isLoop)
```


### setLoopCount

**Description**
Set the number of loop plays.

loopCount: Indicates the number of times to loop the playback. When loopCount <= 0, it means infinite looping; when loopCount = n (n >= 1), it means to play from the beginning to the end, for a total of n times.


Note:

1. The default value of loopCount is 1, which means that when this method is not actively called externally, the animation will play only once and then end.
2. The setLoop(boolean isLoop) method internally calls the current method, meaning that when isLoop = true, it is equivalent to calling setLoopCount(-1); and when isLoop = false, it is equivalent to calling setLoopCount(1); therefore, these two methods affect each other, and the later call will override the previous one.

**Interface**

```java
public void setLoopCount(int loopCount)
```


### setDuration
**Description**

Set the duration for the animation to complete playback. After setting, the subsequent animation playback will automatically adjust the playback speed to ensure that the animation ends at the set duration.

That is: If the set duration exceeds the original animation duration, the animation will play slowly; if it is less than the original animation duration, it will fast forward.

Note: 
1.Currently, this only applies to tcmp4 format animations.
2.The current method and the `setRate` method for setting the playback speed are mutually exclusive; the latter call will override the former.

durationInMilliSec: The duration to be set, in milliseconds.

**Interface**

```java
public void setDuration(long durationInMilliSec)
```


### stopPlay

**Description**

Stop playback.

**Interface**

```java
public void stopPlay(boolean clearLastFrame)
```

### setMute

**Description**

Set whether to play silently.

true: Play silently;

false: Play non-silently;

**Interface**

```java
public void setMute(boolean mute)
```

### setPlayListener

**Description**

Set the special effect player playback callback.

**Interface**

```java
public void setPlayListener(IAnimPlayListener listener)
```

**Parameter Description**

IAnimPlayListener interface:

```java
public interface IAnimPlayListener {
void onPlayStart();

void onPlayEnd();

void onPlayError(int errorCode);

void onPlayEvent(int event, Bundle param);
}
```
For the `onPlayEvent` method, the values of the `event` parameter are detailed in the `TCEffectPlayerConstant` class as constants:
```java
public static final int REPORT_INFO_ON_PLAY_EVT_PLAY_END = 2006;
public static final int REPORT_INFO_ON_PLAY_EVT_RCV_FIRST_I_FRAME = 2003;
public static final int REPORT_INFO_ON_PLAY_EVT_CHANGE_RESOLUTION = 2009;
public static final int REPORT_INFO_ON_PLAY_EVT_LOOP_ONCE_COMPLETE = 6001;
public static final int REPORT_INFO_ON_VIDEO_CONFIG_READY = 200001;
public static final int REPORT_INFO_ON_NEED_SURFACE = 200002;
public static final int REPORT_INFO_ON_VIDEO_SIZE_CHANGE = 200003;
public static final int REPORT_ANIM_INFO = 200004;
```

For the `onPlayError` method, the values of the `errorCode` parameter are detailed in the `TCEffectPlayerConstant` class as constants:
```java
public static final int REPORT_ERROR_TYPE_HEVC_NOT_SUPPORT = -10007; // h265 is not supported
public static final int REPORT_ERROR_TYPE_INVALID_PARAM = -10008; // Illegal parameters
public static final int REPORT_ERROR_TYPE_INVALID_LICENSE = -10009; // License is illegal
public static final int REPORT_ERROR_TYPE_ADVANCE_MEDIA_PLAYER = -10010; // MediaPlayer playback failed
public static final int REPORT_ERROR_TYPE_MC_DECODER = -10011; // Decoder failed in MediaCodec
public static final int REPORT_ERROR_TYPE_UNKNOWN_ERROR = -20000; // Unknown error
```


### getTCAnimInfo

**Description**

Obtain the information corresponding to the currently playing animation, return an instance of `TCEffectAnimInfo`. For more details, see `TCEffectAnimInfo`.

Note: This method must be called within the `IAnimPlayListener#onPlayStart()` method or after this method is executed to obtain the information of the current animation; otherwise, it will return null.

**Interface**

```java
public TCEffectAnimInfo getTCAnimInfo()
```

### getTCEffectPlayer

**Description**

Get the TCEffectPlayer instance.

**Interface**

```java
public TCEffectPlayer getTCEffectPlayer()
```

### onDestroy

**Description**

Stop playback and release resources.

**Interface**

```java
public void onDestroy()
```

## TCEffectConfig class

**Description**

Construct the special effect player configuration, which needs to be constructed through Builder.

Note: The following features require the Tencent Cloud RT-Cube Gift AR Enterprise Edition SDK and an Enterprise License authorization. [Click here](https://cloud.tencent.com/document/product/616/116459) for details.

**Builder interface**

```java
// Set CodecType
public Builder setCodecType(CodecType type)
```

**Parameter Description**

setCodecType(CodecType type): It has three values, namely:

- TCEffectConfig.CodecType.TC_MPLAYER (MPLAYER playback engine)

- TCEffectConfig.CodecType.TC_MCODEC (MCODEC playback engine)

- TCEffectConfig.CodecType.TX_LITEAV_SDK (Tencent Cloud Player SDK)

```java
// Set playback configuration, non-essential step
TCEffectConfig config = new TCEffectConfig.Builder().setCodecType(TCEffectConfig.CodecType.TC_MPLAYER).build();
mPlayerView.setConfig(config);
```

Note:

1. Currently only supports calling setConfig() before the player starts Method to set playback configuration. Configuration modification is not supported after playback starts.

2. The three currently supported CodecTypes are only effective for TEP animations.

3. If CodecType is set to TCEffectConfig.CodecType.TX_LITEAV_SDK, you also need to separately introduce Tencent Cloud Player SDK, and apply for and register its corresponding license.

4. If config is not set, CodecType = TCEffectConfig.CodecType.TC_MPLAYER will be used by default


```java
// Set freeze frame index
public Builder setFreezeFrame(int frame)
```
**Parameter Description**

The input parameter "frame" indicates at which frame the animation should pause when playing. Currently available values:

- TCEffectConfig.FREEZE_FRAME_NONE : Disable the freezeFrame feature, and the player will play and pause normally without freezing.

- TCEffectConfig.FREEZE_FRAME_LAST : After the first playthrough, the screen stays on the last frame.


```java
// Set the format of the animation to be played subsequently.
public Builder setAnimType(AnimType type)
```
**Parameter Description**

Used to specify the format of the animation to be played subsequently, suitable for scenarios where the file extension of the animation to be played has been modified in some cases. The input parameter "type" represents the animation format to be specified. Currently available options are:

- TCEffectConfig.AnimType.AUTO  (The SDK's default policy, which determines the animation format based on the file extension of the animation, such as tcmp4/mp4/tep/tepg formats, etc.)

- TCEffectConfig.AnimType.MP4  (MP4 animation format, all subsequent animation files will be played as MP4 type, regardless of the file extension.)

- TCEffectConfig.AnimType.TCMP4 (TCMP4 animation format, all subsequent animation files will be played as TCMP4 type, regardless of the file extension.)



## TCEffectAnimInfo
**Description**

Store the information of the currently playing animation

**Property Description**

| Property name   | Type              | Description           |
| -------- | ----------------| -------------- |
| type     | int             | Current animation type, values: TCEffectAnimInfo.TYPE_MP4 and TCEffectAnimInfo.TYPE_TCMP4 |
| duration | long            | Animation duration, in milliseconds |
| width    | int             | Animation width         |
| height   | int             | Animation height         |
| encryptLevel  | int             | The current animation's advanced encryption type. If the value is TCEffectAnimInfo#ENCRYPT_LEVEL_NONE, it indicates that there is no advanced encryption; otherwise, it indicates that advanced encryption is applied.          |
| mixInfo   | MixInfo             | Merge animation information; when it is null, it means that the animation has no merge information.                        |



## TCEffectAnimInfo.MixInfo
**Description**

Store the mix information in the current playing animation.

**Property Description**

| Property name   | Type              | Description                                                                         |
| -------- | ----------------|-------------------------------------------------------------------------------------|
| textMixItemList     | List<MixItem>             | Text mix information; when it is null, it means there is no text mix information.   |
| imageMixItemList     | List<MixItem>             | Image mix information; when it is null, it means there is no image mix information. |


## TCEffectAnimInfo.MixInfo.MixItem
**Description**

Store the mix information in the current playing animation.

**Property Description**

| Property name   | Type            | Description                                                                                                                                                                                                                       |
| -------- |---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| id     | String        | The current mix animation ID. If it is tcmp4, it is the corresponding layer index to be replaced; if it is mp4, it is the ID value displayed in the TEP-Tool.                                                            |
| tag     | String        | The current mix animation tag. If it is tcmp4, it is the fixed value: TCEffectPlayerConstant.TAG_TPEG; if it is mp4, it is the tag value filled in the TEP-Tool.                                                         |
| text     | String        | The text content of the current text mix animation (this value is empty for image mix animations). If it is tcmp4, it is its internal original text content; if it is mp4, it is the tag value filled in the TEP-Tool. |


## TCEffectText
**Description**

Fusion animation replacement text style data class

**Property Description**

| Property name       | Type     | Description                                                                                                                              |
|-----------|--------|---------------------------------------------------------------------------------------------------------------------------------|
| text      | String | The final text content to be replaced and displayed                                                                                                                  |
| color     | int    | Text color, format required: ARGB, such as 0xFFFFFFFF                                                                                                     |
| fontStyle | String | Text display style, possible values: 'bold' for bold, default size if not specified|
| alignment    | int    | Text alignment mode, possible values: TEXT_ALIGNMENT_NONE (default value, keeping the SDK default alignment), TCEffectText.TEXT_ALIGNMENT_LEFT (left-aligned), TCEffectText.TEXT_ALIGNMENT_CENTER (centered), TCEffectText.TEXT_ALIGNMENT_RIGHT (right-aligned)|
| fontSize     | float    | Text size, in pixels (px); if a text size is set (value greater than 0), the internal automatic scaling strategy will be disabled, and the specified text size will be enforced. This may result in the text being too large to be fully displayed. |