
package com.tnrn.UMPush;

import android.app.Activity;

import java.util.ArrayList;
import java.util.List;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;
import com.umeng.message.MsgConstant;
import com.umeng.message.PushAgent;
import com.umeng.message.UTrack;
import com.umeng.message.common.UmengMessageDeviceConfig;
import com.umeng.message.common.inter.ITagManager;
import com.umeng.message.entity.UMessage;
import com.umeng.message.tag.TagManager;

import org.json.JSONObject;

/**
 * Created by wangfei on 17/8/30
 */

public class RNUMPushModule extends ReactContextBaseJavaModule implements PushEventCallBack{
    private final int SUCCESS = 200;
    private final int ERROR = 0;
    private final int CANCEL = -1;
    private static final String TAG = RNUMPushModule.class.getSimpleName();
    private static Handler mSDKHandler = new Handler(Looper.getMainLooper());
    private ReactApplicationContext context;
    private boolean isGameInited = false;
    private static Activity mActivity;
    private PushAgent mPushAgent;
    private DeviceEventManagerModule.RCTDeviceEventEmitter eventEmitter;
    private String mAppState;

    private static ArrayList<String> mMessageQueue;


    public static void onMessageOutLine(String msg) { // 厂商推送消息
        if (null == mMessageQueue) {
            mMessageQueue = new ArrayList<String>();
        }
        mMessageQueue.add(msg);
    }

