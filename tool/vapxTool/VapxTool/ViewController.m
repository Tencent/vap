// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
//
// Licensed under the MIT License (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

#import "ViewController.h"
#import "VapxProcessor.h"
#import "VapMergeInfoView.h"
#import "VapProgressHUD.h"

@interface ViewController () <VapMergeInfoViewDelegate>

@property (nonatomic, strong) VapxFileHelper *fileHelper;
@property (nonatomic, strong) NSMutableArray<VapMergeInfoView *> *mergeInfoViews;
@property (weak) IBOutlet NSTextField *basicInfoLabel;
@property (strong) IBOutlet NSView *uploadFramesButton;
@property (weak) IBOutlet NSTextField *uploadFramesTipsLabel;
@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSTextField *fpsLabel;
@property (weak) IBOutlet NSTextField *bitRateLabel;
@property (weak) IBOutlet NSTextField *alphaScaleLabel;
@property (weak) IBOutlet NSButton *addMergeInfoButton;
@property (weak) IBOutlet NSTextField *mergeInfoLabel;
@property (weak) IBOutlet NSView *mergeInfoArea;
@property (weak) IBOutlet NSTextField *addMergeInfoLabel;
@property (weak) IBOutlet NSButton *uploadAudioButton;

@property (nonatomic, assign) BOOL hasUploadedVideoFrames;
@property (nonatomic, strong) NSString *audioPath;

@property (nonatomic, assign) BOOL classicMode;

@property (nonatomic, assign) NSEdgeInsets layoutPadding;

@end

@implementation ViewController



- (IBAction)onClassicModeButtonClicked:(NSButton *)sender {
    
    if (sender.state == NSControlStateValueOn) {
        self.classicMode = YES;
    } else {
        self.classicMode = NO;
    }
    [self refreshUIForClassicMode];
}

- (void)refreshUIForClassicMode {
    
    if (self.classicMode) {
        self.alphaScaleLabel.stringValue = @"1.0";
        self.addMergeInfoButton.enabled = NO;
        [self.mergeInfoViews enumerateObjectsUsingBlock:^(VapMergeInfoView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [self.mergeInfoViews removeAllObjects];
        [self rearrangeMergeInfoArea];
        self.layoutPadding = NSEdgeInsetsZero;
        self.alphaScaleLabel.enabled = NO;
    } else {
        self.addMergeInfoButton.enabled = YES;
        self.layoutPadding = NSEdgeInsetsMake(4, 4, 4, 4);
        self.alphaScaleLabel.enabled = YES;
    }
}

- (IBAction)onOpenOuputFolderBtnClicked:(id)sender {
    
    NSString *output = _fileHelper.outputPath;
    NSURL *folderURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",output]];
    [[NSWorkspace sharedWorkspace] openURL:folderURL];
}

- (IBAction)onGenerateButtonClick:(id)sender {
    
    NSString *errorString = [self checkInputingValid];
    if (errorString) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"生成vap文件失败"];
        [alert setInformativeText:errorString];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return ;
    }
    
    VapxProcessor *processor = [VapxProcessor new];
    processor.fileHelper = _fileHelper;
    processor.version = [_versionLabel.stringValue integerValue];
    processor.fps = [_fpsLabel.stringValue integerValue];
    processor.bitrates = [_bitRateLabel.stringValue integerValue];
    processor.alphaScale = [_alphaScaleLabel.stringValue floatValue];
    processor.mergeInfoViews = _mergeInfoViews;
    processor.audioPath = self.audioPath;
    processor.layoutPadding = self.layoutPadding;
    processor.classicMode = self.classicMode;
    
    VapProgressHUD *hud = [VapProgressHUD showHUDToSuperView:self.view];
    
    [processor process:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.currentValue = progress*100;
        });
    } onCompletion:^(BOOL success, NSString *output, NSError *error) {
        hud.currentValue = 100;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide];
        });
        
        if (!success || error) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"生成vap文件失败"];
            error = error ?: [NSError errorWithDomain:@"未知错误" code:-1 userInfo:nil];
            [alert setInformativeText:error.localizedDescription];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"生成vap文件成功！"];
            [alert setInformativeText:output];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
            NSURL *folderURL = [[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",output]] URLByDeletingLastPathComponent];
            [[NSWorkspace sharedWorkspace] openURL:folderURL];
        }
    }];
}

