// Copyright (c) 2026 Tencent. All rights reserved.

#import "ViewController.h"
#import "BackgroundView.h"
#import <TCEffectPlayer/TCEffectPlayerSDK.h>
#import <Masonry/Masonry.h>

/**
 * TCEffectPlayer iOS Demo
 *
 * 布局（从上到下）：
 *   - 棋盘格背景（白底 + 灰色格子）
 *   - 顶部栏（半透明黑 #80000000）： 返回 | 文件名 | 切换动画
 *   - TCEffectAnimView
 *   - 右上角半透明日志区（红色小字）
 *   - 融合资源点击展示（图片居中 / 文字顶部红色大字）
 *   - 底部控制面板覆盖层（半透明黑 #A0000000）：
 *       Codec Spinner 行                     [截图]
 *       Rate Spinner 行
 *       Rotation Spinner 行                  [isMute]
 *       ScaleType Spinner 行                 [isLoop]
 *       [StartPlay] [Pause] [Resume] [StopPlay]
 */
@interface ViewController () <TCEPAnimViewDelegate>

@property (nonatomic, strong) BackgroundView *bgView;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *panelOverlay;      // 底部半透明黑覆盖层

@property (nonatomic, strong) TCEffectAnimView *animView;
@property (nonatomic, strong) UIView *animBorderView;    // 红色边框
@property (nonatomic, strong) TCEffectConfig *playerConfig;

// 顶部
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *fileNameLabel;
@property (nonatomic, strong) UIButton *changeAnimButton;

// 下拉按钮
@property (nonatomic, strong) UILabel *codecLabel;
@property (nonatomic, strong) UIButton *codecSpinner;
@property (nonatomic, strong) UIButton *btnSnapshot;

@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UIButton *rateSpinner;

@property (nonatomic, strong) UILabel *rotationLabel;
@property (nonatomic, strong) UIButton *rotationSpinner;
@property (nonatomic, strong) UISwitch *muteSwitch;
@property (nonatomic, strong) UILabel *muteLabel;

@property (nonatomic, strong) UILabel *scaleLabel;
@property (nonatomic, strong) UIButton *scaleSpinner;
@property (nonatomic, strong) UISwitch *loopSwitch;
@property (nonatomic, strong) UILabel *loopLabel;

// 底部按钮
@property (nonatomic, strong) UIScrollView *btnScrollView;
@property (nonatomic, strong) UIButton *btnStart;
@property (nonatomic, strong) UIButton *btnPause;
@property (nonatomic, strong) UIButton *btnResume;
@property (nonatomic, strong) UIButton *btnStop;

// 日志 & 点击展示
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) UIImageView *clickImageView;
@property (nonatomic, strong) UILabel *clickTextLabel;

// 数据
@property (nonatomic, strong) NSArray<NSString *> *animFiles;
@property (nonatomic, assign) NSInteger curAnimIndex;

@property (nonatomic, strong) NSArray<NSString *> *scaleTypeItems;
@property (nonatomic, assign) NSInteger scaleIndex;

@property (nonatomic, strong) NSArray<NSString *> *rotationItems; // 字符串形式的 degrees
@property (nonatomic, assign) NSInteger rotationIndex;

@property (nonatomic, strong) NSArray<NSString *> *rateItems;
@property (nonatomic, assign) NSInteger rateIndex;

@property (nonatomic, strong) NSArray<NSString *> *codecItems;
@property (nonatomic, assign) NSInteger codecIndex;

