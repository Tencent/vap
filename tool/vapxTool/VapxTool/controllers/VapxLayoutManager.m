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

#import "VapxLayoutManager.h"

@interface VapxLayoutItem : NSObject

@property (nonatomic, readonly) NSSize size;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) BOOL isAlpha;
@property (nonatomic, assign) BOOL isRGB;
@property (nonatomic, strong) QGVAPMergedInfo *mergeInfo;

@end

@implementation VapxLayoutItem

- (NSSize)size {
    
    if (self.scale > 0) {
        return NSMakeSize(self.image.size.width*self.scale, self.image.size.height*self.scale);
    }
    return self.image.size;
}

@end

@implementation VapxBox

@end

@implementation VapxLayoutManager

- (instancetype)init {
    if (self = [super init]) {
        _padding = NSEdgeInsetsZero;
    }
    return self;
}

- (void)layoutWith:(QGVAPConfigModel *)config desDir:(NSString *)des alphaScale:(CGFloat)scale {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:des]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:des withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error create dir fail:%@", des);
            return ;
        }
    }
    
    CGSize size = config.info.videoSize;
    //每一帧
    [config.info.alphaPaths enumerateObjectsUsingBlock:^(NSString *alphaPath, NSUInteger idx, BOOL * _Nonnull stop) {
        
        @autoreleasepool {
            
            NSMutableArray *layoutItems = [NSMutableArray new];
            VapxBox *rootBox = [VapxBox new];
            rootBox.rect = NSMakeRect(0, 0, size.width, size.height);
            
            NSImage *alphaImage = [[NSImage alloc] initWithContentsOfFile:alphaPath];
            NSImage *rgbImage = [[NSImage alloc] initWithContentsOfFile:config.info.rgbPaths[idx]];
            VapxLayoutItem *alphaItem = [VapxLayoutItem new];
            alphaItem.image = alphaImage ;
            alphaItem.scale = scale;
            alphaItem.isAlpha = YES;
            VapxLayoutItem *rgbItem = [VapxLayoutItem new];
            rgbItem = [VapxLayoutItem new];
            rgbItem.image = rgbImage;
            rgbItem.isRGB = YES;
            
            [layoutItems addObject:alphaItem];
            [layoutItems addObject:rgbItem];
            
            //当前帧的每一个mask
            [config.mergedConfig[@(idx)] enumerateObjectsUsingBlock:^(QGVAPMergedInfo * _Nonnull maskInfo, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *maskPath = maskInfo.tempPathForMask;
                NSImage *maskImage = [[NSImage alloc] initWithContentsOfFile:maskPath];
                VapxLayoutItem *maskItem = [VapxLayoutItem new];
                maskItem.image = maskImage;
                maskItem.mergeInfo = maskInfo;
                [layoutItems addObject:maskItem];
            }];
            NSImage *mergedImage = [self layoutWith:config desDir:des layoutItems:layoutItems];
            NSString *path = [des stringByAppendingPathComponent:[alphaPath lastPathComponent]];
            [self saveImage:mergedImage atPath:path];
        }
    }];
}