    public RNUMPushModule(final ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
        mPushAgent = PushAgent.getInstance(context);
        RNUMengPushHelper.setClickCallBack(this);
        RNUMengPushHelper.setMsgCallBack(this);

        Thread thread = new Thread() {
            @Override
            public void run() {
                super.run();
                while(reactContext.getLifecycleState().toString() != "RESUMED") { // app 没加载完成 等待
                    try {
                        Thread.sleep(200);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                for (String uMsg: mMessageQueue) {
                    sendMessage2Js("clickMsgOutLine", mMessageQueue);
                }
            }
        };
    }

    /**
     * 发送推送消息到js
     * */
    public void sendMessage2Js(String eventName, Object msg) {
        if (null == eventEmitter) {
            eventEmitter = getReactApplicationContext()
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class);
        }
        eventEmitter.emit(eventName, msg);
    }

    public static void initPushSDK(Activity activity) {
        mActivity = activity;
    }

    @Override
    public String getName() {
        return "RNUmengPush";
    }

    private static void runOnMainThread(Runnable runnable) {
        mSDKHandler.postDelayed(runnable, 0);
    }

    @ReactMethod
    public void getDeviceToken(Callback callback) { // 获取device_token
        callback.invoke(mPushAgent.getRegistrationId());
    }

//    @ReactMethod
//    public void getAuthorizationStatus(Callback callback) { // 获取push 权限
//        mPushPermissionCallBack = callback;
//    }
//
//    @ReactMethod
//    public void receiveNotification(Callback callback) { // 收到推送消息
//        mPushMessageCallBack = callback;
//    }
//
//    @ReactMethod
//    public void openNotification(Callback callback) { // 点击推送 打开app
//        mPushClickCallBack = callback;
//    }

    @ReactMethod
    public void addTag(String tag, final Callback successCallback) {
        mPushAgent.getTagManager().addTags(new TagManager.TCallBack() {
            @Override
            public void onMessage(final boolean isSuccess, final ITagManager.Result result) {
                if (isSuccess) {
                    successCallback.invoke(SUCCESS, result.remain);
                } else {
                    successCallback.invoke(ERROR, 0);
                }
            }
        }, tag);
    }


    @ReactMethod
    public void deleteTag(String tag, final Callback successCallback) {
        mPushAgent.getTagManager().deleteTags(new TagManager.TCallBack() {
            @Override
            public void onMessage(boolean isSuccess, final ITagManager.Result result) {
                Log.i(TAG, "isSuccess:" + isSuccess);
                if (isSuccess) {
                    successCallback.invoke(SUCCESS, result.remain);
                } else {
                    successCallback.invoke(ERROR, 0);
                }
            }
        }, tag);
    }

    @ReactMethod
    public void listTag(final Callback successCallback) {
        mPushAgent.getTagManager().getTags(new TagManager.TagListCallBack() {
            @Override
            public void onMessage(final boolean isSuccess, final List<String> result) {
                mSDKHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (isSuccess) {
                            if (result != null) {

                                successCallback.invoke(SUCCESS, resultToList(result));
                            } else {
                                successCallback.invoke(ERROR, resultToList(result));
                            }
                        } else {
                            successCallback.invoke(ERROR, resultToList(result));
                        }

                    }
                });

            }
        });
    }

    @ReactMethod
    public void addAlias(String alias, String aliasType, final Callback successCallback) {
        mPushAgent.addAlias(alias, aliasType, new UTrack.ICallBack() {
            @Override
            public void onMessage(final boolean isSuccess, final String message) {
                Log.i(TAG, "isSuccess:" + isSuccess + "," + message);

                Log.e("xxxxxx", "isuccess" + isSuccess);
                if (isSuccess) {
                    successCallback.invoke(SUCCESS);
                } else {
                    successCallback.invoke(ERROR);
                }


            }
        });
    }

    @ReactMethod
    public void addAliasType() {
        Toast.makeText(mActivity, "function will come soon", Toast.LENGTH_LONG);
    }

    @ReactMethod
    public void addExclusiveAlias(String exclusiveAlias, String aliasType, final Callback successCallback) {
        mPushAgent.setAlias(exclusiveAlias, aliasType, new UTrack.ICallBack() {
            @Override
            public void onMessage(final boolean isSuccess, final String message) {

                Log.i(TAG, "isSuccess:" + isSuccess + "," + message);
                if (Boolean.TRUE.equals(isSuccess)) {
                    successCallback.invoke(SUCCESS);
                } else {
                    successCallback.invoke(ERROR);
                }


            }
        });
    }

    @ReactMethod
    public void deleteAlias(String alias, String aliasType, final Callback successCallback) {
        mPushAgent.deleteAlias(alias, aliasType, new UTrack.ICallBack() {
            @Override
            public void onMessage(boolean isSuccess, String s) {
                if (Boolean.TRUE.equals(isSuccess)) {
                    successCallback.invoke(SUCCESS);
                } else {
                    successCallback.invoke(ERROR);
                }
            }
        });
    }


    @ReactMethod
    public void appInfo(final Callback successCallback) {
        String pkgName = context.getPackageName();
        String info = String.format("DeviceToken:%s\n" + "SdkVersion:%s\nAppVersionCode:%s\nAppVersionName:%s",
                mPushAgent.getRegistrationId(), MsgConstant.SDK_VERSION,
                UmengMessageDeviceConfig.getAppVersionCode(context), UmengMessageDeviceConfig.getAppVersionName(context));
        successCallback.invoke("应用包名:" + pkgName + "\n" + info);
    }

    private WritableMap resultToMap(ITagManager.Result result) {
        WritableMap map = Arguments.createMap();
        if (result != null) {
            map.putString("status", result.status);
            map.putInt("remain", result.remain);
            map.putString("interval", result.interval + "");
            map.putString("errors", result.errors);
            map.putString("last_requestTime", result.last_requestTime + "");
            map.putString("jsonString", result.jsonString);
        }
        return map;
    }

    private WritableArray resultToList(List<String> result) {
        WritableArray list = Arguments.createArray();
        if (result != null) {
            for (String key : result) {
                list.pushString(key);
            }
        }
        Log.e("xxxxxx", "list=" + list);
        return list;
    }

    @Override
    public void onCallBack(int type, UMessage msg) {
        String eventName = "";
        Gson gson = new Gson();
        String msgJson = gson.toJson(msg);
        switch (type) {
            case 0: // 收到消息的回调
                eventName = "receiveMsg";
                break;
            case 1: // 点击通知的回调
                eventName = "clickMsg";
                break;
        }
        sendMessage2Js(eventName, msgJson);
    }
}