- (IBAction)addMergeInfoAreaDidClicked:(id)sender {
    
    VapMergeInfoView *mergInfoView = [[VapMergeInfoView alloc] initWithFrame:NSMakeRect(0, 0, 900, 60)];
    mergInfoView.delegate = self;
    mergInfoView.fileHelper = _fileHelper;
    [_mergeInfoViews addObject:mergInfoView];
    [self rearrangeMergeInfoArea];
    [self.mergeInfoArea addSubview:mergInfoView];
}

- (void)rearrangeMergeInfoArea {
    
    CGFloat singleHeight = 70;
    CGFloat height = _mergeInfoViews.count*singleHeight;
    self.mergeInfoArea.frame = NSMakeRect(CGRectGetMinX(self.mergeInfoArea.frame), CGRectGetMaxY(self.mergeInfoLabel.frame)-height, CGRectGetWidth(self.mergeInfoArea.frame), height);
    
    __weak __typeof(_mergeInfoViews) weakInfoViews = _mergeInfoViews;
    [_mergeInfoViews enumerateObjectsUsingBlock:^(VapMergeInfoView * _Nonnull mergeView, NSUInteger idx, BOOL * _Nonnull stop) {
        [mergeView setIndex:idx+1];
        mergeView.frame = NSMakeRect(0, (weakInfoViews.count-1-idx)*singleHeight, 900, singleHeight);
    }];
    
    self.addMergeInfoButton.frame = NSMakeRect(CGRectGetMinX(self.addMergeInfoButton.frame), CGRectGetMinY(self.mergeInfoArea.frame)-CGRectGetHeight(self.addMergeInfoButton.frame), CGRectGetWidth(self.addMergeInfoButton.frame), CGRectGetHeight(self.addMergeInfoButton.frame));
    self.addMergeInfoLabel.frame = NSMakeRect(CGRectGetMinX(self.addMergeInfoLabel.frame), CGRectGetMinY(self.mergeInfoArea.frame)-CGRectGetHeight(self.addMergeInfoButton.frame)/2.0-CGRectGetHeight(self.addMergeInfoLabel.frame)/2.0, CGRectGetWidth(self.addMergeInfoLabel.frame), CGRectGetHeight(self.addMergeInfoLabel.frame));
}
- (IBAction)uploadAudioButtonDidClick:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel new];
    openPanel.allowsMultipleSelection = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    NSModalResponse res = [openPanel runModal];
    if (res == NSModalResponseOK) {
        NSString *audioPath = [self.fileHelper saveUploadedAudioFile:openPanel.URL];
        self.audioPath = audioPath;
        self.uploadAudioButton.title = @"上传成功";
    } else {
        self.audioPath = nil;
        self.uploadAudioButton.title = @"error, retry";
    }
}

- (IBAction)uploadFramesButtonDidClick:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel new];
    openPanel.allowsMultipleSelection = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    NSModalResponse res = [openPanel runModal];
    if (res == NSModalResponseOK) {
        [self.fileHelper saveUploadedVideoFrames:openPanel.URLs];
        self.uploadFramesTipsLabel.stringValue = [NSString stringWithFormat:@"成功上传%@个文件",@(openPanel.URLs.count)];
        [self.uploadFramesTipsLabel sizeToFit];
        self.uploadFramesTipsLabel.hidden = NO;
        self.hasUploadedVideoFrames = YES;
    } else {
        self.hasUploadedVideoFrames = NO;
    }
}

