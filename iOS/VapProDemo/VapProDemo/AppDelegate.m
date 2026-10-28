// Copyright (c) 2026 Tencent. All rights reserved.

#import "AppDelegate.h"
#import <TCMediaX/TCMediaX.h>

 // License的字符串， 申请地址：https://tceffect-license.tmf.qq.com/
static NSString *const sLicenseV2 =
    @"eyJzaWduYXR1cmUiOiJndWZjZGk2SGlIYzd5bVJ3NTE3THBMNzFPcXJUeUNEbGxjTmV3WFVJQldqMEtPQ1VzcVQ1SDVqbHhxWnNzOFhJL1R1SDd6d2pncjhEQzZlQ3BuTm9lZlZ5ZW8zdThCYUZMMjZ0NjZualVBZ3h2eFMxdFhSY002WFkrM29xT3VCdFl0cEt5ZlFVUnBKNm5hQ1FOTGRjOEVRRHRqYnBKZnFRUVNiWnY2dmlBK3ZQMmV0NHdoQUJ3MmdVLythSWR2dmxxT3krUXorcHo1aVFaTzhmKzhBdHEzTTNHR3FXRE9uZmgxMHphQWxHL2V1Y0ZKdi9STmozM1gza2pROW9IVkF3eU05bnJoTXlYYkQ4TlZMMnkxSUZvcmNUclh5dE9ISXpDbC9CVUt0aW9kY2xIOEF0RWhMQmtYdGpoZDQ5YSswN0MyUVV5SDEzekpEemNFQjhUa3BlL2c9PSIsImNvbnRlbnQiOiJRMFV6TXpZelFVWTVSVUl5UkRsRlFXbGdyeHlneUZPVDh2L1BQZStMeUNPakxRTW8rVTdRczB1WWtWMHJLeVlmNWlLMXZ4amhXUlZIMWZiVEVjZDUyTER0LzlHWlh6Qng2RHBUWmM4MzNIS2tRZFlhQllQUU1OY2IvVTBIYzNMWTV5dnhabi9STXdkNzA4M0w1MU50aFY5d2I0d3o3MERlV215WlRoOURnLytkMnlLVVdWOFJJbjFhQnk0ZXB0T21Wc0NVelRqeVdCTHVwQXVuWXVYOXJJVjlTUnBMc29WOFFNTkVGbUpVY3E0U05WczJDNU10dnh5QkhuaW1nMDBaRnozcGdoNXdGRGZoV3MwUThRamE1QT09In0=";

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setLicense];
    return YES;
}

#pragma mark - License

- (void)setLicense {
    [[TCMediaXBase getInstance] setLogEnable:YES];

    // License 一次性离线完成校验
    [[TCMediaXBase getInstance] setLicense:sLicenseV2
                                  callback:^(int errCode, NSString *msg) {
        NSLog(@"TCMediaX license result: errCode: %d, msg: %@", errCode, msg);
    }];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                              options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
