// UIDevice+VAPUtil.m
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 Tencent.  All rights reserved.
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

#import "UIDevice+VAPUtil.h"

MTLResourceOptions getDefaultMTLResourceOption() {
    
    if (@available(iOS 9.0, *)) {
        return MTLResourceStorageModeShared;
    } else {
        return MTLResourceCPUCacheModeDefaultCache;
    }
}
@implementation UIDevice (VAPUtil)

+ (double)systemVersionNum {
    
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}

@end