- (IBAction)openSourceInfoButtonDidClicked:(id)sender {
    NSString *documentsPath = [[NSBundle mainBundle] pathForResource:@"Draft_License_VAP_HK20200804" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:documentsPath encoding:NSUTF8StringEncoding error:nil];

    CGFloat width = 600;
    CGFloat height = 400;

    NSTextView *accessory = [[NSTextView alloc] initWithFrame:NSMakeRect(0,0,width,height)];
    NSFont *font =[NSFont systemFontOfSize:[NSFont systemFontSize]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [accessory insertText:[[NSAttributedString alloc] initWithString:content attributes:textAttributes] replacementRange:NSMakeRange(0, content.length)];
    [accessory setEditable:NO];
    [accessory setDrawsBackground:NO];
    [accessory setSelectable:NO];

    NSScrollView*scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
    [scrollView setDocumentView:accessory];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSNoBorder];

    NSWindow *mFileInfoWindow= [[NSWindow alloc] initWithContentRect:NSMakeRect(800, 600, width, height)  styleMask:NSWindowStyleMaskTitled |NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
    NSView *contentView = [mFileInfoWindow contentView];
    [contentView addSubview:scrollView];

    //[[NSApplication sharedApplication] runModalForWindow:mFileInfoWindow];
    
    NSWindowController *vc = [[NSWindowController alloc] initWithWindow:mFileInfoWindow];
    [vc showWindow:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mergeInfoViews = [NSMutableArray new];
    self.fileHelper = [VapxFileHelper new];
    [self.fileHelper clearCurrentWorkSpace];
    [self.fileHelper createCurrentWorkSpaceIfNeed];
    self.uploadFramesTipsLabel.hidden = YES;
    [self setupUIComponents];
    self.layoutPadding = NSEdgeInsetsMake(4, 4, 4, 4);
}

- (void)setupUIComponents {
    
    self.generateButton.layer.zPosition = 1000;
    [self.generateButton.cell setBackgroundColor:[NSColor colorWithRed:299/255.0 green:133/255.0 blue:61/255.0 alpha:1]];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (void)didClickAtCloseButton:(VapMergeInfoView *)view {
    
    [view removeFromSuperview];
    [_mergeInfoViews removeObject:view];
    [self rearrangeMergeInfoArea];
}

- (NSString *)checkInputingValid {
    
    if (_versionLabel.stringValue.length == 0) {
        return @"版本号不能为空!";
    }
    if (_fpsLabel.stringValue.length == 0) {
        return @"fps不能为空!";
    }
    if (_bitRateLabel.stringValue.length == 0) {
        return @"码率不能为空!";
    }
    if (_alphaScaleLabel.stringValue.length == 0) {
        return @"alphaScale不能为空!";
    }
    if (!self.hasUploadedVideoFrames) {
        return @"请上传视频帧!";
    }
    
    for (int i = 0; i < self.mergeInfoViews.count; i++) {
        VapMergeInfoView *mergeInfoView = self.mergeInfoViews[i];
        if (mergeInfoView.tagLabel.stringValue.length == 0) {
            return [@"占位符不能为空!" stringByAppendingString:[NSString stringWithFormat:@"-第%@个遮罩",@(i+1)]];
        }
        if (mergeInfoView.widthLabel.stringValue.length == 0) {
            return [@"宽度不能为空!" stringByAppendingString:[NSString stringWithFormat:@"-第%@个遮罩",@(i+1)]];
        }
        if (mergeInfoView.tagLabel.stringValue.length == 0) {
            return [@"高度不能为空!" stringByAppendingString:[NSString stringWithFormat:@"-第%@个遮罩",@(i+1)]];
        }
        if (mergeInfoView.maskPath.length == 0) {
            return [@"请上传遮罩文件!" stringByAppendingString:[NSString stringWithFormat:@"-第%@个遮罩",@(i+1)]];
        }
        if ([mergeInfoView.resTypePopButton.selectedItem.title isEqualToString:@"文字"]) {
            if (mergeInfoView.colorLabel.stringValue.length == 0) {
                return [@"文字颜色不能为空!" stringByAppendingString:[NSString stringWithFormat:@"-第%@个遮罩",@(i+1)]];
            }
        }
    }
    
    return nil;
}

@end