@property (nonatomic, assign) BOOL needAutoResume;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.animFiles = @[@"demo", @"vap_car_ronghe", @"vap_king_ronghe"];
    self.curAnimIndex = 0;

    self.scaleTypeItems = @[@"CENTER_CROP", @"FIT_CENTER", @"FIT_XY", @"FIT_START", @"FIT_END"];
    self.scaleIndex = 1;

    self.rotationItems = @[@"-180", @"-90", @"0", @"90", @"180", @"270", @"360", @"450", @"540", @"630"];
    self.rotationIndex = 2;

    self.rateItems = @[@"0.5", @"1.0", @"1.5", @"2.0", @"2.5", @"3.0"];
    self.rateIndex = 1;

    self.codecItems = @[@"AVPlayer", @"VODPlayer"];
    self.codecIndex = 0;

    [self setupViews];
    [self setupLayout];
    [self applyConfig];
    [self refreshSpinnerTitles];

    [self appendLog:@"日志会在这里打印，长按可清除所有日志"];
    [self appendLog:[NSString stringWithFormat:@"SDK Version: %@", [TCEffectAnimView getSdkVersion]]];

    // 前后台切换
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_animView stopPlay];
}

- (void)onAppResignActive {
    if ([self.animView isPlaying]) {
        self.needAutoResume = YES;
        [self.animView pause];
    }
}

- (void)onAppEnterForeground {
    if (self.needAutoResume) {
        self.needAutoResume = NO;
        [self.animView resume];
    }
}

#pragma mark - Setup

- (void)setupViews {
    // 底层：棋盘格背景（覆盖整个屏幕）
    [self.view addSubview:self.bgView];

    // 顶部栏
    [self.view addSubview:self.topBar];
    [self.topBar addSubview:self.backButton];
    [self.topBar addSubview:self.fileNameLabel];
    [self.topBar addSubview:self.changeAnimButton];

    // 播放视图
    [self.view addSubview:self.animView];
    [self.view addSubview:self.animBorderView];
    [self.view addSubview:self.clickImageView];
    [self.view addSubview:self.clickTextLabel];

    // 日志（右上）
    [self.view addSubview:self.logView];

    // 底部控制面板覆盖层
    [self.view addSubview:self.panelOverlay];

    // Codec 行
    [self.panelOverlay addSubview:self.codecLabel];
    [self.panelOverlay addSubview:self.codecSpinner];
    [self.panelOverlay addSubview:self.btnSnapshot];
    // Rate 行
    [self.panelOverlay addSubview:self.rateLabel];
    [self.panelOverlay addSubview:self.rateSpinner];
    // Rotation 行
    [self.panelOverlay addSubview:self.rotationLabel];
    [self.panelOverlay addSubview:self.rotationSpinner];
    [self.panelOverlay addSubview:self.muteSwitch];
    [self.panelOverlay addSubview:self.muteLabel];
    // ScaleType 行
    [self.panelOverlay addSubview:self.scaleLabel];
    [self.panelOverlay addSubview:self.scaleSpinner];
    [self.panelOverlay addSubview:self.loopSwitch];
    [self.panelOverlay addSubview:self.loopLabel];

    // 底部按钮
    [self.panelOverlay addSubview:self.btnScrollView];
    [self.btnScrollView addSubview:self.btnStart];
    [self.btnScrollView addSubview:self.btnPause];
    [self.btnScrollView addSubview:self.btnResume];
    [self.btnScrollView addSubview:self.btnStop];
}

