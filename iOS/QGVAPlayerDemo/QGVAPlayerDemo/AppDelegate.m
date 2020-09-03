// AppDelegate.m
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

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self testCustomVapcAtom];
    return YES;
}

- (void)testCustomVapcAtom {
    
    NSString *resPath = [NSString stringWithFormat:@"%@/Resource", [[NSBundle mainBundle] resourcePath]];
    NSData *configData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/vapc.json", resPath]];
    NSString *str = [[NSString alloc] initWithData:configData encoding:kCFStringEncodingUTF8];
    NSData *utf8Data = [str dataUsingEncoding:kCFStringEncodingUTF8];
    NSInteger length = utf8Data.length+8;
    unsigned char bytes[8] = {(length&0xff000000)>>24,(length&0xff0000)>>16,(length&0xff00)>>8,length&0xff,'v','a','p','c'};
    NSMutableData *muData = [[[NSData alloc] initWithBytes:bytes length:8] mutableCopy];
    [muData appendData:utf8Data];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
