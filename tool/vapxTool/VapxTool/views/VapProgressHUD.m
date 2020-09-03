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

#import "VapProgressHUD.h"

@interface VapProgressHUD ()

@property (nonatomic, strong) NSProgressIndicator *progressIndicator;

@end

@implementation VapProgressHUD

- (void)mouseDown:(NSEvent *)event {
    
}

- (void)rightMouseDown:(NSEvent *)event {
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)initWithView:(NSView *)view {
    if (self = [super initWithFrame:view.bounds]) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
        [self setNeedsDisplay:YES];
        
        NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:view.bounds];
        progressIndicator.indeterminate = NO;
        progressIndicator.bezeled = YES;
        progressIndicator.controlSize = NSControlSizeRegular;
        progressIndicator.doubleValue = 0;
        progressIndicator.style = NSProgressIndicatorStyleBar;
        progressIndicator.displayedWhenStopped = NO;
        [self addSubview:progressIndicator];
        self.progressIndicator = progressIndicator;

        CGFloat labelWidth = 100;
        CGFloat labelHeight = 30;
        NSText *progressLabel = [[NSText alloc] initWithFrame:CGRectMake((progressIndicator.frame.size.width - labelWidth) / 2, (progressIndicator.frame.size.height - labelHeight) / 2 - 40, labelWidth, labelHeight)];
        progressLabel.string = @"处理中...";
        progressLabel.backgroundColor = NSColor.clearColor;
        progressLabel.font = [NSFont fontWithName:@"Helvetica-Bold" size:20];
        progressLabel.alignment = NSTextAlignmentCenter;
        [self addSubview:progressLabel];
    }
    return self;
}

+ (instancetype)showHUDToSuperView:(NSView *)superView {
    VapProgressHUD *hud = [[self alloc] initWithView:superView];
    [superView addSubview:hud];
    [hud show];
    return hud;
}

- (void)show {
    [self.progressIndicator startAnimation:nil];
}

- (void)hide {
    [self.progressIndicator stopAnimation:nil];
    [self removeFromSuperview];
}

- (void)setCurrentValue:(CGFloat)currentValue {
    self.progressIndicator.doubleValue = currentValue;
}

@end
