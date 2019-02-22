//
//  RNUmengPush.m
//  RNUMPush
//
//  Created by winter on 2019/2/20.
//  Copyright © 2019 tnrn. All rights reserved.
//

#import "RNUmengPush.h"
//#import <UMPush/UMessage.h>
//#import <UMCommon/UMCommon.h>

#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString * const DidReceiveRemoteMessage = @"RNUmengPushDidReceiveRemoteMessage";
static NSString * const DidOpenRemoteMessage = @"RNUmengPushDidOpenRemoteMessage";

@interface RNUmengPush ()<UNUserNotificationCenterDelegate>
@property(nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) RCTPromiseResolveBlock receiveRemoteMessageBlock;
@property (nonatomic, copy) RCTPromiseResolveBlock openRemoteMessageBlock;
@end

@implementation RNUmengPush
RCT_EXPORT_MODULE()

+ (instancetype)sharedInstance {
    static RNUmengPush *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

+ (dispatch_queue_t)sharedMethodQueue {
    static dispatch_queue_t methodQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        methodQueue = dispatch_queue_create("com.tnrn.rn-umeng-push", DISPATCH_QUEUE_SERIAL);
    });
    return methodQueue;
}

- (dispatch_queue_t)methodQueue {
    return [RNUmengPush sharedMethodQueue];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[DidReceiveRemoteMessage, DidOpenRemoteMessage];
}

#pragma mark - private method

- (void)didReceiveRemoteNotification:(NSDictionary *)noti {
    if (self.receiveRemoteMessageBlock) {
        self.receiveRemoteMessageBlock(noti);
    }
    else [self sendEventWithName:DidReceiveRemoteMessage body:noti];
}

- (void)didOpenRemoteNotification:(NSDictionary *)noti {
    if (self.openRemoteMessageBlock) {
        self.openRemoteMessageBlock(noti);
    }
    else [self sendEventWithName:DidOpenRemoteMessage body:noti];
}

+ (void)setupPushWithLaunchOptions:(NSDictionary *)launchOptions {
//    UMessageRegisterEntity *entity = [[UMessageRegisterEntity alloc] init];
//    // 声音，弹窗，角标
//    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
    
    // iOS10以后
    if (UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1_ios10_identifier" title:@"打开" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2_ios10_identifier" title:@"忽略" options:UNNotificationActionOptionForeground];
        
        //UNNotificationCategoryOptionNone
        //UNNotificationCategoryOptionCustomDismissAction  清除通知被触发会走通知的代理方法
        //UNNotificationCategoryOptionAllowInCarPlay       适用于行车模式
        UNNotificationCategory *notiCategory_ios10 = [UNNotificationCategory categoryWithIdentifier:@"notiCategory_ios10"
                                                                                            actions:@[action1, action2]
                                                                                  intentIdentifiers:@[]
                                                                                            options:UNNotificationCategoryOptionCustomDismissAction];
//        entity.categories = [NSSet setWithObjects:notiCategory_ios10, nil];
    }
    else {
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_ios8_identifier";
        action1.title = @"打开";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_ios8_identifier";
        action2.title = @"忽略";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *notiCategory_ios8 = [[UIMutableUserNotificationCategory alloc] init];
        notiCategory_ios8.identifier = @"notiCategory_ios8";
        [notiCategory_ios8 setActions:@[action1, action2] forContext:(UIUserNotificationActionContextDefault)];
        
//        entity.categories = [NSSet setWithObjects:notiCategory_ios8, nil];
    }
    
//    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        // iOS10以后 回调
//        if (!granted) {
//            // 拒绝通知
//        }
//    }];
    
    // 设置APP运行时，收到通知不弹窗
//    [UMessage setAutoAlert:NO];
//    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    // 由推送第一次打开app
    if (launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]) {
        [self didReceiveRemoteNotificationWhenFirstLaunchApp:launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"]];
    }
}

+ (void)didReceiveRemoteNotificationWhenFirstLaunchApp:(NSDictionary *)noti {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), [self sharedMethodQueue], ^{
//        // 当前模块是否正在加载
//        if ([RNUmengPush sharedInstance].bridge.isLoading) {
//            [UMessage didReceiveRemoteNotification:noti];
//            [[RNUmengPush sharedInstance] didOpenRemoteNotification:noti];
//        }
//        else {
//            [self didReceiveRemoteNotificationWhenFirstLaunchApp:noti];
//        }
//    });
}

#pragma mark - pulic method

+ (void)registerWithAppkey:(NSString *)appkey launchOptions:(NSDictionary *)launchOptions {
//    [UMConfigure initWithAppkey:appkey channel:nil];
//    [self setupPushWithLaunchOptions:launchOptions];
//
//#ifdef DEBUG
//    [UMConfigure setLogEnabled:YES];
//#endif
}

+ (void)didRegisterDeviceToken:(NSData *)deviceToken {
    NSString *tokenString = [deviceToken description];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [RNUmengPush sharedInstance].deviceToken = tokenString;
    
//    [UMessage registerDeviceToken:deviceToken];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState )state  {
//    [UMessage didReceiveRemoteNotification:userInfo];
//
//    // send event
//    if (state == UIApplicationStateInactive) {
//        [[RNUmengPush sharedInstance] didOpenRemoteNotification:userInfo];
//    }
//    else {
//        [[RNUmengPush sharedInstance] didReceiveRemoteNotification:userInfo];
//    }
}

