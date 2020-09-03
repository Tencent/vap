// QGHWDMetalView.h
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
#import "VAPMacros.h"

//https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Device/Device.html#//apple_ref/doc/uid/TP40014221-CH2-SW1
/*
 2018-12-31 00:01:51.349229+0800 MetalTest[28134:2050088] [DYMTLInitPlatform] platform initialization successful
 2018-12-31 00:01:51.413574+0800 MetalTest[28134:2050043] Metal GPU Frame Capture Enabled
 2018-12-31 00:01:51.414037+0800 MetalTest[28134:2050043] Metal API Validation Enabled
 2018-12-31 00:01:54.008682+0800 MetalTest[28134:2050086] Execution of the command buffer was aborted due to an error during execution. Insufficient Permission (to submit GPU work from background) (IOAF code 6)
 2018-12-31 00:01:54.009053+0800 MetalTest[28134:2050086] Execution of the command buffer was aborted due to an error during execution. Insufficient Permission (to submit GPU work from background) (IOAF code 6)
 2018-12-31 00:01:54.011370+0800 MetalTest[28134:2050086] Execution of the command buffer was aborted due to an error during execution. Insufficient Permission (to submit GPU work from background) (IOAF code 6)
 2018-12-31 00:01:54.011710+0800 MetalTest[28134:2050086] Execution of the command buffer was aborted due to an error during execution. Insufficient Permission (to submit GPU work from background) (IOAF code 6)
 */
@protocol QGHWDMetelViewDelegate <NSObject>

- (void)onMetalViewUnavailable;

@end

@interface QGHWDMetalView : UIView

@property (nonatomic, weak) id<QGHWDMetelViewDelegate> delegate;
@property (nonatomic, assign) QGHWDTextureBlendMode blendMode;

- (instancetype)initWithFrame:(CGRect)frame blendMode:(QGHWDTextureBlendMode)mode;

- (void)display:(CVPixelBufferRef)pixelBuffer;

- (void)dispose;

@end

