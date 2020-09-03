// QGVAPLogger.h
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

#import <Foundation/Foundation.h>

#define kQGVAPModuleCommon @"kQGVAPModuleCommon"

NS_ASSUME_NONNULL_BEGIN

#define VAP_Logger(level, module, format, ...) if(external_VAP_Logger)external_VAP_Logger(level, __FILE__, __LINE__, __FUNCTION__, module, format, ##__VA_ARGS__); else internal_VAP_Logger_handler(level, __FILE__, __LINE__, __FUNCTION__, module, format, ##__VA_ARGS__);

#define VAP_Error(module, format, ...)   VAP_Logger(VAPLogLevelError, module, format,  ##__VA_ARGS__)
#define VAP_Event(module, format, ...)   VAP_Logger(VAPLogLevelEvent,  module, format,  ##__VA_ARGS__)
#define VAP_Warn(module, format, ...)    VAP_Logger(VAPLogLevelWarn, module, format,  ##__VA_ARGS__)
#define VAP_Info(module, format, ...)    VAP_Logger(VAPLogLevelInfo, module, format,  ##__VA_ARGS__)
#define VAP_Debug(module, format, ...)   VAP_Logger(VAPLogLevelDebug, module, format,  ##__VA_ARGS__)

typedef enum {
    VAPLogLevelAll = 0,
    VAPLogLevelDebug,    // Detailed information on the flow through the system.
    VAPLogLevelInfo,     // Interesting runtime events (startup/shutdown), should be conservative and keep to a minimum.
    VAPLogLevelEvent,
    VAPLogLevelWarn,     // Other runtime situations that are undesirable or unexpected, but not necessarily "wrong".
    VAPLogLevelError,    // Other runtime errors or unexpected conditions.
    VAPLogLevelFatal,    // Severe errors that cause premature termination.
    VAPLogLevelNone,     // Special level used to disable all log messages.
} VAPLogLevel;

typedef VAPLogLevel HWDLogLevel;

//void qg_VAP_Logger(VAPLogLevel level, const char* file, int line, const char* func, NSString *MODULE, NSString *format, ...);
typedef void (*QGVAPLoggerFunc)(VAPLogLevel, const char*, int, const char*, NSString *, NSString *, ...);

#if defined __cplusplus
extern "C" {
#endif
    
    extern QGVAPLoggerFunc external_VAP_Logger;
    void internal_VAP_Logger_handler(VAPLogLevel level, const char* file, int line, const char* func, NSString *module, NSString *format, ...);
    
#if defined __cplusplus
};
#endif

@interface QGVAPLogger : NSObject

+ (void)registerExternalLog:(QGVAPLoggerFunc)externalLog;

+ (void)log:(VAPLogLevel)level file:(NSString *)file line:(NSInteger)line func:(NSString *)func module:(NSString *)module message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