- (void)setupLayout {
    // 棋盘格背景
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    // 顶部栏
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topBar);
        make.left.equalTo(self.topBar).offset(4);
        make.height.mas_equalTo(32);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    [self.changeAnimButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topBar);
        make.right.equalTo(self.topBar).offset(-8);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(80);
    }];
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topBar);
        make.centerX.equalTo(self.topBar);
        make.left.greaterThanOrEqualTo(self.backButton.mas_right).offset(8);
        make.right.lessThanOrEqualTo(self.changeAnimButton.mas_left).offset(-8);
    }];

    // 底部控制面板覆盖层（固定高度）
    [self.panelOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];

    // ============== 4 行 Spinner ==============
    CGFloat rowH = 36;
    CGFloat labelW = 90;
    // Codec 行（最上）
    [self.codecLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.panelOverlay).offset(6);
        make.left.equalTo(self.panelOverlay).offset(8);
        make.width.mas_equalTo(labelW);
        make.height.mas_equalTo(rowH);
    }];
    [self.codecSpinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.codecLabel);
        make.left.equalTo(self.codecLabel.mas_right);
        make.height.mas_equalTo(rowH);
        make.width.mas_greaterThanOrEqualTo(110);
    }];
    [self.btnSnapshot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.codecLabel);
        make.right.equalTo(self.panelOverlay).offset(-8);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(28);
    }];
    // Rate 行
    [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.codecLabel.mas_bottom).offset(2);
        make.left.equalTo(self.codecLabel);
        make.size.equalTo(self.codecLabel);
    }];
    [self.rateSpinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rateLabel);
        make.left.equalTo(self.rateLabel.mas_right);
        make.height.mas_equalTo(rowH);
        make.width.mas_greaterThanOrEqualTo(70);
    }];
    // Rotation 行
    [self.rotationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rateLabel.mas_bottom).offset(2);
        make.left.equalTo(self.codecLabel);
        make.size.equalTo(self.codecLabel);
    }];
    [self.rotationSpinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rotationLabel);
        make.left.equalTo(self.rotationLabel.mas_right);
        make.height.mas_equalTo(rowH);
        make.width.mas_greaterThanOrEqualTo(70);
    }];
    [self.muteSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rotationLabel);
        make.right.equalTo(self.panelOverlay).offset(-8);
    }];
    [self.muteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rotationLabel);
        make.right.equalTo(self.muteSwitch.mas_left).offset(-4);
    }];
    // ScaleType 行
    [self.scaleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rotationLabel.mas_bottom).offset(2);
        make.left.equalTo(self.codecLabel);
        make.size.equalTo(self.codecLabel);
    }];
    [self.scaleSpinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scaleLabel);
        make.left.equalTo(self.scaleLabel.mas_right);
        make.height.mas_equalTo(rowH);
        make.width.mas_greaterThanOrEqualTo(120);
    }];
    [self.loopSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scaleLabel);
        make.right.equalTo(self.panelOverlay).offset(-8);
    }];
    [self.loopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scaleLabel);
        make.right.equalTo(self.loopSwitch.mas_left).offset(-4);
    }];

    // 底部按钮横向滚动
    [self.btnScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scaleLabel.mas_bottom).offset(4);
        make.left.right.equalTo(self.panelOverlay);
        make.bottom.equalTo(self.panelOverlay).offset(-4);
        make.height.mas_equalTo(38);
    }];
    CGFloat btnH = 32;
    CGFloat btnW = 86;
    [self.btnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnScrollView).offset(4);
        make.centerY.equalTo(self.btnScrollView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];
    [self.btnPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnStart.mas_right).offset(6);
        make.centerY.equalTo(self.btnScrollView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];
    [self.btnResume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnPause.mas_right).offset(6);
        make.centerY.equalTo(self.btnScrollView);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];
    [self.btnStop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.btnResume.mas_right).offset(6);
        make.centerY.equalTo(self.btnScrollView);
        make.right.equalTo(self.btnScrollView).offset(-4);
        make.width.mas_equalTo(btnW);
        make.height.mas_equalTo(btnH);
    }];

    // 播放视图：顶栏下 ~ 控制面板上
    [self.animView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom).offset(5);
        make.left.equalTo(self.view).offset(5);
        make.right.equalTo(self.view).offset(-5);
        make.bottom.equalTo(self.panelOverlay.mas_top).offset(-5);
    }];
    [self.animBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.animView);
    }];

    // 日志（右上角）
    [self.logView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom);
        make.right.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.5);
        make.height.equalTo(self.view).multipliedBy(0.2);
    }];

    // 融合资源点击展示
    [self.clickImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.5);
        make.height.equalTo(self.clickImageView.mas_width);
    }];
    [self.clickTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
    }];
}

#pragma mark - Config

