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

#import "VapxAlphaExtractor.h"
#import <AppKit/AppKit.h>

@implementation VapxAlphaExtractor

+ (NSString *)extractWithDir:(NSString *)directory info:(QGVAPCommonInfo**)info completion:(extractCompletionBlock)onCompletion {
    
    VapxAlphaExtractor *extractor = [VapxAlphaExtractor new];
    extractor.resourceDirectory = directory;
    return [extractor extract:info completion:onCompletion];
}

- (NSString *)extract:(QGVAPCommonInfo**)info completion:(extractCompletionBlock)onCompletion {
    
    if (self.resourceDirectory.length == 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *targetDir = [self.resourceDirectory stringByAppendingPathComponent:@"mergedImages"];
    NSString *alphaDir = [self.resourceDirectory stringByAppendingPathComponent:@"alphaImages"];
    NSString *rgbDir = [self.resourceDirectory stringByAppendingPathComponent:@"rbgImages"];
    
    if (![fileManager fileExistsAtPath:targetDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:targetDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    if (![fileManager fileExistsAtPath:alphaDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:alphaDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    if (![fileManager fileExistsAtPath:rgbDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:rgbDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.resourceDirectory error:NULL];
    
    __block NSInteger framesCount = 0;
    __block NSSize size = NSZeroSize;
    
    NSMutableArray *alphaPaths = [NSMutableArray new];
    NSMutableArray *rgbPaths = [NSMutableArray new];
    
    NSArray *sortedArr = [directoryContent sortedArrayUsingComparator:^NSComparisonResult(NSString  *obj1, NSString *obj2) {
        return [[obj1 stringByDeletingPathExtension] compare:[obj2 stringByDeletingPathExtension]];
    }];
    [sortedArr enumerateObjectsUsingBlock:^(NSString *content, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if (![content.pathExtension isEqualToString:@"png"]) {
                NSLog(@"item is not png!:%@", content);
                return ;
            }
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:[self.resourceDirectory stringByAppendingPathComponent:content]];
            if (framesCount == 0) {
                size = image.size;
            } else {
                if (!NSEqualSizes(size, image.size)) {
                    NSLog(@"png size not equal!!:%@ size:%@ first size:%@", content, [NSValue valueWithSize:image.size], [NSValue valueWithSize:size]);
                    return ;
                }
            }
            [self extractAlphaChannel:image name:content info:info];
            [alphaPaths addObject:[alphaDir stringByAppendingPathComponent:content]];
            [rgbPaths addObject:[rgbDir stringByAppendingPathComponent:content]];
            framesCount += 1;
        }
    }];
    (*info).framesCount = framesCount;
    (*info).size = size;
    (*info).alphaPaths = alphaPaths;
    (*info).rgbPaths = rgbPaths;
    
    if (onCompletion) {
        onCompletion(framesCount, alphaPaths, rgbPaths);
    }
    return targetDir;
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

- (void)extractAlphaChannel:(NSImage *)image name:(NSString *)name info:(QGVAPCommonInfo**)info {
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSRect rect = NSMakeRect(0, 0, width, height);
    CGImageRef imageRef = [image CGImageForProposedRect:&rect context:nil hints:nil];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    unsigned char *alphaData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    unsigned char *rgbData = (unsigned char*)calloc(height * width * 4, sizeof(unsigned char));
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
    bitsPerComponent, bytesPerRow, colorSpace,
    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    for (int i = 0; i < height * width * 4; i += 4) {
        CGFloat red   = ((CGFloat)rawData[i]);
        CGFloat green = ((CGFloat)rawData[i+1]);
        CGFloat blue  = ((CGFloat)rawData[i+2]);
        CGFloat alpha = ((CGFloat)rawData[i+3]);
        
        rgbData[i] = red;
        rgbData[i+1] = green;
        rgbData[i+2] = blue;
        rgbData[i+3] = 255;

        alphaData[i] = alpha;
        alphaData[i+1] = alpha;
        alphaData[i+2] = alpha;
        alphaData[i+3] = 255;
    }
    free(rawData);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | (CGBitmapInfo)kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // 生成 RGB 图片
    CGDataProviderRef rgbProvider = CGDataProviderCreateWithData(NULL, rgbData, width*height*4, NULL);
    CGImageRef rgbImageRef = CGImageCreate(width,  height, 8, 32, 4*width,colorSpace, bitmapInfo, rgbProvider,NULL,NO, renderingIntent);
    NSImage *rgbImage = [[NSImage alloc] initWithCGImage:rgbImageRef size: rect.size];
    NSString *rgbDir = [self.resourceDirectory stringByAppendingPathComponent:@"rbgImages"];
    [self saveImage:rgbImage atPath:[rgbDir stringByAppendingPathComponent:name]];
    CGImageRelease(rgbImageRef);
    free(rgbData);
    CGDataProviderRelease(rgbProvider);
     
    // 生成 Alpha 图片
    CGDataProviderRef alphaProvider = CGDataProviderCreateWithData(NULL, alphaData, width*height*4, NULL);
    CGImageRef alphaImageRef = CGImageCreate(width,  height, 8, 32, 4*width,colorSpace, bitmapInfo, alphaProvider,NULL,NO, renderingIntent);
    NSImage *alphaImage = [[NSImage alloc] initWithCGImage:alphaImageRef size:rect.size];
    NSString *alphaDir = [self.resourceDirectory stringByAppendingPathComponent:@"alphaImages"];
    [self saveImage:alphaImage atPath:[alphaDir stringByAppendingPathComponent:name]];
    CGImageRelease(alphaImageRef);
    free(alphaData);
    CGDataProviderRelease(alphaProvider);
}

- (NSRect)alphaRectForPosition:(VapxAlphaPostion)position rgbSize:(NSSize)size alphaScale:(CGFloat)scale {
    
    NSSize totalSize = [self mergedSizeWithPosition:position rgbSize:size alphaScale:scale];
    NSSize alphaSize = NSMakeSize(size.width*scale, size.height*scale);
    return [self rectForSize:alphaSize containerSize:totalSize position:position];
}

- (NSRect)rgbRectForPosition:(VapxAlphaPostion)position rgbSize:(NSSize)size alphaScale:(CGFloat)scale {
    
    NSSize totalSize = [self mergedSizeWithPosition:position rgbSize:size alphaScale:scale];
    VapxAlphaPostion rgbPostion = VapxAlphaPostion_rightCenter;
    switch (position) {
        case VapxAlphaPostion_leftTop:
        case VapxAlphaPostion_leftCenter:
        case VapxAlphaPostion_leftBottom:
            rgbPostion = VapxAlphaPostion_rightTop;
            break;
        case VapxAlphaPostion_rightTop:
        case VapxAlphaPostion_rightCenter:
        case VapxAlphaPostion_rightBottom:
            rgbPostion = VapxAlphaPostion_leftTop;
            break;
        case VapxAlphaPostion_bottomLeft:
        case VapxAlphaPostion_bottomRight:
        case VapxAlphaPostion_bottomCenter:
            rgbPostion = VapxAlphaPostion_topLeft;
            break;
        case VapxAlphaPostion_topLeft:
        case VapxAlphaPostion_topRight:
        case VapxAlphaPostion_topCenter:
            rgbPostion = VapxAlphaPostion_bottomLeft;
            break;
        default:
            break;
    }
    return [self rectForSize:size containerSize:totalSize position:rgbPostion];
}

- (NSRect)rectForSize:(NSSize)size containerSize:(NSSize)containerSize position:(VapxAlphaPostion)position {
    
    CGFloat x,y;
    switch (position) {
        case VapxAlphaPostion_leftTop:
            x = 0;
            y = containerSize.height-size.height;
            break;
        case VapxAlphaPostion_leftCenter:
            x = 0;
            y = (containerSize.height-size.height)/2.0;
            break;
        case VapxAlphaPostion_leftBottom:
            x = 0;
            y = 0;
            break;
        case VapxAlphaPostion_rightTop:
            x = containerSize.width - size.width;
            y = containerSize.height-size.height;
            break;
        case VapxAlphaPostion_rightCenter:
            x = containerSize.width - size.width;
            y = (containerSize.height-size.height)/2.0;
            break;
        case VapxAlphaPostion_rightBottom:
            x = containerSize.width - size.width;
            y = 0;
            break;
        case VapxAlphaPostion_bottomLeft:
            x = 0;
            y = 0;
            break;
        case VapxAlphaPostion_bottomRight:
            x = containerSize.width - size.width;
            y = 0;
            break;
        case VapxAlphaPostion_bottomCenter:
            x = (containerSize.width-size.width)/2.0;
            y = 0;
            break;
        case VapxAlphaPostion_topLeft:
            x = 0;
            y = containerSize.height-size.height;
            break;
        case VapxAlphaPostion_topRight:
            x = containerSize.width - size.width;
            y = containerSize.height-size.height;
            break;
        case VapxAlphaPostion_topCenter:
            x = (containerSize.width-size.width)/2.0;
            y = containerSize.height-size.height;
            break;
        default:
            break;
    }
    return NSMakeRect(x, y, size.width, size.height);
}

- (NSSize)mergedSizeWithPosition:(VapxAlphaPostion)position rgbSize:(NSSize)size alphaScale:(CGFloat)scale {
    
    switch (position) {
        case VapxAlphaPostion_leftTop:
        case VapxAlphaPostion_leftCenter:
        case VapxAlphaPostion_leftBottom:
        case VapxAlphaPostion_rightTop:
        case VapxAlphaPostion_rightCenter:
        case VapxAlphaPostion_rightBottom:
            return NSMakeSize(size.width+size.width*scale, size.height);
        case VapxAlphaPostion_bottomLeft:
        case VapxAlphaPostion_bottomRight:
        case VapxAlphaPostion_bottomCenter:
        case VapxAlphaPostion_topLeft:
        case VapxAlphaPostion_topRight:
        case VapxAlphaPostion_topCenter:
            return NSMakeSize(size.width, size.height+size.height*scale);
        default:
            break;
    }
}

@end
