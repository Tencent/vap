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

#import "VapMergeInfoView.h"

@interface VapMergeInfoView () {
    
    NSTextField *_tagHintLabel;
    NSTextField *_typeLabel;
    NSTextField *_fitTypeHintLabel;
    NSTextField *_widthHintLabel;
    NSTextField *_heightHintLabel;
    NSTextField *_maskHintLabel;
    NSTextField *_colorHintLabel;
    NSTextField *_fontHintLabel;
    NSButton *_closeButton;
    NSInteger _index;
}

@end

@implementation VapMergeInfoView

- (void)setIndex:(NSInteger)index {
    
    _index = index;
    _tagHintLabel.stringValue = [NSString stringWithFormat:@"%@. 占位符:",@(index)];
    [_tagHintLabel sizeToFit];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    
    if (self = [super initWithFrame:frameRect]) {
        [self setupUIComponents];
        [self updateComponentsFrame];
    }
    return self;
}

- (void)setupUIComponents {
    
    _tagHintLabel = [NSTextField new];
    _tagHintLabel.drawsBackground = NO;
    _tagHintLabel.stringValue = @"1. 占位符:";
    [_tagHintLabel setBezeled:NO];
    [_tagHintLabel setEditable:NO];
    [_tagHintLabel sizeToFit];
    [self addSubview:_tagHintLabel];
    
    _tagLabel = [NSTextField new];
    _tagLabel.placeholderString = [NSString stringWithFormat: @"例:[%@]", @"userAvatar"];
    [self addSubview:_tagLabel];
    
    _typeLabel = [NSTextField new];
    _typeLabel.drawsBackground = NO;
    _typeLabel.stringValue = @"资源类型:";
    [_typeLabel setBezeled:NO];
    [_typeLabel setEditable:NO];
    [_typeLabel sizeToFit];
    [self addSubview:_typeLabel];
    
    _resTypePopButton = [NSPopUpButton new];
    [_resTypePopButton addItemsWithTitles:@[@"网络图片",@"文字"]];
    [self addSubview:_resTypePopButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didResTypePopButtonSelect:)
                                                 name:NSMenuDidSendActionNotification
                                               object:[_resTypePopButton menu]];
    
    _fitTypeHintLabel = [NSTextField new];
    _fitTypeHintLabel.drawsBackground = NO;
    _fitTypeHintLabel.stringValue = @"适配类型:";
    [_fitTypeHintLabel setBezeled:NO];
    [_fitTypeHintLabel setEditable:NO];
    [_fitTypeHintLabel sizeToFit];
    [self addSubview:_fitTypeHintLabel];
    
    _fitTypePopButton = [NSPopUpButton new];
    [_fitTypePopButton addItemsWithTitles:@[@"铺满",@"等比适配"]];
    [self addSubview:_fitTypePopButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFitTypePopButtonSelect:)
                                                 name:NSMenuDidSendActionNotification
                                               object:[_fitTypePopButton menu]];
    
    _widthHintLabel = [NSTextField new];
    _widthHintLabel.drawsBackground = NO;
    _widthHintLabel.stringValue = @"宽度:";
    [_widthHintLabel setBezeled:NO];
    [_widthHintLabel setEditable:NO];
    [_widthHintLabel sizeToFit];
    [self addSubview:_widthHintLabel];
    
    _widthLabel = [NSTextField new];
    [self addSubview:_widthLabel];
    
    _heightHintLabel = [NSTextField new];
    _heightHintLabel.drawsBackground = NO;
    _heightHintLabel.stringValue = @"高度:";
    [_heightHintLabel setBezeled:NO];
    [_heightHintLabel setEditable:NO];
    [_heightHintLabel sizeToFit];
    [self addSubview:_heightHintLabel];
    
    _heightLabel = [NSTextField new];
    [self addSubview:_heightLabel];
    
    _maskHintLabel = [NSTextField new];
    _maskHintLabel.drawsBackground = NO;
    _maskHintLabel.stringValue = @"上传对应的遮罩:";
    [_maskHintLabel setBezeled:NO];
    [_maskHintLabel setEditable:NO];
    [_maskHintLabel sizeToFit];
    [self addSubview:_maskHintLabel];
    
    _maskUploadButotn = [NSButton new];
    [_maskUploadButotn setFrame:NSMakeRect(0, 0, 100, 15)];
    [_maskUploadButotn setBezelStyle:NSBezelStyleRounded];
    [_maskUploadButotn setTitle:@"上传遮罩"];
    [_maskUploadButotn setTarget:self];
    [_maskUploadButotn setAction:@selector(onUploadMaskButtonClicked:)];
    [self addSubview:_maskUploadButotn];
    
    _colorHintLabel = [NSTextField new];
    _colorHintLabel.drawsBackground = NO;
    _colorHintLabel.stringValue = @"颜色:";
    [_colorHintLabel setBezeled:NO];
    [_colorHintLabel setEditable:NO];
    [_colorHintLabel sizeToFit];
    [self addSubview:_colorHintLabel];
    
    _colorLabel = [NSTextField new];
    _colorLabel.placeholderString = @"例:#000000";
    [_colorLabel sizeToFit];
    [self addSubview:_colorLabel];
    
    _fontHintLabel = [NSTextField new];
    _fontHintLabel.drawsBackground = NO;
    _fontHintLabel.stringValue = @"字体:";
    [_fontHintLabel setBezeled:NO];
    [_fontHintLabel setEditable:NO];
    [_fontHintLabel sizeToFit];
    [self addSubview:_fontHintLabel];
    
    _fontStyleButton = [NSPopUpButton new];
    [_fontStyleButton addItemsWithTitles:@[@"粗体",@"正常"]];
    [self addSubview:_fontStyleButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFontPopButtonSelect:)
                                                 name:NSMenuDidSendActionNotification
                                               object:[_fontStyleButton menu]];
    [self setTextTypeViewsHidden:YES];
    
    _closeButton = [NSButton new];
    [_closeButton setImage:[NSImage imageNamed:@"close"]];
    [_closeButton setTarget:self];
    [_closeButton setAction:@selector(onCloseButtonClick:)];
    _closeButton.bordered = NO;
    [self addSubview:_closeButton];
    
}