- (void)applyConfig {
    if (!_playerConfig) {
        _playerConfig = [[TCEffectConfig alloc] init];
    }
    _playerConfig.vapEngineType = (self.codecIndex == 1) ? TCEPCodecTypeVODPlayer : TCEPCodecTypeAVPlayer;
    _playerConfig.freezeFrame = FRAME_LAST;
    _playerConfig.enableProgressCallback = YES;
    _playerConfig.enableFrameRenderCallback = YES;
    _playerConfig.progressCallbackIntervalMs = 200;
    [self.animView setEffectPlayerConfig:_playerConfig];
}

- (void)refreshSpinnerTitles {
    [self.codecSpinner    setTitle:self.codecItems[self.codecIndex]       forState:UIControlStateNormal];
    [self.rateSpinner     setTitle:self.rateItems[self.rateIndex]         forState:UIControlStateNormal];
    [self.rotationSpinner setTitle:self.rotationItems[self.rotationIndex] forState:UIControlStateNormal];
    [self.scaleSpinner    setTitle:self.scaleTypeItems[self.scaleIndex]   forState:UIControlStateNormal];
    self.fileNameLabel.text = [self.animFiles[self.curAnimIndex] stringByAppendingString:@".mp4"];
}

#pragma mark - Spinner (ActionSheet)

- (void)showPicker:(UIButton *)sender
             title:(NSString *)title
             items:(NSArray<NSString *> *)items
          selected:(NSInteger)selected
           onPick:(void(^)(NSInteger idx))onPick {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < items.count; i++) {
        NSString *display = (i == selected) ? [NSString stringWithFormat:@"✓ %@", items[i]] : items[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:display
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_) {
            if (onPick) onPick(i);
        }];
        [alert addAction:action];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    // iPad 兼容
    alert.popoverPresentationController.sourceView = sender;
    alert.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Spinner click handlers

- (void)onCodecSpinnerTapped {
    __weak typeof(self) ws = self;
    [self showPicker:self.codecSpinner title:@"Codec" items:self.codecItems selected:self.codecIndex onPick:^(NSInteger idx) {
        ws.codecIndex = idx;
        [ws.animView stopPlay];
        [ws applyConfig];
        [ws refreshSpinnerTitles];
        [ws appendLog:[NSString stringWithFormat:@"Codec = %@（下次 startPlay() 时生效）", ws.codecItems[idx]]];
    }];
}

- (void)onRateSpinnerTapped {
    __weak typeof(self) ws = self;
    [self showPicker:self.rateSpinner title:@"Rate" items:self.rateItems selected:self.rateIndex onPick:^(NSInteger idx) {
        ws.rateIndex = idx;
        float r = [ws.rateItems[idx] floatValue];
        [ws.animView setRate:r];
        [ws refreshSpinnerTitles];
        [ws appendLog:[NSString stringWithFormat:@"Rate = %.1f（已生效）", r]];
    }];
}

- (void)onRotationSpinnerTapped {
    __weak typeof(self) ws = self;
    [self showPicker:self.rotationSpinner title:@"Rotation" items:self.rotationItems selected:self.rotationIndex onPick:^(NSInteger idx) {
        ws.rotationIndex = idx;
        NSInteger degree = [ws.rotationItems[idx] integerValue];
        [ws.animView setRenderRotation:[ws orientationForDegree:degree]];
        [ws refreshSpinnerTitles];
        [ws appendLog:[NSString stringWithFormat:@"Rotation = %ld°（下次 startPlay() 时生效）", (long)degree]];
    }];
}

- (void)onScaleSpinnerTapped {
    __weak typeof(self) ws = self;
    [self showPicker:self.scaleSpinner title:@"ScaleType" items:self.scaleTypeItems selected:self.scaleIndex onPick:^(NSInteger idx) {
        ws.scaleIndex = idx;
        [ws.animView setRenderMode:[ws contentModeForScaleType:ws.scaleTypeItems[idx]]];
        [ws refreshSpinnerTitles];
        [ws appendLog:[NSString stringWithFormat:@"ScaleType = %@（下次 startPlay() 时生效）", ws.scaleTypeItems[idx]]];
    }];
}

