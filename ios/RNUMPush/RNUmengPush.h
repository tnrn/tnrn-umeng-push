//
//  RNUmengPush.h
//  RNUMPush
//
//  Created by winter on 2019/2/20.
//  Copyright © 2019 tnrn. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#endif

@interface RNUmengPush : RCTEventEmitter <RCTBridgeModule>
/** 初始化友盟所有组件产品 
 @param appKey 开发者在友盟官网申请的appkey.
 @param launchOptions didFinishLaunchingWithOptions:launchOptions
 */
+ (void)registerWithAppkey:(NSString *)appkey launchOptions:(NSDictionary *)launchOptions;
+ (void)application:(UIApplication *)application didRegisterDeviceToken:(NSData *)deviceToken;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
@end
