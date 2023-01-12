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

/*
 封装VAPView，本身不响应手势
 提供ContentMode功能
 播放完成后会自动移除内部的VAPView（可选）
 */
@interface QGVAPWrapView : UIView
/// default is QGVAPWrapViewContentModeScaleToFill
@property (nonatomic, assign) QGVAPWrapViewContentMode contentMode;
// 是否在播放完成后自动移除内部VAPView, 如果外部用法会复用当前View，可以不移除
@property (nonatomic, assign) BOOL autoDestoryAfterFinish;

- (void)playHWDMP4:(NSString *)filePath
       repeatCount:(NSInteger)repeatCount
          delegate:(id<VAPWrapViewDelegate>)delegate;

- (void)stopHWDMP4;

- (void)pauseHWDMP4;
- (void)resumeHWDMP4;

//设置是否静音播放素材，注：在播放开始时进行设置，播放过程中设置无效
- (void)setMute:(BOOL)isMute;

//增加点击的手势识别, 如果开启了autoDestoryAfterFinish，那么手势将在播放完毕后失效
- (void)addVapTapGesture:(VAPGestureEventBlock)handler;
//手势识别通用接口, 如果开启了autoDestoryAfterFinish，那么手势将在播放完毕后失效
- (void)addVapGesture:(UIGestureRecognizer *)gestureRecognizer callback:(VAPGestureEventBlock)handler;


/*
 QGVAPWrapView本身不响应手势，只有子视图响应手势，请使用vapWrapView_addVapTapGesture / vapWrapView_addVapGesture添加
 */
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