// ScaleType 映射（iOS 只有 3 种，不支持的 fallback 到 AspectFit）
- (TCEPVPViewContentMode)contentModeForScaleType:(NSString *)s {
    if ([s isEqualToString:@"FIT_XY"])       return TCEPVPViewContentModeScaleToFill;
    if ([s isEqualToString:@"CENTER_CROP"])  return TCEPVPViewContentModeAspectFill;
    return TCEPVPViewContentModeAspectFit; // FIT_CENTER / FIT_START / FIT_END
}

// Rotation 映射：iOS 的 HomeOrientation 只有 4 个方向，按 degree % 360 取最近
- (TCEP_Enum_Type_HomeOrientation)orientationForDegree:(NSInteger)degree {
    NSInteger d = ((degree % 360) + 360) % 360;
    switch (d) {
        case 90:  return TCEP_HOME_ORIENTATION_LEFT;
        case 180: return TCEP_HOME_ORIENTATION_UP;
        case 270: return TCEP_HOME_ORIENTATION_RIGHT;
        default:  return TCEP_HOME_ORIENTATION_DOWN; // 0 / 360
    }
}

#pragma mark - Switch / Button actions

- (void)onLoopChanged {
    [self.animView setLoop:self.loopSwitch.isOn];
    [self appendLog:[NSString stringWithFormat:@"Loop = %@（已生效）", self.loopSwitch.isOn ? @"true" : @"false"]];
}

- (void)onMuteChanged {
    [self.animView setMute:self.muteSwitch.isOn];
    [self appendLog:[NSString stringWithFormat:@"Mute = %@（已生效）", self.muteSwitch.isOn ? @"true" : @"false"]];
}

- (void)onBackTapped {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onChangeAnim {
    self.curAnimIndex = (self.curAnimIndex + 1) % self.animFiles.count;
    [self refreshSpinnerTitles];
}

- (void)onStartTapped {
    NSString *name = self.animFiles[self.curAnimIndex];
    NSString *url = [[NSBundle mainBundle] pathForResource:name ofType:@"mp4"];
    if (!url) {
        [self appendLog:[NSString stringWithFormat:@"[ERROR] 资源不存在: %@.mp4", name]];
        return;
    }
    [self appendLog:[NSString stringWithFormat:@"[Click] StartPlay: %@.mp4", name]];

    // 下次生效的参数在这里统一应用
    [self.animView setRenderMode:[self contentModeForScaleType:self.scaleTypeItems[self.scaleIndex]]];
    NSInteger degree = [self.rotationItems[self.rotationIndex] integerValue];
    [self.animView setRenderRotation:[self orientationForDegree:degree]];
    [self.animView startPlay:url];
}

- (void)onPauseTapped {
    [self appendLog:@"[Click] Pause"];
    [self.animView pause];
}

- (void)onResumeTapped {
    [self appendLog:@"[Click] Resume"];
    [self.animView resume];
}

- (void)onStopTapped {
    [self appendLog:@"[Click] StopPlay"];
    [self.animView stopPlay];
}

- (void)onSnapshotTapped {
    UIImage *snap = [self.animView snapshot];
    if (snap) {
        [self appendLog:[NSString stringWithFormat:@"Snapshot size=%@", NSStringFromCGSize(snap.size)]];
        self.clickImageView.image = snap;
        self.clickImageView.hidden = NO;
    } else {
        [self appendLog:@"Snapshot == nil"];
    }
}

- (void)onLogLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.logView.text = @"";
    }
}

- (void)onClickDisplayTapped {
    self.clickImageView.hidden = YES;
}

#pragma mark - Log

- (void)appendLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = self.logView.text ?: @"";
        self.logView.text = [NSString stringWithFormat:@"%@%@\n", text, log];
        if (self.logView.text.length > 0) {
            [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length - 1, 1)];
        }
    });
}

#pragma mark - TCEPAnimViewDelegate

