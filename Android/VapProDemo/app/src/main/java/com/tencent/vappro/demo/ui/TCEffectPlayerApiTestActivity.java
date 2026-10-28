package com.tencent.vappro.demo.ui;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;

import com.tencent.tcmediax.tceffectplayer.api.TCEffectAnimView;
import com.tencent.tcmediax.tceffectplayer.api.TCEffectConfig;
import com.tencent.tcmediax.tceffectplayer.api.TCEffectPlayerConstant;
import com.tencent.tcmediax.tceffectplayer.api.data.TCEffectAnimInfo;
import com.tencent.tcmediax.tceffectplayer.api.data.TCEffectText;
import com.tencent.tcmediax.tceffectplayer.api.mix.IFetchResource;
import com.tencent.tcmediax.tceffectplayer.api.mix.IFetchResourceImgResult;
import com.tencent.tcmediax.tceffectplayer.api.mix.IFetchResourceTxtResult;
import com.tencent.tcmediax.tceffectplayer.api.mix.Resource;
import com.tencent.tcmediax.utils.Log;
import com.tencent.vappro.demo.R;
import com.tencent.vappro.demo.util.AnimFiles;

import java.io.File;

/**
 * TCEffectPlayer API 测试界面。
 * 仅保留 mp4 的播放测试：
 *   - ScaleType（缩放）、Rotation（旋转）、Rate（倍速）、Loop、Mute
 *   - Codec（TC_MPLAYER / TC_MCODEC）
 *   - 融合资源 fetchResource（图片/文本）
 *   - Snapshot 截图
 *   - 切换动画资源
 * 鉴权使用 {@link com.tencent.vappro.demo.TCMediaXLicenseService}
 */
public class TCEffectPlayerApiTestActivity extends Activity {
    private static final String TAG = "TCEffectPlayerApiTest";

    private static final String CENTER_CROP = "CENTER_CROP";
    private static final String FIT_CENTER = "FIT_CENTER";
    private static final String FIT_XY = "FIT_XY";
    private static final String FIT_START = "FIT_START";
    private static final String FIT_END = "FIT_END";
    private static final String[] SPINNER_SCALE_TYPE_ITEMS = {CENTER_CROP, FIT_CENTER, FIT_XY, FIT_START, FIT_END};

    private static final String[] SPINNER_ROTATION_ITEMS = {"-180", "-90", "0", "90", "180", "270", "360", "450", "540", "630"};

    private static final String[] SPINNER_RATE_ITEMS = {"0.5", "1.0", "1.5", "2.0", "2.5", "3.0"};

    private static final String CODEC_TC_MPLAYER = "MP";
    private static final String CODEC_TC_MCODEC = "MC";
    // 仅保留 SDK 自带 Codec 实现（TC_MPLAYER / TC_MCODEC），不启用 TX_LITEAV_SDK 以降低集成成本
    private static final String[] SPINNER_CODEC_ITEMS = {CODEC_TC_MPLAYER, CODEC_TC_MCODEC};

    private Spinner spinnerScaleType;
    private Spinner spinnerRotation;
    private Spinner spinnerCodec;
    private Spinner spinnerRate;
    private TCEffectAnimView playerView;
    private View btnStartPlay;
    private View btnPause;
    private View btnResume;
    private View btnStopPlay;
    private View btnSnapshot;
    private TextView tvAnimFilePath;
    private View btnChangeAnimFilePath;
    private ImageView ivClickDisplay;
    private TextView tvClickDisplay;
    private SwitchCompat switchIsLooping;
    private SwitchCompat switchIsMute;
    private ScrollView scrollLogs;
    private TextView tvLogs;

    private int curSelectedAnimFilePathIndex = 0;
    private TCEffectPlayerConstant.ScaleType curScaleType = TCEffectPlayerConstant.ScaleType.FIT_CENTER;
    private int curRotation = 0;
    private float curPlayRate = 1.0f;
    private boolean isLooping = false;
    private boolean isMute = false;
    private TCEffectConfig.CodecType curCodecType = TCEffectConfig.CodecType.TC_MPLAYER;
    private TCEffectConfig tcEffectConfig;

    private boolean needAutoResumeWhenActivityResume = false;

