// ViewController.m
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
#import "UIView+VAP.h"
#import "QGVAPWrapView.h"

@interface ViewController () <HWDMP4PlayDelegate, VAPWrapViewDelegate>

@property (nonatomic, strong) UIButton *vapButton;
@property (nonatomic, strong) UIButton *vapxButton;
@property (nonatomic, strong) UIButton *vapWrapViewButton;

@property (nonatomic, strong) VAPView *vapView;

@end

@implementation ViewController

//日志接口
void qg_VAP_Logger_handler(VAPLogLevel level, const char* file, int line, const char* func, NSString *module, NSString *format, ...) {
    
    if (format.UTF8String == nil) {
        NSLog(@"log包含非utf-8字符");
        return;
    }
    if (level > VAPLogLevelDebug) {
        va_list argList;
        va_start(argList, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
        file = [NSString stringWithUTF8String:file].lastPathComponent.UTF8String;
        NSLog(@"<%@> %s(%@):%s [%@] - %@",@(level), file, @(line), func, module, message);
        va_end(argList);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //日志
    [UIView registerHWDLog:qg_VAP_Logger_handler];
    
    //vap-经典效果
    _vapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 90)];
    _vapButton.backgroundColor = [UIColor lightGrayColor];
    [_vapButton setTitle:@"电竞方案" forState:UIControlStateNormal];
    [_vapButton addTarget:self action:@selector(playVap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_vapButton];
    
    //vapx-融合效果
    _vapxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_vapButton.frame)+60, CGRectGetWidth(self.view.frame), 90)];
    _vapxButton.backgroundColor = [UIColor lightGrayColor];
    [_vapxButton setTitle:@"融合特效" forState:UIControlStateNormal];
    [_vapxButton addTarget:self action:@selector(playVapx) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_vapxButton];
    
    //使用WrapView，支持ContentMode
    _vapWrapViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_vapxButton.frame)+60, CGRectGetWidth(self.view.frame), 90)];
    _vapWrapViewButton.backgroundColor = [UIColor lightGrayColor];
    [_vapWrapViewButton setTitle:@"WrapView-ContentMode" forState:UIControlStateNormal];
    [_vapWrapViewButton addTarget:self action:@selector(playVapWithWrapView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_vapWrapViewButton];
}

#pragma mark - 各种类型的播放

- (void)playVap {
    VAPView *mp4View = [[VAPView alloc] initWithFrame:CGRectMake(0, 0, 752/2, 752/2)];
    //默认使用metal渲染，使用OpenGL请打开下面这个开关
    //mp4View.renderByOpenGL = YES;
    mp4View.center = self.view.center;
    [self.view addSubview:mp4View];
    mp4View.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageviewTap:)];
    [mp4View addGestureRecognizer:tap];
    NSString *resPath = [NSString stringWithFormat:@"%@/Resource/demo.mp4", [[NSBundle mainBundle] resourcePath]];
    //单纯播放的接口
    //[mp4View playHWDMp4:resPath];
    //指定素材混合模式，重复播放次数，delegate的接口
    [mp4View playHWDMP4:resPath repeatCount:-1 delegate:self];
}

//vap动画
- (void)playVapx {
    NSString *mp4Path = [NSString stringWithFormat:@"%@/Resource/vap.mp4", [[NSBundle mainBundle] resourcePath]];
    VAPView *mp4View = [[VAPView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mp4View];
    mp4View.center = self.view.center;
    mp4View.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageviewTap:)];
    [mp4View addGestureRecognizer:tap];
    [mp4View playHWDMP4:mp4Path repeatCount:-1 delegate:self];
}

/// 使用WrapView，支持ContentMode
- (void)playVapWithWrapView {
    QGVAPWrapView *wrapView = [[QGVAPWrapView alloc] initWithFrame:self.view.bounds];
    wrapView.center = self.view.center;
    wrapView.contentMode = QGVAPWrapViewContentModeAspectFit;
    [self.view addSubview:wrapView];
    NSString *resPath = [NSString stringWithFormat:@"%@/Resource/demo.mp4", [[NSBundle mainBundle] resourcePath]];
    [wrapView vapWrapView_playHWDMP4:resPath repeatCount:-1 delegate:self];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageviewTap:)];
    [wrapView addGestureRecognizer:tap];
}

#pragma mark -  mp4 hwd delegate

#pragma mark -- 播放流程
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

#pragma mark -- 融合特效的接口 vapx

//provide the content for tags, maybe text or url string ...
- (NSString *)contentForVapTag:(NSString *)tag resource:(QGVAPSourceInfo *)info {
    
    NSDictionary *extraInfo = @{@"[sImg1]" : @"http://shp.qlogo.cn/pghead/Q3auHgzwzM6GuU0Y6q6sKHzq3MjY1aGibIzR4xrJc1VY/60",
                                @"[textAnchor]" : @"我是主播名",
                                @"[textUser]" : @"我是用户名😂😂",};
    return extraInfo[tag];
}

//provide image for url from tag content
- (void)loadVapImageWithURL:(NSString *)urlStr context:(NSDictionary *)context completion:(VAPImageCompletionBlock)completionBlock {
    
    //call completionBlock as you get the image, both sync or asyn are ok.
    //usually we'd like to make a net request
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/Resource/qq.png", [[NSBundle mainBundle] resourcePath]]];
        //let's say we've got result here
        completionBlock(image, nil, urlStr);
    });
}

#pragma mark - gesture

- (void)onImageviewTap:(UIGestureRecognizer *)ges {
    
    [ges.view removeFromSuperview];
}

#pragma mark - WrapViewDelegate

//provide the content for tags, maybe text or url string ...
- (NSString *)vapWrapview_contentForVapTag:(NSString *)tag resource:(QGVAPSourceInfo *)info {
    return nil;
}

//provide image for url from tag content
- (void)vapWrapView_loadVapImageWithURL:(NSString *)urlStr context:(NSDictionary *)context completion:(VAPImageCompletionBlock)completionBlock {
}

@end