#pragma mark - UNUserNotificationCenterDelegate >=iOS10.0

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // APP在前台的远程通知
//        NSDictionary *userInfo = notification.request.content.userInfo;
//        [[RNUmengPush sharedInstance] didReceiveRemoteNotification:userInfo];
    }
    else {
        // 前台的本地通知
    }
    // app处于前台时提示设置
    completionHandler(UNNotificationPresentationOptionNone);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // APP在前台的远程通知
//        NSDictionary *userInfo = response.notification.request.content.userInfo;
//        [[RNUmengPush sharedInstance] didReceiveRemoteNotification:userInfo];
    }
    else {
        // 前台的本地通知
    }
}

#pragma mark - native handle js method

//  /**未知错误*/
//  kUMessageErrorUnknown = 0,
//  /**响应出错*/
//  kUMessageErrorResponseErr = 1,
//  /**操作失败*/
//  kUMessageErrorOperateErr = 2,
//  /**参数非法*/
//  kUMessageErrorParamErr = 3,
//  /**条件不足(如:还未获取device_token，添加tag是不成功的)*/
//  kUMessageErrorDependsErr = 4,
//  /**服务器限定操作*/
//  kUMessageErrorServerSetErr = 5,
- (NSString *)checkErrorMessage:(NSInteger)code {
    switch (code) {
        case 1:
            return @"响应出错";
        case 2:
            return @"操作失败";
        case 3:
            return @"参数非法";
        case 4:
            return @"条件不足(如:还未获取device_token，添加tag是不成功的)";
        case 5:
            return @"服务器限定操作";
        default:
            break;
    }
    return @"未知错误";
}

- (void)handleResponse:(id  _Nonnull)responseObject remain:(NSInteger)remain error:(NSError * _Nonnull)error completion:(RCTResponseSenderBlock)completion {
    if (completion) {
        if (error) {
            NSString *msg = [self checkErrorMessage:error.code];
            if (msg.length == 0) {
                msg = error.localizedDescription;
            }
            completion(@[@(error.code), @(remain)]);
        }
        else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *retDict = responseObject;
                if ([retDict[@"success"] isEqualToString:@"ok"]) {
                    completion(@[@200, @(remain)]);
                }
                else completion(@[@(-1), @(remain)]);
            }
            else completion(@[@(-1), @(remain)]);
        }
    }
}

- (void)handleGetTagResponse:(NSSet * _Nonnull)responseTags remain:(NSInteger)remain error:(NSError * _Nonnull)error completion:(RCTResponseSenderBlock)completion {
    if (completion) {
        if (error) {
            NSString *msg = [self checkErrorMessage:error.code];
            if (msg.length == 0) {
                msg = error.localizedDescription;
            }
            completion(@[@(error.code), @(remain), @[]]);
        }
        else {
            if ([responseTags isKindOfClass:[NSSet class]]) {
                NSArray *retList = responseTags.allObjects;
                completion(@[@200, @(remain), retList]);
            }
            else completion(@[@(-1), @(remain), @[]]);
        }
    }
}

- (void)handleAliasResponse:(id  _Nonnull)responseObject error:(NSError * _Nonnull)error completion:(RCTResponseSenderBlock)completion {
    if (completion) {
        if (error) {
            NSString *msg = [self checkErrorMessage:error.code];
            if (msg.length == 0) {
                msg = error.localizedDescription;
            }
            completion(@[@(error.code)]);
        }
        else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *retDict = responseObject;
                if ([retDict[@"success"] isEqualToString:@"ok"]) {
                    completion(@[@200]);
                }
                else completion(@[@(-1)]);
                
            }
            else completion(@[@(-1)]);
        }
    }
}

#pragma mark - RN method

//RCT_EXPORT_METHOD(receiveRemoteNotification:(RCTPromiseResolveBlock)completion) {
//    self.receiveRemoteMessageBlock = completion;
//}
//
//RCT_EXPORT_METHOD(openRemoteNotification:(RCTPromiseResolveBlock)completion) {
//    self.openRemoteMessageBlock = completion;
//}
//
//RCT_EXPORT_METHOD(addTag:(NSString *)tag response:(RCTResponseSenderBlock)completion) {
//    [UMessage addTags:tag response:^(id responseObject, NSInteger remain, NSError *error) {
//        [self handleResponse:responseObject remain:remain error:error completion:completion];
//    }];
//}
//
//RCT_EXPORT_METHOD(deleteTag:(NSString *)tag response:(RCTResponseSenderBlock)completion) {
//    [UMessage deleteTags:tag response:^(id responseObject, NSInteger remain, NSError *error) {
//        [self handleResponse:responseObject remain:remain error:error completion:completion];
//    }];
//}
//
//RCT_EXPORT_METHOD(listTag:(RCTResponseSenderBlock)completion) {
//    [UMessage getTags:^(NSSet *responseTags, NSInteger remain, NSError *error) {
//        [self handleGetTagResponse:responseTags remain:remain error:error completion:completion];
//    }];
//}
//
//RCT_EXPORT_METHOD(addAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion) {
//    [UMessage addAlias:name type:type response:^(id responseObject, NSError *error) {
//        [self handleAliasResponse:responseObject error:error completion:completion];
//    }];
//}
//
//RCT_EXPORT_METHOD(addExclusiveAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion) {
//    [UMessage setAlias:name type:type response:^(id responseObject, NSError *error) {
//        [self handleAliasResponse:responseObject error:error completion:completion];
//    }];
//}
//
//RCT_EXPORT_METHOD(deleteAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion) {
//    [UMessage removeAlias:name type:type response:^(id responseObject, NSError *error) {
//        [self handleAliasResponse:responseObject error:error completion:completion];
//    }];
//}

@end

