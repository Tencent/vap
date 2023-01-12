// UIView+VAP.m
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

#import "QGVAPWrapView.h"
#import "QGVAPConfigModel.h"

@interface QGVAPWrapView()<VAPWrapViewDelegate, HWDMP4PlayDelegate>

@property (nonatomic, weak) id<VAPWrapViewDelegate> delegate;

@property (nonatomic, strong) VAPView *vapView;

@end

@implementation QGVAPWrapView

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _autoDestoryAfterFinish = YES;
}

// 因为播放停止后可能移除VAPView，这里需要加回来
- (void)initVAPViewIfNeed {
    if (!_vapView) {
        _vapView = [[VAPView alloc] initWithFrame:self.bounds];
        [self addSubview:_vapView];
    }
}

- (void)playHWDMP4:(NSString *)filePath
                   repeatCount:(NSInteger)repeatCount
                      delegate:(id<VAPWrapViewDelegate>)delegate {
    
    self.delegate = delegate;
    
    [self initVAPViewIfNeed];
    [self.vapView playHWDMP4:filePath repeatCount:repeatCount delegate:self];
}

- (void)stopHWDMP4 {
    [self.vapView stopHWDMP4];
}

- (void)pauseHWDMP4 {
    [self.vapView pauseHWDMP4];
}

- (void)resumeHWDMP4 {
    [self.vapView resumeHWDMP4];
}

- (void)setMute:(BOOL)isMute {
    [self initVAPViewIfNeed];
    [self.vapView setMute:isMute];
}

- (void)addVapGesture:(UIGestureRecognizer *)gestureRecognizer callback:(VAPGestureEventBlock)handler {
    [self initVAPViewIfNeed];
    [self.vapView addVapGesture:gestureRecognizer callback:handler];
}

- (void)addVapTapGesture:(VAPGestureEventBlock)handler {
    [self initVAPViewIfNeed];
    [self.vapView addVapTapGesture:handler];
}

#pragma mark - UIView
// 自身不响应，仅子视图响应。
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha < 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [self convertPoint:point toView:subview];
            UIView *hitView = [subview hitTest:convertedPoint withEvent:event];
            if (hitView) {
                return hitView;
            }
        }
        return nil;
    }
    return nil;
}

#pragma mark - Private

- (void)p_setupContentModeWithConfig:(QGVAPConfigModel *)config {
    CGFloat realWidth = 0.;
    CGFloat realHeight = 0.;
    
    CGFloat layoutWidth = self.bounds.size.width;
    CGFloat layoutHeight = self.bounds.size.height;
    
    CGFloat layoutRatio = self.bounds.size.width / self.bounds.size.height;
    CGFloat videoRatio = config.info.size.width / config.info.size.height;
    
    switch (self.contentMode) {
        case QGVAPWrapViewContentModeScaleToFill: {

        }
            break;
        case QGVAPWrapViewContentModeAspectFit: {
            if (layoutRatio < videoRatio) {
                realWidth = layoutWidth;
                realHeight = realWidth / videoRatio;
            } else {
                realHeight = layoutHeight;
                realWidth = videoRatio * realHeight;
            }
            
            self.vapView.frame = CGRectMake(0, 0, realWidth, realHeight);
            self.vapView.center = self.center;
        }
            break;;
        case QGVAPWrapViewContentModeAspectFill: {
            if (layoutRatio > videoRatio) {
                realWidth = layoutWidth;
                realHeight = realWidth / videoRatio;
            } else {
                realHeight = layoutHeight;
                realWidth = videoRatio * realHeight;
            }
            
            self.vapView.frame = CGRectMake(0, 0, realWidth, realHeight);
            self.vapView.center = self.center;
        }
            break;;
        default:
            break;
    }
}

#pragma mark -  mp4 hwd delegate

#pragma mark -- 播放流程
- (void)viewDidStartPlayMP4:(VAPView *)container {
    if ([self.delegate respondsToSelector:@selector(vapWrap_viewDidStartPlayMP4:)]) {
        [self.delegate vapWrap_viewDidStartPlayMP4:container];
    }
}

- (void)viewDidFinishPlayMP4:(NSInteger)totalFrameCount view:(UIView *)container {
    //note:在子线程被调用
    if ([self.delegate respondsToSelector:@selector(vapWrap_viewDidFinishPlayMP4:view:)]) {
        [self.delegate vapWrap_viewDidFinishPlayMP4:totalFrameCount view:container];
    }
}

- (void)viewDidPlayMP4AtFrame:(QGMP4AnimatedImageFrame *)frame view:(UIView *)container {
    //note:在子线程被调用
    if ([self.delegate respondsToSelector:@selector(vapWrap_viewDidPlayMP4AtFrame:view:)]) {
        [self.delegate vapWrap_viewDidPlayMP4AtFrame:frame view:container];
    }
}

- (void)viewDidStopPlayMP4:(NSInteger)lastFrameIndex view:(UIView *)container {
    //note:在子线程被调用
    if ([self.delegate respondsToSelector:@selector(vapWrap_viewDidStopPlayMP4:view:)]) {
        [self.delegate vapWrap_viewDidStopPlayMP4:lastFrameIndex view:container];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.autoDestoryAfterFinish) {
            [self.vapView removeFromSuperview];
            self.vapView = nil;
        }
    });
}

- (BOOL)shouldStartPlayMP4:(VAPView *)container config:(QGVAPConfigModel *)config {
    [self p_setupContentModeWithConfig:config];
    
    if ([self.delegate respondsToSelector:@selector(vapWrap_viewshouldStartPlayMP4:config:)]) {
        return [self.delegate vapWrap_viewshouldStartPlayMP4:container config:config];
    }
    return YES;
}

- (void)viewDidFailPlayMP4:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(vapWrap_viewDidFailPlayMP4:)]) {
        [self.delegate vapWrap_viewDidFailPlayMP4:error];
    }
}

#pragma mark -- 融合特效的接口 vapx

//provide the content for tags, maybe text or url string ...
- (NSString *)contentForVapTag:(NSString *)tag resource:(QGVAPSourceInfo *)info {
    if ([self.delegate respondsToSelector:@selector(vapWrapview_contentForVapTag:resource:)]) {
        return [self.delegate vapWrapview_contentForVapTag:tag resource:info];
    }
    
    return nil;
}

//provide image for url from tag content
- (void)loadVapImageWithURL:(NSString *)urlStr context:(NSDictionary *)context completion:(VAPImageCompletionBlock)completionBlock {
    if ([self.delegate respondsToSelector:@selector(vapWrapView_loadVapImageWithURL:context:completion:)]) {
        [self.delegate vapWrapView_loadVapImageWithURL:urlStr context:context completion:completionBlock];
    }
}

@end