- (NSImage *)layoutWith:(QGVAPConfigModel *)config desDir:(NSString *)des layoutItems:(NSArray<VapxLayoutItem*>*)items {
    
    CGSize size = config.info.videoSize;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    CGContextRef mergeContext = CGBitmapContextCreate(nil, (int)size.width, (int)size.height,
                                                      bitsPerComponent, (int)(bytesPerPixel*size.width), colorSpace,
                                                      kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    __block VapxLayoutItem *rgbItem = nil;
    __block VapxLayoutItem *alphaItem = nil;
    NSMutableArray *sortedItems = [[items sortedArrayUsingComparator:^NSComparisonResult(VapxLayoutItem *obj1, VapxLayoutItem *obj2) {
        CGSize size1 = obj1.size;
        CGSize size2 = obj2.size;
        return [@(size2.width*size2.height) compare:@(size1.width*size1.height)];
    }] mutableCopy];
    
    [sortedItems enumerateObjectsUsingBlock:^(VapxLayoutItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isAlpha) {
            alphaItem = obj;
        }
        if (obj.isRGB) {
            rgbItem = obj;
        }
    }];
    [sortedItems removeObject:alphaItem];
    [sortedItems insertObject:alphaItem atIndex:0];
    [sortedItems removeObject:rgbItem];
    [sortedItems insertObject:rgbItem atIndex:0];
    
    VapxBox *rootBox = [VapxBox new];
    rootBox.rect = NSMakeRect(0, 0, size.width, size.height);
    
    //宽型视频
    NSSize firstSize = fitOuterSize([sortedItems.firstObject size], self.padding);
    BOOL rightFirst = (firstSize.width >= firstSize.height);
    
    
    [sortedItems enumerateObjectsUsingBlock:^(VapxLayoutItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize imageSize = item.size;
        NSSize imageOuterSize = fitOuterSize(imageSize, self.padding);
        VapxBox *box = [self findBox:rootBox size:imageOuterSize rightFirst:rightFirst];
        if (box) {
            [self splitBox:box size:imageOuterSize];
            NSEdgeInsets fitPadding = paddingForSize(imageSize, self.padding);
            NSRect drawRect = NSMakeRect(box.rect.origin.x+fitPadding.left, size.height - box.rect.origin.y - fitPadding.top - imageSize.height, imageSize.width, imageSize.height);
            NSRect drawBounds = NSMakeRect(0, 0, imageSize.width, imageSize.height);
            //debug code
//            CGContextSetFillColorWithColor(mergeContext, [NSColor redColor].CGColor);
//            CGContextFillRect(mergeContext, NSMakeRect(box.rect.origin.x, size.height - box.rect.origin.y - imageOuterSize.height, imageOuterSize.width, imageOuterSize.height));
            
            CGContextDrawImage(mergeContext, drawRect, [item.image CGImageForProposedRect:&drawBounds context:nil hints:nil]);
            NSRect rect = NSMakeRect(box.rect.origin.x+fitPadding.left, box.rect.origin.y+fitPadding.top, imageSize.width, imageSize.height);
            if (item.isAlpha) {
                config.info.alphaAreaRect = rect;
            } else if (item.isRGB) {
                config.info.rgbAreaRect = rect;
            } else {
                item.mergeInfo.maskRect = rect;
            }
        }
    }];
    
    
    CGImageRef mergedImageRef = CGBitmapContextCreateImage(mergeContext);
    NSImage *mergedImage = [[NSImage alloc] initWithCGImage:mergedImageRef size:size];
    CGImageRelease(mergedImageRef);
    CGContextRelease(mergeContext);
    return mergedImage;
}

- (void)saveImage:(NSImage *)image atPath:(NSString *)path {
    
    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    [newRep setSize:[image size]];   // if you want the same resolution
    NSData *pngData = [newRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    BOOL succ = [pngData writeToFile:path atomically:YES];
    if (!succ) {
        
    }
}

- (NSSize)maximumSizeForInfo:(QGVAPConfigModel *)config alphaMinScale:(CGFloat)scale {

    __block NSSize minSize = NSMakeSize(0, 0);
    [config.info.alphaPaths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *sizes = [NSMutableArray new];
        NSSize imageSize = [self sizeOfImageAt:config.info.alphaPaths[idx]];
        NSSize alphaSize = NSMakeSize(imageSize.width*scale, imageSize.height*scale);
        [sizes addObject:[NSValue valueWithSize:fitOuterSize(imageSize, self.padding)]];
        [sizes addObject:[NSValue valueWithSize:fitOuterSize(alphaSize, self.padding)]];
        [config.mergedConfig[@(idx)] enumerateObjectsUsingBlock:^(QGVAPMergedInfo * _Nonnull maskInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            NSSize maskSize = [self sizeOfImageAt:maskInfo.tempPathForMask];
            //NSSize rotatedSize = [self rotatedSize:maskSize];
            [sizes addObject:[NSValue valueWithSize:fitOuterSize(maskSize, self.padding)]];
        }];
        NSSize size = [self mergeSizes:sizes];
        minSize = ((minSize.width*minSize.height) > (size.width*size.height)) ? minSize : size;
    }];
    return minSize;
}

- (NSSize)rotatedSize:(NSSize)size {
    return NSMakeSize(size.height, size.width);
}

- (NSImage *)rotatedImage:(NSImage *)image {
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSRect rect = NSMakeRect(0, 0, width, height);
    CGImageRef imageRef = [image CGImageForProposedRect:&rect context:nil hints:nil];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));

    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    CGFloat newWidth = height;
    CGFloat newHeight = width;
    
    unsigned char *rotatedData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    //旋转计算
    
    for (int i = 0 ; i < newHeight; i ++) {
        for (int j = 0; j < newWidth; j ++) {
            NSInteger oldIndex = ((width-1)-i+j*width)*4;
            NSInteger newIndex = (i*(int)newWidth+j)*4;
            rotatedData[newIndex] = rawData[oldIndex];
            rotatedData[newIndex+1] = rawData[oldIndex+1];
            rotatedData[newIndex+2] = rawData[oldIndex+2];
            rotatedData[newIndex+3] = rawData[oldIndex+3];
        }
    }
    free(rawData);
    
    CGDataProviderRef rotatedProvider = CGDataProviderCreateWithData(NULL, rotatedData, newWidth*newHeight*4, NULL);
    
    CGColorSpaceRef rotateColorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | (CGBitmapInfo)kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef maskImageRef = CGImageCreate(newWidth, newHeight, 8, 32, 4*newWidth,rotateColorSpace, bitmapInfo, rotatedProvider,NULL,NO, renderingIntent);
    NSImage *rotatedImage = [[NSImage alloc] initWithCGImage:maskImageRef size:NSMakeSize(newWidth, newHeight)];
    CGDataProviderRelease(rotatedProvider);
    CGImageRelease(maskImageRef);
    free(rotatedData);
    
    return rotatedImage;
}

