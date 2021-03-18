// UIView+VAP.h
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
#import "UIView+VAP.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, QGVAPWrapViewContentMode) {
    QGVAPWrapViewContentModeScaleToFill,
    QGVAPWrapViewContentModeAspectFit,
    QGVAPWrapViewContentModeAspectFill,
};

@protocol VAPWrapViewDelegate <NSObject>

@optional
//即将开始播放时询问，true马上开始播放，false放弃播放
- (BOOL)vapWrap_viewshouldStartPlayMP4:(VAPView *)container config:(QGVAPConfigModel *)config;

- (void)vapWrap_viewDidStartPlayMP4:(VAPView *)container;
- (void)vapWrap_viewDidPlayMP4AtFrame:(QGMP4AnimatedImageFrame*)frame view:(VAPView *)container;
- (void)vapWrap_viewDidStopPlayMP4:(NSInteger)lastFrameIndex view:(VAPView *)container;
- (void)vapWrap_viewDidFinishPlayMP4:(NSInteger)totalFrameCount view:(VAPView *)container;
- (void)vapWrap_viewDidFailPlayMP4:(NSError *)error;

//vap APIs
- (NSString *)vapWrapview_contentForVapTag:(NSString *)tag resource:(QGVAPSourceInfo *)info;        //替换配置中的资源占位符（不处理直接返回tag）
- (void)vapWrapView_loadVapImageWithURL:(NSString *)urlStr context:(NSDictionary *)context completion:(VAPImageCompletionBlock)completionBlock; //由于组件内不包含网络图片加载的模块，因此需要外部支持图片加载。

@end

/// 封装渲染容器的View，提供ContentMode功能
@interface QGVAPWrapView : UIView
/// default is QGVAPWrapViewContentModeScaleToFill
@property (nonatomic, assign) QGVAPWrapViewContentMode contentMode;

- (void)vapWrapView_playHWDMP4:(NSString *)filePath
                   repeatCount:(NSInteger)repeatCount
                      delegate:(id<VAPWrapViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
