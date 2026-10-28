# Introduction to Tencent Cloud RT-Cube Gift AR Vap Pro SDK

The Tencent Cloud RT-Cube Gift AR Vap Pro SDK (hereinafter referred to as the Gift AR SDK) is used to play cool video animations, and is commonly used to display cool gift-sending animations in live streaming rooms.

The following shows the playback effects of the original template video and the fused animation:

| Original template video                                      | Fused playback effect                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_temlate.gif) | ![img](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/Res/cool_vapx_car.gif) |

# Integration Guide
## Manual Integration

1. Download [MediaX_Android_Vap_Pro_SDK_Latest.zip](https://mediacloud-76607.gzc.vod.tencent-cloud.com/MediaX/vap_pro_sdk/download/latest/MediaX_Android_Vap_Pro_SDK_Latest.zip). After the download is complete, unzip it to obtain the SDK aar files.
2. Copy the aar files from the unzipped SDK directory to the app/libs directory of your project.
3. In the build.gradle file in the project root directory, add flatDir and specify the local repository path.
4. Add the Tencent Gift AR SDK dependency. In app/build.gradle, add the code that references the aar packages:
```groovy
implementation(name: "TCEffectPlayer_vap_pro_x.x.x", ext: "aar")
implementation(name: "TCMediaX_x.x.x", ext: "aar")
implementation(name: "xmagic-auth_x.x.x", ext: "aar")
```
Note: In the example above, x.x.x is the version number, which is subject to the latest SDK version number actually downloaded; also note that the version numbers of the three aar files must be consistent.

5. In the defaultConfig of app/build.gradle, specify the CPU architectures used by the App (currently supports armeabi, armeabi-v7a, and arm64-v8a).
```groovy
defaultConfig {
 ndk {
     abiFilters "armeabi", "armeabi-v7a", "arm64-v8a"
 }
}
```
## Setting Proguard Rules:
In the proguard-rules.pro file, add the relevant classes to the non-obfuscation list:

```java
-keep class com.tcmediax.** { *; }
-keep class com.tencent.** { *; }
-keep class androidx.exifinterface.** {*;}
```

# Apply for License Authorization

## Apply for a license

[Click to open](https://tceffect-license.tmf.qq.com/) the Tencent Cloud RT-Cube Gift AR Vap Pro SDK license application page. After the application is approved, you will obtain a permanently authorized License string. Please be sure to keep it safe.

## Initialize and register the license

After the application is approved, you will receive a License string (already base64-encoded). Pass it directly into the following interface to complete the license verification.

```java
// When using, replace LICENSE with the License envelope string you obtained
String license = "${license}";
TCMediaXBase.getInstance().setLicense(appContext, license, new ILicenseCallback() {
    @Override
    public void onResult(int errCode, String msg) {
        Log.d(TAG, "TCMediaX license result: errCode: " + errCode + ", msg: " + msg);
    }
});
```

License verification error codes:

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

## Log Management

You can enable saving logs to a file by calling TCMediaXBase#setLogEnable. On Android, logs are saved in the /sdcard/Android/data/packagename/files/TCMediaX directory; on iOS, they are saved in the Documents/TCMediaX directory of the sandbox. You can upload the logs in this directory to your business backend as needed to locate online user issues.


# Using the Gift AR SDK TCEffectPlayer

## 1. Add TCEffectAnimView to the layout

```xml
<FrameLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:layout_marginTop="0dp">
    <com.tencent.tcmediax.tceffectplayer.api.TCEffectAnimView
        android:id="@+id/video_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_centerInParent="true"
        android:visibility="visible" />
</FrameLayout>
```

## 2. Initialize TCEffectAnimView

```java
private TCEffectAnimView mPlayerView;
mPlayerView = (TCEffectAnimView) findViewById(R.id.video_view);

// Optional: set the video alignment mode (default FIT_CENTER, customizable)
mPlayerView.setScaleType(TCEffectPlayerConstant.ScaleType.FIT_CENTER);
```

## 3. Playback controls

### Start playing

Only local video resources on the sdcard are supported. If you are using network video resources, download them locally before playing.

```java
String localPath = /sdcard/Android/${packageName}/files/tep_cool_ss.mp4
mPlayerView.startPlay(localPath)
```

### Pause playback

```java
mPlayerView.pause()
```

### Resume playback

```java
mPlayerView.resume()
```

### Stop playback

When you no longer need to use the player, you need to stop playback and release the occupied resources.

```java
mPlayerView.stopPlay(true)
```

## 4. Fusion animation configuration

To implement Vap fusion animation, you need to implement the IFetchResource interface. If it is an image type, you need to return the corresponding Bitmap; if it is text, you need to return the corresponding String.
```java
mPlayerView.setFetchResource(new IFetchResource() {
    @Override
    public void fetchImage(Resource resource, IFetchResourceImgResult result) {
        String index = resource.id;
        // Later, you can select the image Bitmap resource you want to replace based on the value of the layer index.
        // If you want to skip a specified layer without replacing it, you can return null.
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inScaled = false;
        Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.test, options);
        // Return the result
        result.fetch(bitmap);
    }
    @Override
    public void fetchText(Resource resource, IFetchResourceTxtResult result) {
        String index = resource.id;
        // According to the value of the layer index, select the text String you want to replace.
        TCEffectText tcEffectText = new TCEffectText();
        tcEffectText.text = "test";
//                    tcEffectText.color = Color.YELLOW;
//                    tcEffectText.alignment = TCEffectText.TEXT_ALIGNMENT_RIGHT;
        tcEffectText.fontStyle = "bold";
        result.loadTextForPlayer(tcEffectText);
    }
    @Override
    public void releaseResource(List<Resource> resources) {
        // Resource release notification
        for (Resource resource : resources) {
            if (resource.bitmap != null) resource.bitmap.recycle();
        }
    }
});
```

To listen for the event that a custom resource of the Vap animation is clicked, you need to register the OnResourceClickListener listener:
```java
mPlayerView.setOnResourceClickListener(new OnResourceClickListener() {
    @Override
    public void onClick(Resource resource) {
        // Handle the display based on the clicked resource type
        if (resource.srcType.equals(Resource.SrcType.TXT)) {
            // If it is of type TXT, the id field is its layer id, and text is the text that was replaced at that time
            tvTest.setText(resource.text);
        } else {
            // If it is of type IMG, the id field is its layer id, and bitmap is the image that was replaced at that time
            ivTest.setImageBitmap(resource.bitmap);
        }
    }
});
```


## 5. Playback listener

You can set the animation playback status listener by calling the `setPlayListener` method before starting playback:

```java
// Set playback status callback
playerView.setPlayListener(new TCEffectAnimView.IAnimPlayListener() {
    @Override
    public void onPlayStart() {
        // Animation starts playing
    }

    @Override
    public void onPlayEnd() {
        // Animation ends playing
    }

    @Override
    public void onPlayError(int errorCode) {
        // Animation playback failed
    }
});
```

1. If you need to obtain information about the currently playing animation, you can call the `getTCAnimInfo()` method in the `onPlayStart()` method (or after this method is executed) to obtain an instance of the `TCEffectAnimInfo` object, and then obtain the type, duration, width and height of the currently playing animation.
2. The `onPlayEvent()` method will call back events during animation playback, and the callback thread is not guaranteed to be on the main thread.

# Frequently Asked Questions

## Playback failed

If the following log appears during playback:

```xml
License checked failed! tceffect player license required!
```

Please check whether you have applied for the Gift AR License and completed the initialization registration.

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
|------------|-------------|
| -10001     | Animation resource unpacking failed, please check if the played file is .mp4 first |
| -10002     | Animation decoding failed |
| -10003     | Failed to create internal decoding thread, please check if the device memory is insufficient |
| -10004     | Failed to parse configuration information in the animation file, check if the licenseKey entered during animation file conversion and the licenseKey set by the SDK are consistent |
| -10005     | Failed to prepare fusion animation resources, please check if the setFetchResource() interface is implemented correctly |
| -10006     | When starting to play, the entered animation file path is incorrect, please check if the corresponding file exists at this path |
| -10007     | The animation video encoding format is h265, which is not supported on the current device |
| -10008     | When starting to play, the entered animation file path is empty, please check |
| -10009     | License expired, please check the license validity period and whether the license and packageName match |
| -10011     | Mp4 animation playback failed, see errorMsg for details |
| -10012 | Missing some essential dependencies resulted in animation playback failure. For details on the missing dependencies, please refer to errorMsg                            |
| -20000     | Playback failure caused by other exceptions, see errorMsg for details |

If you still cannot solve your problem, please provide the log file for us to troubleshoot. See above for details on extracting the log file.
