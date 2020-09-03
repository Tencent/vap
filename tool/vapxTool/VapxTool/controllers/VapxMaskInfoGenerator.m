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

#import "VapxMaskInfoGenerator.h"

@implementation VapxMaskInfoGenerator

+ (NSDictionary<NSNumber *,NSArray<QGVAPMergedInfo *> *> *)mergeInfoAt:(NSArray<NSString *> *)paths sources:(NSArray<QGVAPSourceInfo *> *)sources frames:(NSInteger)frameCount {
    
    if (paths.count != sources.count) {
        NSLog(@"遮罩与资源信息数量不匹配！");
        return nil;
    }
    if (frameCount <= 0) {
        NSLog(@"帧数不对");
        return nil;
    }
    //每个遮罩分别解析
    NSMutableArray<NSDictionary <NSNumber *, QGVAPMergedInfo *> *> *mergeInfoArr = [NSMutableArray new];
    NSInteger count = paths.count;
    for (int i = 0; i < count; i ++) {
        @autoreleasepool {
            NSString *path = paths[i];
            QGVAPSourceInfo *source = sources[i];
            NSDictionary <NSNumber *, QGVAPMergedInfo *> *mergeInfo = [self mergeInfoAt:path sourceID:source index:i];
            [mergeInfoArr addObject:mergeInfo];
        }
    }
    //遮罩信息根据帧index合并
    NSMutableDictionary<NSNumber *,NSArray<QGVAPMergedInfo *> *> *totalMergeInfo = [NSMutableDictionary new];
    for (int i = 0; i < frameCount; i ++) {
        @autoreleasepool {
            NSMutableArray<QGVAPMergedInfo *> *mergeInfosForCurrentFrame = [NSMutableArray new];
            [mergeInfoArr enumerateObjectsUsingBlock:^(NSDictionary<NSNumber *,QGVAPMergedInfo *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                QGVAPMergedInfo *mergeInfo = obj[@(i)];
                if (mergeInfo) {
                    [mergeInfosForCurrentFrame addObject:mergeInfo];
                }
            }];
            if (mergeInfosForCurrentFrame.count > 0) {
                totalMergeInfo[@(i)] = mergeInfosForCurrentFrame;
            }
        }
    }
    return totalMergeInfo;
}

+ (NSDictionary <NSNumber *, QGVAPMergedInfo *> *)mergeInfoAt:(NSString *)path sourceID:(QGVAPSourceInfo *)source index:(NSInteger)index {
    
    NSMutableDictionary <NSNumber *, QGVAPMergedInfo *>* mergeInfoDic = [NSMutableDictionary new];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *targetDir = [path stringByAppendingPathComponent:@"maskOutPut"];
    if (![fileManager fileExistsAtPath:targetDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:targetDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error create dir fail:%@", targetDir);
            return nil;
        }
    }
    [directoryContent enumerateObjectsUsingBlock:^(NSString *content, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if (![content.pathExtension isEqualToString:@"png"]) {
                NSLog(@"item is not png!:%@", content);
                return ;
            }
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:content]];
            QGVAPMergedInfo *mergeInfo = [self mergeInfoFor:image desPath:[targetDir stringByAppendingPathComponent:content] sourceInfo:source];
            if (!mergeInfo) {
                NSLog(@"mask has no valid area:%@", [targetDir stringByAppendingPathComponent:content]);
                return ;
            }
            mergeInfo.renderIndex = index;
            mergeInfo.source = source;
            NSInteger frameIndex = [[content stringByDeletingPathExtension] integerValue];
            mergeInfoDic[@(frameIndex)] = mergeInfo;
        }
    }];
    
    return mergeInfoDic;
}

+ (QGVAPMergedInfo *)mergeInfoFor:(NSImage *)image desPath:(NSString *)path sourceInfo:(QGVAPSourceInfo *)source {
    
    QGVAPMergedInfo *mergeInfo = [QGVAPMergedInfo new];
    
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
    
    CGFloat minX = -1, minY = -1, maxX = -1, maxY = -1;
    for (int i = 0; i < height * width * 4; i += 4) {
        CGFloat alpha = ((CGFloat)rawData[i+3]);
        if (alpha == 0) {
            continue ;
        }
        NSInteger x = (i/4)%((int)width);
        NSInteger y = (i/4)/((int)width);
        if (minX == -1) {
            minX = x;
            minY = y;
            maxX = x;
            maxY = y;
        } else {
            minX = MIN(minX, x);
            minY = MIN(minY, y);
            maxX = MAX(maxX, x);
            maxY = MAX(maxY, y);
        }
    }
    
    if (minX >= maxX || minY >= maxY) {
        //无有效区域
        free(rawData);
        return nil;
    }
    
    maxX += 1;
    maxY += 1;
    
    NSRect maskRect = NSMakeRect(minX, minY, maxX-minX, maxY-minY);
    mergeInfo.renderRect = maskRect;
    unsigned char *maskData = (unsigned char*)calloc(maskRect.size.height * maskRect.size.width * 4, sizeof(unsigned char));
    
    NSInteger maskDataIndex = 0;
    for (int i = minY; i < maxY; i ++) {
        for (int j = minX; j < maxX; j ++) {
            NSInteger index = i*width*4 + j*4;
            CGFloat v = 255;
            CGFloat r = rawData[index];
            CGFloat a = rawData[index+3];
            
            if (a == 0) {
                v = 0;
            } else {
                v = (255-r)*a/255.0;
            }
            maskData[maskDataIndex++] = v;
            maskData[maskDataIndex++] = v;
            maskData[maskDataIndex++] = v;
            maskData[maskDataIndex++] = 255;
        }
    }
    
    CGDataProviderRef maskProvider = CGDataProviderCreateWithData(NULL, maskData, maskRect.size.width*maskRect.size.height*4, NULL);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | (CGBitmapInfo)kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef maskImageRef = CGImageCreate(maskRect.size.width,  maskRect.size.height, 8, 32, 4*maskRect.size.width,colorSpace, bitmapInfo, maskProvider,NULL,NO, renderingIntent);
    
    CGDataProviderRelease(maskProvider);
    free(maskData);
    free(rawData);
    
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:maskImageRef];
    CGImageRelease(maskImageRef);
    [newRep setSize:maskRect.size];   // if you want the same resolution
    NSData *pngData = [newRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    BOOL succ = [pngData writeToFile:path atomically:YES];
    
    if (!succ) {
        NSLog(@"save png fail!:%@ image:%@" , path, image);
    }
    mergeInfo.tempPathForMask = path;
    return mergeInfo;
}

@end
