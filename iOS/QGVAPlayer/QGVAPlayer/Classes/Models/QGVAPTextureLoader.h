// QGVAPTextureLoader.h
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

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

@interface QGVAPTextureLoader : NSObject

+ (id<MTLBuffer>)loadVapColorFillBufferWith:(UIColor *)color device:(id<MTLDevice>)device;

+ (id<MTLTexture>)loadTextureWithImage:(UIImage *)image device:(id<MTLDevice>)device;

+ (id<MTLTexture>)loadTextureWithData:(NSData *)data device:(id<MTLDevice>)device width:(CGFloat)width height:(CGFloat)height;

+ (UIImage *)drawingImageForText:(NSString *)textStr color:(UIColor *)color size:(CGSize)size bold:(BOOL)bold;

+ (UIFont *)getAppropriateFontWith:(NSString *)text rect:(CGRect)fitFrame designedSize:(CGFloat)designedFontSize bold:(BOOL)isBold textSize:(CGSize *)textSize;

@end
