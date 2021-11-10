// QGVAPTextureLoader.m
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

#import "QGVAPTextureLoader.h"
#import <MetalKit/MetalKit.h>
#import "QGHWDShaderTypes.h"
#import "QGVAPLogger.h"
#import "UIDevice+VAPUtil.h"

@implementation QGVAPTextureLoader

#if TARGET_OS_SIMULATOR//模拟器
+ (id<MTLBuffer>)loadVapColorFillBufferWith:(UIColor *)color device:(id<MTLDevice>)device {return nil;}
+ (id<MTLTexture>)loadTextureWithImage:(UIImage *)image device:(id<MTLDevice>)device {return nil;}
+ (UIImage *)drawingImageForText:(NSString *)textStr color:(UIColor *)color size:(CGSize)size bold:(BOOL)bold {return nil;}
+ (UIFont *)getAppropriateFontWith:(NSString *)text rect:(CGRect)fitFrame designedSize:(CGFloat)designedFontSize bold:(BOOL)isBold textSize:(CGSize *)textSize {return nil;}
#else

+ (id<MTLBuffer>)loadVapColorFillBufferWith:(UIColor *)color device:(id<MTLDevice>)device {
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    if (color) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    struct VapAttachmentFragmentParameter colorParams[] = {{color != nil ? 0 : 1, {red, green, blue, alpha}}};
    NSUInteger colorParamsSize = sizeof(struct VapAttachmentFragmentParameter);
    id<MTLBuffer> buffer = [device newBufferWithBytes:colorParams length:colorParamsSize options:kDefaultMTLResourceOption];
    return buffer;
}

+ (id<MTLTexture>)loadTextureWithImage:(UIImage *)image device:(id<MTLDevice>)device {
    
    if (!image) {
        VAP_Error(kQGVAPModuleCommon, @"attemp to loadTexture with nil image");
        return nil;
    }
    if (@available(iOS 10.0, *)) {
        MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
        NSError *error = nil;
        id<MTLTexture> texture = [loader newTextureWithCGImage:image.CGImage options:@{MTKTextureLoaderOptionOrigin : MTKTextureLoaderOriginFlippedVertically,MTKTextureLoaderOptionSRGB:@(NO)} error:&error];
        if (!texture || error) {
            VAP_Error(kQGVAPModuleCommon, @"loadTexture error:%@", error);
            return nil;
        }
        return texture;
    }
    return [self cg_loadTextureWithImage:image device:device];
}

+ (UIImage *)drawingImageForText:(NSString *)textStr color:(UIColor *)color size:(CGSize)size bold:(BOOL)bold {
    
    if (textStr.length == 0) {
        VAP_Error(kQGVAPModuleCommon, @"draw text resource fail cuz text is nil !!");
        return nil;
    }
    if (!color) {
        color = [UIColor blackColor];
    }
    CGRect rect = CGRectMake(0, 0, size.width/2.0, size.height/2.0);
    CGSize textSize = CGSizeZero;
    UIFont *font = [QGVAPTextureLoader getAppropriateFontWith:textStr rect:rect designedSize:rect.size.height*0.8 bold:bold textSize:&textSize];
    if (!font) {
        VAP_Error(kQGVAPModuleCommon, @"draw text resource:%@ fail cuz font is nil !!", textStr);
        return nil;
    }
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attr = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:color};
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    rect.origin.y = (rect.size.height - font.lineHeight)/2.0;
    [textStr drawWithRect:rect options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!image) {
        VAP_Error(kQGVAPModuleCommon, @"draw text resource:%@ fail cuz UIGraphics fail.", textStr);
        return nil;
    }
    return image;
}

+ (id<MTLTexture>)cg_loadTextureWithImage:(UIImage *)image device:(id<MTLDevice>)device {
    
    CGImageRef imageRef = image.CGImage;
    if (!device || imageRef == nil) {
        VAP_Error(kQGVAPModuleCommon, @"load texture fail,cuz device/image is nil-device:%@ imaghe%@", device, imageRef);
        return nil;
    }
    CGFloat width = CGImageGetWidth(imageRef), height = CGImageGetHeight(imageRef);
    NSInteger bytesPerPixel = 4, bytesPerRow = bytesPerPixel * width, bitsPerComponent = 8;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *rawData = calloc(height * width * bytesPerPixel, sizeof(uint8_t));
    if (rawData == nil) {
        VAP_Error(kQGVAPModuleCommon, @"load texture fail,cuz alloc mem fail!width:%@ height:%@ bytesPerPixel:%@", @(width), @(height),  @(bytesPerPixel));
        CGColorSpaceRelease(colorSpace);
        colorSpace = NULL;
        return nil;
    }
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGImageByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    if (context == nil) {
        VAP_Error(kQGVAPModuleCommon, @"CGBitmapContextCreate error width:%@ height:%@ bitsPerComponent:%@ bytesPerRow:%@", @(width), @(height), @(bitsPerComponent), @(bytesPerRow));
        free(rawData);
        return nil;
    }
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:width height:height mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    if (!texture) {
        VAP_Error(kQGVAPModuleCommon, @"load texture fail,cuz fail getting texture");
        free(rawData);
        CGContextRelease(context);
        return nil;
    }
    MTLRegion region = MTLRegionMake3D(0, 0, 0, width, height, 1);
    [texture replaceRegion:region mipmapLevel:0 withBytes:rawData bytesPerRow:bytesPerRow];
    free(rawData);
    CGContextRelease(context);
    return texture;
}

+ (id<MTLTexture>)loadTextureWithData:(NSData *)data device:(id<MTLDevice>)device width:(CGFloat)width height:(CGFloat)height {
    
    if (!data) {
        VAP_Error(kQGVAPModuleCommon, @"attemp to loadTexture with nil data");
        return nil;
    }
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];
    if (!texture) {
        VAP_Error(kQGVAPModuleCommon, @"load texture fail,cuz fail getting texture");
        return nil;
    }
    MTLRegion region = MTLRegionMake3D(0, 0, 0, width, height, 1);
    
    const void *bytes = [data bytes];
    [texture replaceRegion:region mipmapLevel:0 withBytes:bytes bytesPerRow:width];
    return texture;
}

//根据指定的字符内容和容器大小计算合适的字体
+ (UIFont *)getAppropriateFontWith:(NSString *)text rect:(CGRect)fitFrame designedSize:(CGFloat)designedFontSize bold:(BOOL)isBold textSize:(CGSize *)textSize {
    
    UIFont *designedFont = isBold? [UIFont boldSystemFontOfSize:designedFontSize] : [UIFont systemFontOfSize:designedFontSize];
    if (text.length == 0 || CGRectEqualToRect(CGRectZero, fitFrame) || !designedFont) {
        *textSize = fitFrame.size;
        return designedFont ;
    }
    CGSize stringSize = [text sizeWithAttributes:@{NSFontAttributeName:designedFont}];
    CGFloat fontSize = designedFontSize;
    NSInteger remainExcuteCount = 100;
    while (stringSize.width > fitFrame.size.width && fontSize > 2.0 && remainExcuteCount > 0) {
        fontSize *= 0.9;
        remainExcuteCount -= 1;
        designedFont = isBold? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
        stringSize = [text sizeWithAttributes:@{NSFontAttributeName:designedFont}];
    }
    if (remainExcuteCount < 1 || fontSize < 5.0) {
        VAP_Event(kQGVAPModuleCommon, @"data exception content:%@ rect:%@ designedSize:%@ isBold:%@", text, [NSValue valueWithCGRect:fitFrame], @(designedFontSize), @(isBold));
    }
    *textSize = stringSize;
    return designedFont;
}

#endif

@end
