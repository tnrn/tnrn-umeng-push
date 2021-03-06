
[![npm][npm-badge]][npm]
[![react-native][rn-badge]][rn]
[![MIT][license-badge]][license]
[![Downloads](https://img.shields.io/npm/dm/tnrn-umeng-push.svg)](https://www.npmjs.com/package/tnrn-umeng-push)

[npm-badge]: https://img.shields.io/npm/v/tnrn-umeng-push.svg
[npm]: https://www.npmjs.com/package/tnrn-umeng-push
[rn-badge]: https://img.shields.io/badge/react--native-v0.40-05A5D1.svg
[rn]: https://facebook.github.io/react-native
[license-badge]: https://img.shields.io/dub/l/vibe-d.svg
[license]: https://raw.githubusercontent.com/tnrn/tnrn-umeng-push/master/LICENSE

友盟推送 [React Native][rn].

## Getting Started

First, `cd` to your RN project directory, and install RNMK through [rnpm](https://github.com/rnpm/rnpm) . If you don't have rnpm, you can install RNMK from npm with the command `npm i -S tnrn-umeng-push` and link it manually (see below).

### iOS

* #### React Native < 0.46 (Using rnpm)

  `rnpm install tnrn-umeng-push`

* #### React Native >= 0.46
  `$npm install -S tnrn-umeng-push`

  `$react-native link tnrn-umeng-push`

在工程target的 `Build Phases->Link Binary with Libraries` 中加入
`libz.tbd libsqlite3.tbd`

在 `Build Settings->Search Paths->Framework Search Paths` 中加入路径 `$(SRCROOT)/../node_modules/tnrn-umeng-push/ios/Framework`

在 `Build Settings->Link->Other Linker Flags` 中加入 `-framework "UMPush"` 和 `-framework "UMCommon"`


### Android

* #### React Native < 0.46 (Using rnpm)

  `rnpm install tnrn-umeng-push`

* #### React Native >= 0.46
  `$npm install -S tnrn-umeng-push`

  `$react-native link tnrn-umeng-push`

#### Manually
1. JDK 7+ is required
1. Add the following snippet to your `android/settings.gradle`:

  ```gradle
include ':tnrn-umeng-push'
project(':tnrn-umeng-push').projectDir = new File(rootProject.projectDir, '../node_modules/tnrn-umeng-push/android/app')
  ```
  
1. Declare the dependency in your `android/app/build.gradle`
  
  ```gradle
  dependencies {
      ...
      compile project(':tnrn-umeng-push')
  }
  ```
  
1. Import `import io.tnrn.splashscreen.SplashScreenPackage;` and register it in your `MainActivity` (or equivalent, RN >= 0.32 MainApplication.java):

  ```java
  @Override
  protected List<ReactPackage> getPackages() {
      return Arrays.asList(
              new MainReactPackage(),
              new SplashScreenPackage(MainActivity.activity, true)
      );
  }
  ```

Finally, you're good to go, feel free to require `tnrn-umeng-push` in your JS files.

Have fun! :metal:

## Basic Usage

Use in AppDelegate.m for iOS

```

#import <RNUmengPush/RNUmengPush.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ...

  [RNUmengPush registerWithAppkey:UmengAppKey launchOptions:launchOptions];

  ...
}

#pragma mark - push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [RNUmengPush didRegisterDeviceToken:deviceToken];
}

// iOS10 以下
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [RNUmengPush didReceiveRemoteNotification:userInfo applicationState:application.applicationState];
  completionHandler(UIBackgroundFetchResultNewData);
}

```


Use library in *.js

```
import UMPush from 'tnrn-umeng-push'

...

UMPush.receiveNotification(result => {
  console.log('receiveNotification = ', result)
})

UMPush.openNotification(result => {
  console.log('openNotification = ', result)
})

UMPush.getDeviceToken(result => {
	console.log('deviceToken = ', result)
})

// only support iOS
UMPush.getAuthorizationStatus(result => {
	console.log('getAuthorizationStatus = ', result)
})
    
UMPush.addAlias('test', (result) => {
  console.log('addAliais = ', result)
}) 

...    
```


## Questions

[create an issue](https://github.com/tnrn/tnrn-umeng-push/issues/new)

> made with ♥