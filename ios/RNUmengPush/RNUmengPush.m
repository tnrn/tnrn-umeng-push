//
//  RNUmengPush.m
//  RNUMPush
//
//  Created by winter on 2019/2/20.
//  Copyright © 2019 tnrn. All rights reserved.
//

#import "RNUmengPush.h"
#import <UMPush/UMessage.h>
#import <UMCommon/UMCommon.h>

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTBridge.h"
#elif __has_include("React/RCTBridge.h")
#import "React/RCTBridge.h"
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static RNUmengPush *_instance = nil;

@interface RNUmengPush ()<UNUserNotificationCenterDelegate>
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) RCTResponseSenderBlock receiveRemoteMessageBlock;
@property (nonatomic, copy) RCTResponseSenderBlock openRemoteMessageBlock;
@end

@implementation RNUmengPush

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil) {
            _instance = [super allocWithZone:zone];
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

#pragma mark - private method

// 等待RN模块加载完成
+ (void)waitLoaded:(void (^)(void))block {
    if (block == nil) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), [self sharedMethodQueue], ^{
        // 当前模块是否有效
        if ([RNUmengPush shareInstance].bridge.isValid) block();
        else [self waitLoaded:block];
    });
}

- (void)waitLoaded:(void (^)(void))block {
    [RNUmengPush waitLoaded:block];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)noti {
    if (self.receiveRemoteMessageBlock) {
        self.receiveRemoteMessageBlock(@[noti]);
    }
}

- (void)didOpenRemoteNotification:(NSDictionary *)noti {
    // 如果APP没有打开，需要等待RN模块加载完成
    [self waitLoaded:^{
        if (self.openRemoteMessageBlock) {
            self.openRemoteMessageBlock(@[noti]);
        }
    }];
}

- (void)getUserNoticationSetting:(RCTResponseSenderBlock)completion {
    // iOS10以后
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSArray *status = @[@"NotDetermined", @"Denied", @"Authorized", @"Provisional"];
            completion(@[status[settings.authorizationStatus]]);
        }];
    }
    else {
        completion(@[@"unkown"]);
    }
}

+ (void)setupPushWithLaunchOptions:(NSDictionary *)launchOptions {
    UMessageRegisterEntity *entity = [[UMessageRegisterEntity alloc] init];
    // 声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;

    // iOS10以后
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"open_identifier" title:@"打开" options:UNNotificationActionOptionForeground];
        UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"cancel_identifier" title:@"忽略" options:UNNotificationActionOptionForeground];

        //UNNotificationCategoryOptionNone
        //UNNotificationCategoryOptionCustomDismissAction  清除通知被触发会走通知的代理方法
        //UNNotificationCategoryOptionAllowInCarPlay       适用于行车模式
        UNNotificationCategory *notiCategory = [UNNotificationCategory categoryWithIdentifier:@"notiCategory"
                                                                                            actions:@[action1, action2]
                                                                                  intentIdentifiers:@[]
                                                                                            options:UNNotificationCategoryOptionCustomDismissAction];
        entity.categories = [NSSet setWithObjects:notiCategory, nil];
    }
    else {
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"open_identifier";
        action1.title = @"打开";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序

        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"cancel_identifier";
        action2.title = @"忽略";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;

        UIMutableUserNotificationCategory *notiCategory = [[UIMutableUserNotificationCategory alloc] init];
        notiCategory.identifier = @"notiCategory";
        [notiCategory setActions:@[action1, action2] forContext:(UIUserNotificationActionContextDefault)];

        entity.categories = [NSSet setWithObjects:notiCategory, nil];
    }

    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // iOS10以后 回调
        if (!granted) {
            // 拒绝通知
        }
    }];
}

+ (void)didReceiveRemoteNotificationWhenFirstLaunchApp:(NSDictionary *)noti {
    [UMessage didReceiveRemoteNotification:noti];
    [[RNUmengPush shareInstance] didOpenRemoteNotification:noti];
}

#pragma mark - pulic method

+ (void)registerWithAppkey:(NSString *)appkey launchOptions:(NSDictionary *)launchOptions {
    [self registerWithAppkey:appkey launchOptions:launchOptions channel:nil];
}

+ (void)registerWithAppkey:(NSString *)appkey launchOptions:(NSDictionary *)launchOptions channel:(NSString *)channel {
#ifdef DEBUG
    //开发者需要显式的调用此函数，日志系统才能工作
    [UMConfigure setLogEnabled:YES];
#endif
    [UMConfigure initWithAppkey:appkey channel:channel];
    // 设置APP运行时，收到通知不弹窗
    [UMessage setAutoAlert:NO];
    
    [self setupPushWithLaunchOptions:launchOptions];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = [self shareInstance];
    }
    else {
        // 由推送第一次打开app
        NSDictionary *noti = launchOptions[@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if (noti) {
            [self didReceiveRemoteNotificationWhenFirstLaunchApp:noti];
        }
    }
}