- (void)onPlayEvent:(ITCEffectPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param {
    if (EvtID == TCEP_PLAYER_EVT_VIDEO_RENDER_PROGRESS) {
        NSInteger frameIndex = [param[TCEPEventFrameIndexKey] integerValue];
        NSLog(@"Frame render idx=%ld", (long)frameIndex);
    } else {
        NSLog(@"onPlayEvent EvtID=%d, param=%@", EvtID, param);
    }
}

- (void)tcePlayerStart:(ITCEffectPlayer *)player {
    [self appendLog:@"[Delegate] onPlayStart"];
    TCEffectAnimInfo *info = [self.animView getAnimInfo];
    if (info) {
        [self appendLog:[NSString stringWithFormat:@"AnimInfo type=%d, %dx%d, duration=%ld",
                         (int)info.resType, info.width, info.height, info.duration]];
    }
}

- (void)tcePlayerEnd:(ITCEffectPlayer *)player {
    [self appendLog:@"[Delegate] onPlayEnd"];
}

- (void)tcePlayerTagTouchBegan:(ITCEffectPlayer *)player tag:(NSString *)tag {
    [self appendLog:[NSString stringWithFormat:@"[Delegate] Tag Clicked: %@", tag]];
    self.clickTextLabel.hidden = NO;
    self.clickTextLabel.text = tag ?: @"";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        self.clickTextLabel.hidden = YES;
    });
}

- (void)tcePlayerError:(ITCEffectPlayer *)player error:(NSError *)error {
    [self appendLog:[NSString stringWithFormat:@"[Delegate] onPlayError: %@", error]];
}

#pragma mark - 融合资源回调

- (void)loadImageForPlayer:(ITCEffectPlayer *)player
                   context:(NSDictionary *)context
                completion:(void (^)(UIImage *image, NSError *error))completionBlock {
     // 获取到当前需要替换的图片对应的 tag，然后根据 tag 返回图片
    NSString *tag = context[TCEPContextSourceTypeImageIndex]; 

    NSString *imgName = (arc4random_uniform(2) == 0) ? @"demo_avatar_earphone" : @"demo_avatar_car";
    NSString *path = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
    UIImage *img = path ? [UIImage imageWithContentsOfFile:path] : nil;
    if (!img) {
        // fallback：纯色占位，避免 completion 不回调导致融合层不渲染
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, 1);
        [[UIColor orangeColor] setFill];
        UIRectFill(CGRectMake(0, 0, 120, 120));
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    if (completionBlock) completionBlock(img, nil);
}

- (TCEffectText *)loadTextForPlayer:(ITCEffectPlayer *)player withTag:(NSString *)tag {
    TCEffectText *effectText = [[TCEffectText alloc] init];
    effectText.text = [NSString stringWithFormat:@"test-%@", tag ?: @""];
    effectText.fontStyle = @"bold";
    effectText.color = [UIColor whiteColor];
    return effectText;
}

#pragma mark - Lazy load — views

- (BackgroundView *)bgView {
    if (!_bgView) {
        _bgView = [[BackgroundView alloc] init];
    }
    return _bgView;
}

- (UIView *)topBar {
    if (!_topBar) {
        _topBar = [[UIView alloc] init];
        _topBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5]; // #80000000
    }
    return _topBar;
}

- (UIView *)panelOverlay {
    if (!_panelOverlay) {
        _panelOverlay = [[UIView alloc] init];
        _panelOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.63]; // #A0000000
    }
    return _panelOverlay;
}

- (TCEffectAnimView *)animView {
    if (!_animView) {
        _animView = [[TCEffectAnimView alloc] initWithFrame:CGRectZero];
        _animView.backgroundColor = [UIColor clearColor];
        _animView.effectPlayerDelegate = self;
        _animView.loop = NO;
        [_animView setRenderMode:TCEPVPViewContentModeAspectFit];
    }
    return _animView;
}

