// QGBaseAnimatedImageFrame+Displaying.m
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
#import "QGBaseAnimatedImageFrame+Displaying.h"
#import <objc/runtime.h>
#import "VAPMacros.h"

@implementation QGBaseAnimatedImageFrame (Displaying)

HWDSYNTH_DYNAMIC_PROPERTY_CTYPE(decodeTime, setDecodeTime, NSTimeInterval)
HWDSYNTH_DYNAMIC_PROPERTY_OBJECT(startDate, setStartDate, OBJC_ASSOCIATION_RETAIN);

- (BOOL)shouldFinishDisplaying {

    if (!self.startDate) {
        return YES;
    }
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    //每一个VSYNC16ms
    return timeInterval*1000 + 10 >= self.duration;
}

@end