    private AnimFiles animFiles;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_api_test);

        animFiles = new AnimFiles(this);
        animFiles.copyResourceIfNeed();

        initViews();
    }

    private void initViews() {
        findViewById(R.id.back_tv).setOnClickListener(v -> finish());
        playerView = findViewById(R.id.anim_view);
        spinnerScaleType = findViewById(R.id.sp_scale_type);
        spinnerRotation = findViewById(R.id.sp_rotation);
        spinnerCodec = findViewById(R.id.sp_codec);
        spinnerRate = findViewById(R.id.sp_rate);
        btnStartPlay = findViewById(R.id.btn_start_play);
        btnPause = findViewById(R.id.btn_pause);
        btnResume = findViewById(R.id.btn_resume);
        btnStopPlay = findViewById(R.id.btn_stop);
        btnSnapshot = findViewById(R.id.btn_snapshot);
        tvAnimFilePath = findViewById(R.id.tv_anim_file_path);
        btnChangeAnimFilePath = findViewById(R.id.btn_change_anim_file_path);
        ivClickDisplay = findViewById(R.id.iv_click);
        ivClickDisplay.setOnClickListener(v -> ivClickDisplay.setVisibility(View.GONE));
        tvClickDisplay = findViewById(R.id.tv_click);
        switchIsLooping = findViewById(R.id.switch_looping);
        switchIsMute = findViewById(R.id.switch_mute);
        scrollLogs = findViewById(R.id.sroll_logs);
        tvLogs = findViewById(R.id.tv_logs);

        tvAnimFilePath.setText(animFiles.getAnimFileName(curSelectedAnimFilePathIndex));

        setupSpinners();
        setupSwitches();
        setupButtons();
        setupPlayerListeners();

        appendLogs("日志会在这里打印，长按可以清除所有日志");
        Toast.makeText(this, "建议测试：\n- 常规 mp4（demo.mp4）\n- 融合资源（vap_car_ronghe.mp4 / vap_king_ronghe.mp4）",
                Toast.LENGTH_LONG).show();
    }

    private void setupSpinners() {
        spinnerScaleType.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, SPINNER_SCALE_TYPE_ITEMS));
        spinnerRotation.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, SPINNER_ROTATION_ITEMS));
        spinnerCodec.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, SPINNER_CODEC_ITEMS));
        spinnerRate.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, SPINNER_RATE_ITEMS));

        spinnerScaleType.setSelection(1); // FIT_CENTER
        spinnerRotation.setSelection(2);  // 0
        spinnerCodec.setSelection(0);     // MP
        spinnerRate.setSelection(1);      // 1.0

        // 避免第一次 setAdapter 之后自动回调一次
        spinnerScaleType.post(() -> spinnerScaleType.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
                String selected = SPINNER_SCALE_TYPE_ITEMS[pos];
                if (CENTER_CROP.equals(selected)) {
                    curScaleType = TCEffectPlayerConstant.ScaleType.CENTER_CROP;
                } else if (FIT_XY.equals(selected)) {
                    curScaleType = TCEffectPlayerConstant.ScaleType.FIT_XY;
                } else if (FIT_START.equals(selected)) {
                    curScaleType = TCEffectPlayerConstant.ScaleType.FIT_START;
                } else if (FIT_END.equals(selected)) {
                    curScaleType = TCEffectPlayerConstant.ScaleType.FIT_END;
                } else {
                    curScaleType = TCEffectPlayerConstant.ScaleType.FIT_CENTER;
                }
                playerView.setScaleType(curScaleType);
                appendLogs("ScaleType = " + selected + "（下次 startPlay() 生效）");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        }));

        spinnerRotation.post(() -> spinnerRotation.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
                curRotation = Integer.parseInt(SPINNER_ROTATION_ITEMS[pos]);
                playerView.setRenderRotation(curRotation);
                appendLogs("Rotation = " + curRotation + "（下次 startPlay() 生效）");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        }));

        spinnerCodec.post(() -> spinnerCodec.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
                String selected = SPINNER_CODEC_ITEMS[pos];
                if (CODEC_TC_MCODEC.equals(selected)) {
                    curCodecType = TCEffectConfig.CodecType.TC_MCODEC;
                } else {
                    curCodecType = TCEffectConfig.CodecType.TC_MPLAYER;
                }
                applyConfig();
                appendLogs("Codec = " + selected + "（下次 startPlay() 生效）");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        }));

        spinnerRate.post(() -> spinnerRate.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
                curPlayRate = Float.parseFloat(SPINNER_RATE_ITEMS[pos]);
                playerView.getTCEffectPlayer().setRate(curPlayRate);
                appendLogs("Rate = " + curPlayRate + "（已生效）");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        }));
    }

    private void setupSwitches() {
        switchIsLooping.setOnCheckedChangeListener((buttonView, isChecked) -> {
            isLooping = isChecked;
            playerView.setLoop(isLooping);
            appendLogs("Loop = " + isLooping + "（已生效）");
        });
        switchIsMute.setOnCheckedChangeListener((buttonView, isChecked) -> {
            isMute = isChecked;
            playerView.setMute(isMute);
            appendLogs("Mute = " + isMute + "（已生效）");
        });
    }

    private void setupButtons() {
        btnStartPlay.setOnClickListener(v -> onBtnStartPlayClicked());
        btnPause.setOnClickListener(v -> onBtnPauseClicked());
        btnResume.setOnClickListener(v -> onBtnResumeClicked());
        btnStopPlay.setOnClickListener(v -> onBtnStopPlayClicked());
        btnSnapshot.setOnClickListener(v -> onBtnSnapshotClicked());
        btnChangeAnimFilePath.setOnClickListener(v -> onBtnChangeAnimFilePathClicked());

        tvLogs.setOnLongClickListener(v -> {
            tvLogs.setText("");
            return true;
        });
    }

    private void setupPlayerListeners() {
        playerView.setPlayListener(new TCEffectAnimView.IAnimPlayListener() {
            @Override
            public void onPlayStart() {
                Log.d(TAG, "onPlayStart");
                appendLogs("[IAnimPlayListener] onPlayStart");
                TCEffectAnimInfo info = playerView.getTCAnimInfo();
                if (info != null) {
                    String typeStr = info.type == TCEffectAnimInfo.TYPE_MP4 ? "mp4" : "tcmp4";
                    Log.d(TAG, "TCAnimInfo type=" + typeStr + ", duration=" + info.duration
                            + ", width=" + info.width + ", height=" + info.height
                            + ", encLevel=" + info.encryptLevel);
                }
            }

            @Override
            public void onPlayEnd() {
                Log.d(TAG, "onPlayEnd");
                appendLogs("[IAnimPlayListener] onPlayEnd");
            }

            @Override
            public void onPlayError(int errorCode) {
                Log.d(TAG, "onPlayError: " + errorCode);
                appendLogs("[IAnimPlayListener] onPlayError: " + errorCode);
            }

            @Override
            public void onPlayEvent(int event, Bundle param) {
                if (event == TCEffectPlayerConstant.REPORT_INFO_ON_PREPARED) {
                    playerView.post(() -> appendLogs("[IAnimPlayListener] Prepared"));
                } else if (event == TCEffectPlayerConstant.EVT_VIDEO_RENDER_PROGRESS) {
                    int curFrame = param.getInt(TCEffectPlayerConstant.EVT_FRAME_INDEX);
                    Log.d(TAG, "onPlayEvent curFrame=" + curFrame);
                }
            }
        });

        // 融合资源：图片 / 文本
        playerView.setFetchResource(new IFetchResource() {
            @Override
            public void fetchImage(Resource resource, IFetchResourceImgResult result) {
                Log.d(TAG, "fetchImage resource: " + resource);
                if (!TextUtils.isEmpty(resource.tag)) {
                    int headerId = R.drawable.demo_avatar_car;
                    if ((curSelectedAnimFilePathIndex % 2) == 0) {
                        headerId = R.drawable.demo_avatar_earphone;
                    }
                    BitmapFactory.Options options = new BitmapFactory.Options();
                    options.inScaled = false;
                    Bitmap bitmap = BitmapFactory.decodeResource(getResources(), headerId, options);
                    result.fetch(bitmap);
                } else {
                    result.fetch(null);
                }
            }

            @Override
            public void fetchText(Resource resource, IFetchResourceTxtResult result) {
                Log.d(TAG, "fetchText resource: " + resource);
                String tag = resource.tag;
                if (!TextUtils.isEmpty(tag)) {
                    TCEffectText tcEffectText = new TCEffectText();
                    tcEffectText.text = "test" + tag;
                    tcEffectText.fontStyle = "bold";
                    result.loadTextForPlayer(tcEffectText);
                } else {
                    result.fetch("");
                }
            }

            @Override
            public void releaseResource(java.util.List<Resource> resources) {
                for (Resource resource : resources) {
                    if (resource.bitmap != null) resource.bitmap.recycle();
                }
            }
        });

        playerView.setOnResourceClickListener(resource -> {
            if (Resource.SrcType.TXT.equals(resource.srcType)) {
                ivClickDisplay.setVisibility(View.GONE);
                tvClickDisplay.setVisibility(View.VISIBLE);
                tvClickDisplay.setText(resource.text);
                tvClickDisplay.postDelayed(() -> tvClickDisplay.setVisibility(View.GONE), 500);
            } else {
                tvClickDisplay.setVisibility(View.GONE);
                ivClickDisplay.setVisibility(View.VISIBLE);
                ivClickDisplay.setImageBitmap(resource.bitmap);
                ivClickDisplay.postDelayed(() -> ivClickDisplay.setVisibility(View.GONE), 500);
            }
        });
    }

    private void applyConfig() {
        tcEffectConfig = new TCEffectConfig.Builder()
                .setCodecType(curCodecType)
                // 仅测试 mp4，固定 AnimType = MP4
                .setAnimType(TCEffectConfig.AnimType.MP4)
                .enableProgressCallback(true)
                .enableFrameRenderCallback(true)
                .build();
        playerView.setConfig(tcEffectConfig);
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (playerView.isPlaying()) {
            needAutoResumeWhenActivityResume = true;
            playerView.pause();
        }
        if (isFinishing()) {
            onBtnStopPlayClicked();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (needAutoResumeWhenActivityResume) {
            needAutoResumeWhenActivityResume = false;
            playerView.resume();
        }
    }

    private void onBtnStartPlayClicked() {
        File animFile = new File(animFiles.getAnimFilePath(curSelectedAnimFilePathIndex));
        if (!animFile.exists()) {
            Toast.makeText(this, "资源尚未拷贝完成或不存在: " + animFile.getAbsolutePath(), Toast.LENGTH_SHORT).show();
            return;
        }

        appendLogs("[Click] StartPlay: " + animFile.getName());
        if (tcEffectConfig == null) {
            applyConfig();
        }
        if (animFile.getName().contains("video_mode_none")) {
            playerView.setVideoMode(TCEffectPlayerConstant.VideoMode.VIDEO_MODE_NONE);
        } else {
            playerView.setVideoMode(TCEffectPlayerConstant.VideoMode.VIDEO_MODE_SPLIT_HORIZONTAL);
        }
        int startResult = playerView.startPlay(animFile.getAbsolutePath());
        if (startResult != 0) {
            Toast.makeText(this, "startPlay failed: " + startResult, Toast.LENGTH_SHORT).show();
        }
    }

    private void onBtnPauseClicked() {
        appendLogs("[Click] Pause");
        if (playerView != null) {
            playerView.pause();
        }
    }

    private void onBtnResumeClicked() {
        appendLogs("[Click] Resume");
        if (playerView != null) {
            playerView.resume();
        }
    }

    private void onBtnStopPlayClicked() {
        appendLogs("[Click] StopPlay");
        if (playerView != null) {
            playerView.stopPlay(true);
            playerView.onDestroy();
        }
    }

    private void onBtnChangeAnimFilePathClicked() {
        curSelectedAnimFilePathIndex++;
        if (curSelectedAnimFilePathIndex >= animFiles.length()) {
            curSelectedAnimFilePathIndex = 0;
        }
        tvAnimFilePath.setText(animFiles.getAnimFileName(curSelectedAnimFilePathIndex));
    }

    private void onBtnSnapshotClicked() {
        Bitmap snapshot = playerView.snapshot();
        if (snapshot == null) {
            Log.d(TAG, "snapshot == null");
            return;
        }
        runOnUiThread(() -> {
            ivClickDisplay.setVisibility(View.VISIBLE);
            ivClickDisplay.setImageBitmap(snapshot);
        });
    }

    private void appendLogs(String logs) {
        tvLogs.append(logs + "\n");
        scrollLogs.post(() -> scrollLogs.fullScroll(ScrollView.FOCUS_DOWN));
    }
}