- (UIView *)animBorderView {
    if (!_animBorderView) {
        _animBorderView = [[UIView alloc] init];
        _animBorderView.userInteractionEnabled = NO;
        _animBorderView.backgroundColor = [UIColor clearColor];
        _animBorderView.layer.borderColor = [UIColor redColor].CGColor;
        _animBorderView.layer.borderWidth = 1.0;
    }
    return _animBorderView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backButton setTitle:@"← 返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_backButton addTarget:self action:@selector(onBackTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)changeAnimButton {
    if (!_changeAnimButton) {
        _changeAnimButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_changeAnimButton setTitle:@"切换动画" forState:UIControlStateNormal];
        [_changeAnimButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _changeAnimButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _changeAnimButton.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
        _changeAnimButton.layer.cornerRadius = 2;
        _changeAnimButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_changeAnimButton addTarget:self action:@selector(onChangeAnim) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeAnimButton;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.textAlignment = NSTextAlignmentCenter;
        _fileNameLabel.textColor = [UIColor whiteColor];
        _fileNameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    }
    return _fileNameLabel;
}

#pragma mark - Spinner labels & buttons

- (UILabel *)codecLabel    { if (!_codecLabel)    _codecLabel    = [self makeTitleLabel:@"Codec: "];     return _codecLabel; }
- (UILabel *)rateLabel     { if (!_rateLabel)     _rateLabel     = [self makeTitleLabel:@"Rate: "];      return _rateLabel; }
- (UILabel *)rotationLabel { if (!_rotationLabel) _rotationLabel = [self makeTitleLabel:@"Rotation: "];  return _rotationLabel; }
- (UILabel *)scaleLabel    { if (!_scaleLabel)    _scaleLabel    = [self makeTitleLabel:@"ScaleType: "]; return _scaleLabel; }
- (UILabel *)muteLabel     { if (!_muteLabel)     _muteLabel     = [self makeTitleLabel:@"isMute"];      return _muteLabel; }
- (UILabel *)loopLabel     { if (!_loopLabel)     _loopLabel     = [self makeTitleLabel:@"isLoop"];      return _loopLabel; }

- (UILabel *)makeTitleLabel:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:14];
    return lbl;
}