+ (void)didRegisterDeviceToken:(NSData *)deviceToken {
    NSString *tokenString = [deviceToken description];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [RNUmengPush shareInstance].deviceToken = tokenString;
    
    [UMessage registerDeviceToken:deviceToken];
}

// iOS10 以下
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState)state  {
    [UMessage didReceiveRemoteNotification:userInfo];
    // send event
    if (state == UIApplicationStateInactive) {
        [[RNUmengPush shareInstance] didOpenRemoteNotification:userInfo];
    }
    else {
        [[RNUmengPush shareInstance] didReceiveRemoteNotification:userInfo];
    }
}

#pragma mark - UNUserNotificationCenterDelegate >=iOS10.0

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // 远程通知
        NSDictionary *userInfo = notification.request.content.userInfo;
        [self didReceiveRemoteNotification:userInfo];
    }
    else {
        // 前台的本地通知
    }
    // app处于前台时提示设置
    completionHandler(UNNotificationPresentationOptionSound);
}

// 点击消息触发
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // 远程通知
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        [self didOpenRemoteNotification:userInfo];
    }
    else {
        // 前台的本地通知
    }
    completionHandler();
}

#pragma mark - native handle js method

//  kUMessageErrorUnknown = 0,      未知错误
//  kUMessageErrorResponseErr = 1,  响应出错
//  kUMessageErrorOperateErr = 2,   操作失败
//  kUMessageErrorParamErr = 3,     参数非法
//  kUMessageErrorDependsErr = 4,   条件不足(如:还未获取device_token，添加tag是不成功的)
//  kUMessageErrorServerSetErr = 5, 服务器限定操作
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
            completion(@[@{@"code": @(error.code), @"msg": msg}]);
        }
        else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *retDict = responseObject;
                if ([retDict[@"success"] isEqualToString:@"ok"]) {
                    completion(@[@{@"code": @(200), @"remain": @(remain)}]);
                }
                else completion(@[@{@"code": @(-1), @"remain": @(remain)}]);
            }
            else completion(@[@{@"code": @(-1), @"remain": @(remain)}]);
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
            completion(@[@{@"code": @(error.code), @"msg": msg}]);
        }
        else {
            if ([responseTags isKindOfClass:[NSSet class]]) {
                NSArray *retList = responseTags.allObjects;
                completion(@[@{@"code": @(200), @"remain": @(remain), @"data": retList}]);
            }
            else completion(@[@{@"code": @(-1), @"remain": @(remain)}]);
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
            completion(@[@{@"code": @(error.code), @"msg": msg}]);
        }
        else {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *retDict = responseObject;
                if ([retDict[@"success"] isEqualToString:@"ok"]) {
                    completion(@[@{@"code": @(200)}]);
                }
                else completion(@[@{@"code": @(-1)}]);
                
            }
            else completion(@[@{@"code": @(-1)}]);
        }
    }
}

#pragma mark - RN method

RCT_EXPORT_METHOD(receiveRemoteNotification:(RCTResponseSenderBlock)completion) {
    self.receiveRemoteMessageBlock = completion;
}

RCT_EXPORT_METHOD(openRemoteNotification:(RCTResponseSenderBlock)completion) {
    self.openRemoteMessageBlock = completion;
}

RCT_EXPORT_METHOD(getDeviceToken:(RCTResponseSenderBlock)completion) {
    NSString *deviceToken = self.deviceToken;
    if(deviceToken == nil) {
        deviceToken = @"";
    }
    completion(@[deviceToken]);
}

RCT_EXPORT_METHOD(getAuthorizationStatus:(RCTResponseSenderBlock)completion) {
    [self getUserNoticationSetting:completion];
}

RCT_EXPORT_METHOD(addTag:(NSString *)tag response:(RCTResponseSenderBlock)completion) {
    [UMessage addTags:tag response:^(id responseObject, NSInteger remain, NSError *error) {
        [self handleResponse:responseObject remain:remain error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(deleteTag:(NSString *)tag response:(RCTResponseSenderBlock)completion) {
    [UMessage deleteTags:tag response:^(id responseObject, NSInteger remain, NSError *error) {
        [self handleResponse:responseObject remain:remain error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(listTag:(RCTResponseSenderBlock)completion) {
    [UMessage getTags:^(NSSet *responseTags, NSInteger remain, NSError *error) {
        [self handleGetTagResponse:responseTags remain:remain error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(addAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion) {
    [UMessage addAlias:name type:type response:^(id responseObject, NSError *error) {
        [self handleAliasResponse:responseObject error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(addExclusiveAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion) {
    [UMessage setAlias:name type:type response:^(id responseObject, NSError *error) {
        [self handleAliasResponse:responseObject error:error completion:completion];
    }];
}

RCT_EXPORT_METHOD(deleteAlias:(NSString *)name type:(NSString *)type response:(RCTResponseSenderBlock)completion) {
    [UMessage removeAlias:name type:type response:^(id responseObject, NSError *error) {
        [self handleAliasResponse:responseObject error:error completion:completion];
    }];
}

@end
