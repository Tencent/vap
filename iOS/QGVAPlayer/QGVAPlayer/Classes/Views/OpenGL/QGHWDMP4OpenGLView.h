// QGHWDMP4OpenGLView.h
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
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "UIView+VAP.h"

@protocol QGHWDMP4OpenGLViewDelegate <NSObject>

- (void)onViewUnavailableStatus;

@end

@interface QGHWDMP4OpenGLView : UIView

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, weak) id<QGHWDMP4OpenGLViewDelegate> displayDelegate;
@property (nonatomic, assign) QGHWDTextureBlendMode blendMode;
@property (nonatomic, assign) BOOL pause;

- (void)setupGL;
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)dispose;

//update glcontext's viewport size by layer bounds
- (void)updateBackingSize;

@end
