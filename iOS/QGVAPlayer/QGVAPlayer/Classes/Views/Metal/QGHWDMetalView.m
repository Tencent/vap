// QGHWDMetalView.m
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

#import "QGHWDMetalView.h"
#import "QGVAPLogger.h"
#import "QGHWDMetalRenderer.h"

#if TARGET_OS_SIMULATOR//模拟器

@implementation QGHWDMetalView

- (instancetype)initWithFrame:(CGRect)frame blendMode:(QGHWDTextureBlendMode)mode {
    return [self initWithFrame:frame];
}

- (void)display:(CVPixelBufferRef)pixelBuffer {}

-(void)dispose {}

@end

#else

@interface QGHWDMetalView ()

@property (nonatomic, strong) CAMetalLayer          *metalLayer;
@property (nonatomic, strong) QGHWDMetalRenderer    *renderer;
@property (nonatomic, assign) BOOL                  drawableSizeShouldUpdate;

@end

@implementation QGHWDMetalView

#pragma mark - override

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(0, @"initWithCoder: has not been implemented");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _drawableSizeShouldUpdate = YES;
        _blendMode = QGHWDTextureBlendMode_AlphaLeft;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    self.drawableSizeShouldUpdate = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.drawableSizeShouldUpdate = YES;
}

- (void)dealloc {
    [self onMetalViewUnavailable];
}

#pragma mark - main

- (instancetype)initWithFrame:(CGRect)frame blendMode:(QGHWDTextureBlendMode)mode {
    
    if (self = [super initWithFrame:frame]) {
        _drawableSizeShouldUpdate = YES;
        _blendMode = QGHWDTextureBlendMode_AlphaLeft;
        _metalLayer = (CAMetalLayer *)self.layer;
        _metalLayer.frame = self.frame;
        _metalLayer.opaque = NO;
        _blendMode = mode;
        _renderer = [[QGHWDMetalRenderer alloc] initWithMetalLayer:_metalLayer blendMode:mode];
        _metalLayer.contentsScale = [UIScreen mainScreen].scale;
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        _metalLayer.framebufferOnly = YES;
    }
    return self;
}

- (void)display:(CVPixelBufferRef)pixelBuffer {
    if (!self.window) {
        VAP_Event(kQGVAPModuleCommon, @"quit display pixelbuffer, cuz window is nil!");
        [self onMetalViewUnavailable];
        return ;
    }
    if (self.drawableSizeShouldUpdate) {
        CGFloat nativeScale = [UIScreen mainScreen].nativeScale;
        CGSize drawableSize = CGSizeMake(CGRectGetWidth(self.bounds)*nativeScale, CGRectGetHeight(self.bounds)*nativeScale);
        self.metalLayer.drawableSize = drawableSize;
        VAP_Event(kQGVAPModuleCommon, @"update drawablesize :%@", [NSValue valueWithCGSize:drawableSize]);
        self.drawableSizeShouldUpdate = NO;
    }
    self.renderer.blendMode = self.blendMode;
    [self.renderer renderPixelBuffer:pixelBuffer metalLayer:self.metalLayer];
}

/**
 资源回收
 */
- (void)dispose {
    [self.renderer dispose];
}

#pragma mark - private

- (void)onMetalViewUnavailable{
    
    if ([self.delegate respondsToSelector:@selector(onMetalViewUnavailable)]) {
        [self.delegate onMetalViewUnavailable];
    }
}

@end

#endif
