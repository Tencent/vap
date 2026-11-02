// Copyright (c) 2026 Tencent. All rights reserved.

#import "BackgroundView.h"

@implementation BackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat tileSize = 8.0; 

    // 白底
    [[UIColor whiteColor] setFill];
    CGContextFillRect(ctx, self.bounds);

    // 灰色棋盘
    [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] setFill];
    for (CGFloat y = 0; y < height; y += tileSize) {
        BOOL draw = ((NSInteger)(y / tileSize) % 2) == 1;
        for (CGFloat x = 0; x < width; x += tileSize) {
            if (draw) {
                CGContextFillRect(ctx, CGRectMake(x, y, tileSize, tileSize));
            }
            draw = !draw;
        }
    }
}

@end
