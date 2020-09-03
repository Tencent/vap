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

#import <Cocoa/Cocoa.h>
#import "VapxFileHelper.h"

@class VapMergeInfoView;
@protocol VapMergeInfoViewDelegate <NSObject>

- (void)didClickAtCloseButton:(VapMergeInfoView*)view;

@end

@interface VapMergeInfoView : NSView

@property (nonatomic, weak) id<VapMergeInfoViewDelegate> delegate;
@property (nonatomic, strong) VapxFileHelper *fileHelper;
@property (nonatomic, strong) NSString *maskPath;

@property (nonatomic, strong) NSTextField *tagLabel;
@property (nonatomic, strong) NSPopUpButton *resTypePopButton;
@property (nonatomic, strong) NSPopUpButton *fitTypePopButton;
@property (nonatomic, strong) NSTextField *widthLabel;
@property (nonatomic, strong) NSTextField *heightLabel;
@property (nonatomic, strong) NSButton *maskUploadButotn;
@property (nonatomic, strong) NSTextField *colorLabel;
@property (nonatomic, strong) NSPopUpButton *fontStyleButton;

- (void)setIndex:(NSInteger)index;

@end