- (UIButton *)codecSpinner {
    if (!_codecSpinner) {
        _codecSpinner = [self makeSpinnerButton];
        [_codecSpinner addTarget:self action:@selector(onCodecSpinnerTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _codecSpinner;
}

- (UIButton *)rateSpinner {
    if (!_rateSpinner) {
        _rateSpinner = [self makeSpinnerButton];
        [_rateSpinner addTarget:self action:@selector(onRateSpinnerTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateSpinner;
}

- (UIButton *)rotationSpinner {
    if (!_rotationSpinner) {
        _rotationSpinner = [self makeSpinnerButton];
        [_rotationSpinner addTarget:self action:@selector(onRotationSpinnerTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotationSpinner;
}

- (UIButton *)scaleSpinner {
    if (!_scaleSpinner) {
        _scaleSpinner = [self makeSpinnerButton];
        [_scaleSpinner addTarget:self action:@selector(onScaleSpinnerTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scaleSpinner;
}

// 下拉按钮（底色白、黑字、底部下划线）
- (UIButton *)makeSpinnerButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 20);
    // 右侧▼
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectZero];
    arrow.tintColor = [UIColor whiteColor];
    arrow.translatesAutoresizingMaskIntoConstraints = NO;
    arrow.contentMode = UIViewContentModeCenter;
    arrow.image = [self triangleDownImage];
    [btn addSubview:arrow];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btn).offset(-4);
        make.centerY.equalTo(btn);
        make.width.height.mas_equalTo(10);
    }];
    // 底部下划线
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor whiteColor];
    [btn addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(btn);
        make.height.mas_equalTo(0.5);
    }];
    return btn;
}

- (UIImage *)triangleDownImage {
    CGSize size = CGSizeMake(10, 6);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, size.width, 0);
    CGContextAddLineToPoint(ctx, size.width/2, size.height);
    CGContextClosePath(ctx);
    [[UIColor whiteColor] setFill];
    CGContextFillPath(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - Switch

- (UISwitch *)loopSwitch {
    if (!_loopSwitch) {
        _loopSwitch = [[UISwitch alloc] init];
        _loopSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        [_loopSwitch addTarget:self action:@selector(onLoopChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _loopSwitch;
}

- (UISwitch *)muteSwitch {
    if (!_muteSwitch) {
        _muteSwitch = [[UISwitch alloc] init];
        _muteSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        [_muteSwitch addTarget:self action:@selector(onMuteChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _muteSwitch;
}

#pragma mark - Action buttons

- (UIButton *)btnStart {
    if (!_btnStart) {
        _btnStart = [self makeFlatButtonWithTitle:@"StartPlay" action:@selector(onStartTapped)];
    }
    return _btnStart;
}

- (UIButton *)btnPause {
    if (!_btnPause) {
        _btnPause = [self makeFlatButtonWithTitle:@"Pause" action:@selector(onPauseTapped)];
    }
    return _btnPause;
}

- (UIButton *)btnResume {
    if (!_btnResume) {
        _btnResume = [self makeFlatButtonWithTitle:@"Resume" action:@selector(onResumeTapped)];
    }
    return _btnResume;
}

- (UIButton *)btnStop {
    if (!_btnStop) {
        _btnStop = [self makeFlatButtonWithTitle:@"StopPlay" action:@selector(onStopTapped)];
    }
    return _btnStop;
}

- (UIButton *)btnSnapshot {
    if (!_btnSnapshot) {
        _btnSnapshot = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnSnapshot setTitle:@"截图" forState:UIControlStateNormal];
        [_btnSnapshot setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnSnapshot.titleLabel.font = [UIFont systemFontOfSize:10];
        _btnSnapshot.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        _btnSnapshot.layer.cornerRadius = 2;
        [_btnSnapshot addTarget:self action:@selector(onSnapshotTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSnapshot;
}

// 扁平按钮（浅灰底 + 黑字）
- (UIButton *)makeFlatButtonWithTitle:(NSString *)title action:(SEL)sel {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    btn.layer.cornerRadius = 2;
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIScrollView *)btnScrollView {
    if (!_btnScrollView) {
        _btnScrollView = [[UIScrollView alloc] init];
        _btnScrollView.showsHorizontalScrollIndicator = NO;
        _btnScrollView.alwaysBounceHorizontal = YES;
    }
    return _btnScrollView;
}

#pragma mark - Log & click display

- (UITextView *)logView {
    if (!_logView) {
        _logView = [[UITextView alloc] init];
        // 半透明黑底 #A0000000 + 红色小字
        _logView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.63];
        _logView.textColor = [UIColor redColor];
        _logView.font = [UIFont systemFontOfSize:9];
        _logView.editable = NO;
        _logView.textContainerInset = UIEdgeInsetsMake(2, 4, 2, 4);
        UILongPressGestureRecognizer *g = [[UILongPressGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(onLogLongPress:)];
        [_logView addGestureRecognizer:g];
    }
    return _logView;
}

- (UIImageView *)clickImageView {
    if (!_clickImageView) {
        _clickImageView = [[UIImageView alloc] init];
        _clickImageView.contentMode = UIViewContentModeScaleAspectFit;
        _clickImageView.userInteractionEnabled = YES;
        _clickImageView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(onClickDisplayTapped)];
        [_clickImageView addGestureRecognizer:tap];
    }
    return _clickImageView;
}

- (UILabel *)clickTextLabel {
    if (!_clickTextLabel) {
        _clickTextLabel = [[UILabel alloc] init];
        _clickTextLabel.textColor = [UIColor redColor];
        _clickTextLabel.font = [UIFont systemFontOfSize:28];
        _clickTextLabel.hidden = YES;
    }
    return _clickTextLabel;
}

@end
