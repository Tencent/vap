// QGVAPLogger.m
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

#import "QGVAPLogger.h"

QGVAPLoggerFunc external_VAP_Logger;

@implementation QGVAPLogger

#pragma mark - Extenral log

void internal_VAP_Logger_handler(VAPLogLevel level, const char* file, int line, const char* func, NSString *module, NSString *format, ...) {
    
#ifdef DEBUG
    va_list arg_list;
    va_start (arg_list, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arg_list];
    va_end(arg_list);
    file = [NSString stringWithUTF8String:file].lastPathComponent.UTF8String;
    NSLog(@"<%@> %s(%@):%s [%@] - %@",@(level), file, @(line), func, module, formattedString);
#endif
}

+ (void)registerExternalLog:(QGVAPLoggerFunc)externalLog {
    external_VAP_Logger = externalLog;
}

+ (void)log:(VAPLogLevel)level file:(NSString *)file line:(NSInteger)line func:(NSString *)func module:(NSString *)module message:(NSString *)message {
    
    if ([message containsString:@"%"]) {
        //此处是为了兼容%进入formmat之后的crash风险
        [message stringByReplacingOccurrencesOfString:@"%" withString:@""];
    }
    if (external_VAP_Logger) {
        external_VAP_Logger(level, file.UTF8String, (int)line, func.UTF8String, module, message);
    } else {
        internal_VAP_Logger_handler(level, file.UTF8String, (int)line, func.UTF8String, module, message);
    }
}

@end