NSSize fitOuterSize(NSSize size, NSEdgeInsets padding) {
    
    NSEdgeInsets newPadding = paddingForSize(size, padding);
    return outerSize(size, newPadding);
}

NSRect fitInnerRect(NSRect rect, NSEdgeInsets padding) {
    
    NSEdgeInsets newPadding = paddingForSize(rect.size, padding);
    return innerRect(rect, newPadding);
}

NSSize outerSize(NSSize size, NSEdgeInsets padding) {
    
    return NSMakeSize(size.width+padding.left+padding.right, size.height+padding.top+padding.bottom);
}

NSRect innerRect(NSRect rect, NSEdgeInsets padding) {
    
    return NSMakeRect(rect.origin.x+padding.left, rect.origin.y+padding.top, rect.size.width-padding.left-padding.right, rect.size.height-padding.top-padding.bottom);
}

NSEdgeInsets paddingForSize(NSSize size, NSEdgeInsets padding) {
    
    NSEdgeInsets newPadding = padding;
    if (size.width + padding.left + padding.right > kVapLayoutMaxWidth) {
        newPadding.left = 0;
        newPadding.right = 0;
    }
    if (size.height + padding.top + padding.bottom > kVapLayoutMaxWidth) {
        newPadding.top = 0;
        newPadding.bottom = 0;
    }
    return newPadding;
}

- (NSSize)sizeOfImageAt:(NSString *)imagePath {
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    return image.size;
}

- (NSSize)mergeSizes:(NSArray *)sizes {
    
    CGSize videoSize = [sizes[0] sizeValue];
    NSArray *sortedSizes = [sizes sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
        CGSize size1 = [obj1 sizeValue];
        CGSize size2 = [obj2 sizeValue];
        return [@(size2.width*size2.height) compare:@(size1.width*size1.height)];
    }];

    __block CGFloat maxWidth = 0;
    __block CGFloat maxHeight = 0;
    
    VapxBox *rootBox = [VapxBox new];
    rootBox.rect = NSZeroRect;
    BOOL rightFirst = YES;
    //宽型视频
    if (videoSize.width >= videoSize.height) {
        maxWidth = [sortedSizes[0] sizeValue].width;
        rootBox.rect = NSMakeRect(0, 0, maxWidth, 10000);
    } else {
        //长条形视频
        maxHeight = [sortedSizes[0] sizeValue].height;
        rightFirst = NO;
        rootBox.rect = NSMakeRect(0, 0, 10000, maxHeight);
    }
    
    [sortedSizes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSSize size = [obj sizeValue];
        VapxBox *box = [self findBox:rootBox size:size rightFirst:rightFirst];
        if (box) {
            [self splitBox:box size:size];
            maxWidth = MAX(maxWidth, box.rect.origin.x+size.width);
            maxHeight = MAX(maxHeight, box.rect.origin.y+size.height);
        }
        
    }];
    
    return NSMakeSize(maxWidth, maxHeight);
}

- (VapxBox *)findBox:(VapxBox *)root size:(NSSize)size rightFirst:(BOOL)rightFirst {
    
    if (root.used) {
        
        if (rightFirst) {
            VapxBox *rightBox = [self findBox:root.right size:size rightFirst:rightFirst];
            if (rightBox) {
                return rightBox;
            }
            return [self findBox:root.down size:size rightFirst:rightFirst];
        } else {
            VapxBox *downBox = [self findBox:root.down size:size rightFirst:rightFirst];
            if (downBox) {
                return downBox;
            }
            return [self findBox:root.right size:size rightFirst:rightFirst];
        }
    } else if (size.width <= root.rect.size.width && size.height <= root.rect.size.height) {
        return root;
    }
    return nil;
}

- (VapxBox *)splitBox:(VapxBox *)box size:(NSSize)size {
    
    box.used = YES;
    VapxBox *downBox = [VapxBox new];
    downBox.rect = NSMakeRect(box.rect.origin.x, box.rect.origin.y+size.height, box.rect.size.width, box.rect.size.height-size.height);
    box.down = downBox;
    
    VapxBox *rightBox = [VapxBox new];
    rightBox.rect = NSMakeRect(box.rect.origin.x+size.width, box.rect.origin.y, box.rect.size.width-size.width, size.height);
    box.right = rightBox;
    
    return box;
}



@end