- (void)updateComponentsFrame {
    
    _tagHintLabel.frame = NSMakeRect(0, CGRectGetHeight(self.frame)-CGRectGetHeight(_tagHintLabel.frame)-5, CGRectGetWidth(_tagHintLabel.frame), CGRectGetHeight(_tagHintLabel.frame));
    CGFloat height = 20;
    _tagLabel.frame = NSMakeRect(CGRectGetMaxX(_tagHintLabel.frame)+10, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-height/2.0, 100, height);
    _typeLabel.frame = NSMakeRect(CGRectGetMaxX(_tagLabel.frame)+10, CGRectGetHeight(self.frame)-CGRectGetHeight(_typeLabel.frame)-5, CGRectGetWidth(_typeLabel.frame), CGRectGetHeight(_typeLabel.frame));
    height = 50;
    _resTypePopButton.frame = NSMakeRect(CGRectGetMaxX(_typeLabel.frame)+5, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-height/2.0, 100, height);
    
    _fitTypeHintLabel.frame = NSMakeRect(CGRectGetMaxX(_resTypePopButton.frame)+10, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-CGRectGetHeight(_fitTypeHintLabel.frame)/2.0, CGRectGetWidth(_fitTypeHintLabel.frame), CGRectGetHeight(_fitTypeHintLabel.frame));
    height = 50;
    _fitTypePopButton.frame = NSMakeRect(CGRectGetMaxX(_fitTypeHintLabel.frame)+5, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-height/2.0, 100, height);
    
    height = 20;
    _widthHintLabel.frame = NSMakeRect(CGRectGetMaxX(_fitTypePopButton.frame)+10, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-CGRectGetHeight(_widthHintLabel.frame)/2.0, CGRectGetWidth(_widthHintLabel.frame), CGRectGetHeight(_widthHintLabel.frame));
    _widthLabel.frame = NSMakeRect(CGRectGetMaxX(_widthHintLabel.frame)+2, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-height/2.0, 50, height);
    
    _heightHintLabel.frame = NSMakeRect(CGRectGetMaxX(_widthLabel.frame), CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-CGRectGetHeight(_heightHintLabel.frame)/2.0, CGRectGetWidth(_heightHintLabel.frame), CGRectGetHeight(_heightHintLabel.frame));
    _heightLabel.frame = NSMakeRect(CGRectGetMaxX(_heightHintLabel.frame)+2, CGRectGetMaxY(_tagHintLabel.frame)-CGRectGetHeight(_tagHintLabel.frame)/2.0-height/2.0, 50, height);
    
    _maskHintLabel.frame = NSMakeRect(0, CGRectGetMinY(_tagHintLabel.frame)-10-CGRectGetHeight(_maskHintLabel.frame), CGRectGetWidth(_maskHintLabel.frame), CGRectGetHeight(_maskHintLabel.frame));
    _maskUploadButotn.frame = NSMakeRect(CGRectGetMaxX(_maskHintLabel.frame), CGRectGetMaxY(_maskHintLabel.frame)-CGRectGetHeight(_maskHintLabel.frame)/2.0-CGRectGetHeight(_maskUploadButotn.frame)/2.0, _maskUploadButotn.frame.size.width, _maskHintLabel.frame.size.height);
    
    _colorHintLabel.frame = NSMakeRect(CGRectGetMaxX(_maskUploadButotn.frame), CGRectGetMaxY(_maskHintLabel.frame)-CGRectGetHeight(_maskHintLabel.frame)/2.0-CGRectGetHeight(_colorHintLabel.frame)/2.0, _colorHintLabel.frame.size.width, _colorHintLabel.frame.size.height);
    _colorLabel.frame = NSMakeRect(CGRectGetMaxX(_colorHintLabel.frame), CGRectGetMaxY(_maskHintLabel.frame)-CGRectGetHeight(_maskHintLabel.frame)/2.0-CGRectGetHeight(_colorLabel.frame)/2.0, _colorLabel.frame.size.width, _colorLabel.frame.size.height);
    _fontHintLabel.frame = NSMakeRect(CGRectGetMaxX(_colorLabel.frame)+10, CGRectGetMaxY(_maskHintLabel.frame)-CGRectGetHeight(_maskHintLabel.frame)/2.0-CGRectGetHeight(_fontHintLabel.frame)/2.0, _fontHintLabel.frame.size.width, _fontHintLabel.frame.size.height);
    height = 50;
    _fontStyleButton.frame = NSMakeRect(CGRectGetMaxX(_fontHintLabel.frame)+5, CGRectGetMaxY(_fontHintLabel.frame)-CGRectGetHeight(_fontHintLabel.frame)/2.0-height/2.0, 100, height);
    
    height = 15;
    _closeButton.frame = NSMakeRect(CGRectGetMaxX(_heightLabel.frame)+30, CGRectGetHeight(self.frame)/2.0-height/2.0, height, height);
    
}

- (void)setTextTypeViewsHidden:(BOOL)hidden {
    
    _colorLabel.hidden = hidden;
    _colorHintLabel.hidden = hidden;
    _fontHintLabel.hidden = hidden;
    _fontStyleButton.hidden = hidden;
    
    if (hidden) {
        _tagLabel.nextKeyView = _widthLabel;
        _widthLabel.nextKeyView = _heightLabel;
        _heightLabel.nextKeyView = _tagLabel;
    } else {
        _tagLabel.nextKeyView = _widthLabel;
        _widthLabel.nextKeyView = _heightLabel;
        _heightLabel.nextKeyView = _colorLabel;
        _colorLabel.nextKeyView = _tagLabel;
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    [super resizeSubviewsWithOldSize:oldSize];
    [self updateComponentsFrame];
}

- (void)didResTypePopButtonSelect:(id)sender {
   
    [self setTextTypeViewsHidden:[_resTypePopButton.selectedItem.title isEqualToString:@"网络图片"]];
}

- (void)didFitTypePopButtonSelect:(id)sender {
    NSLog(@"didFitTypePopButtonSelect");
}

- (void)didFontPopButtonSelect:(id)sender {
    NSLog(@"didFontPopButtonSelect");
}

- (void)onUploadMaskButtonClicked:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel new];
    openPanel.allowsMultipleSelection = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    NSModalResponse res = [openPanel runModal];
    if (res == NSModalResponseOK) {
        self.maskPath = [self.fileHelper saveUploadedMasks:openPanel.URLs identifier:[NSString stringWithFormat:@"%p",self]];
        self.maskUploadButotn.title = [NSString stringWithFormat:@"%@个文件",@(openPanel.URLs.count)];
    } else {
        self.maskPath = nil;
        self.maskUploadButotn.title = @"上传文件";
    }
}

- (void)onCloseButtonClick:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(didClickAtCloseButton:)]) {
        [self.delegate didClickAtCloseButton:self];
    }
}

@end
