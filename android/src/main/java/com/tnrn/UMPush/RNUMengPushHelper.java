package com.tnrn.UMPush;

import android.app.Notification;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.Toast;

import com.facebook.react.common.build.ReactBuildConfig;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.MsgConstant;
import com.umeng.message.PushAgent;
import com.umeng.message.UTrack;
import com.umeng.message.UmengMessageHandler;
import com.umeng.message.UmengNotificationClickHandler;
import com.umeng.message.entity.UMessage;

/**
 * Created by zhangjz on 2019/3/11.
 */

public class RNUMengPushHelper {

    private static Handler handler;
    private static PushAgent mPushAgent;
    private static UmengNotificationClickHandler notificationClickHandler;
    private static PushEventCallBack mClickCallBack; // 点击通知事件回调

    private static PushEventCallBack mMsgCallBack; // 接受到消息事件回调
    private static PushEventCallBack mAuthCallBack;


    public static void setMsgCallBack(PushEventCallBack mMsgCallBack) {
        RNUMengPushHelper.mMsgCallBack = mMsgCallBack;
    }

    public static void setClickCallBack(PushEventCallBack mCallBack) {
        RNUMengPushHelper.mClickCallBack = mCallBack;
    }


//    public static void setNotificationClickHandler(UmengNotificationClickHandler notificationClickHandler) {
//        RNUMengPushHelper.notificationClickHandler = notificationClickHandler;
//    }

    public static Handler getHandler() {
        return handler;
    }

    public static void setHandler(Handler handler) {
        RNUMengPushHelper.handler = handler;
    }


    public static void initUpush(Context context) {
        PushAgent mPushAgent = PushAgent.getInstance(context);
        handler = new Handler(context.getMainLooper());

        //sdk开启通知声音
        mPushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_ENABLE);
        // sdk关闭通知声音
        //		mPushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        // 通知声音由服务端控制
        //		mPushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SERVER);

        //		mPushAgent.setNotificationPlayLights(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        //		mPushAgent.setNotificationPlayVibrate(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);

        UmengMessageHandler messageHandler = new UmengMessageHandler() {
            /**
             * 自定义消息的回调方法
             */
            @Override
            public void dealWithCustomMessage(final Context context, final UMessage msg) {
                Log.e("avery_zjz:cus message", msg.text);
                if (mMsgCallBack != null) {
                    mMsgCallBack.onCallBack(EventConstant.RECEIVE_MSG, msg);
                }
                handler.post(new Runnable() {

                    @Override
                    public void run() {
//                        Log.e("CustomMessage", msg.toString());
                        // TODO Auto-generated method stub
                        // 对自定义消息的处理方式，点击或者忽略
                        Log.e("avery_zjz:message text", msg.text);
                        boolean isClickOrDismissed = true;
                        if (isClickOrDismissed) {
                            //自定义消息的点击统计
                            UTrack.getInstance(context.getApplicationContext()).trackMsgClick(msg);
                        } else {
                            //自定义消息的忽略统计
                            UTrack.getInstance(context.getApplicationContext()).trackMsgDismissed(msg);
                        }
                        Toast.makeText(context, msg.custom, Toast.LENGTH_LONG).show();
                    }
                });
            }

            /**
             * 自定义通知栏样式的回调方法
             */
            @Override
            public Notification getNotification(Context context, UMessage msg) {
                Log.e("avery_zjz 通知栏", msg.text);
                Log.e("avery_zjz mMsgCallBack", ((Boolean) (mMsgCallBack != null)).toString());
                if (mMsgCallBack != null) {
                    mMsgCallBack.onCallBack(EventConstant.RECEIVE_MSG, msg);
                }
                switch (msg.builder_id) {
                    case 1:
                        Notification.Builder builder = new Notification.Builder(context);
                        RemoteViews myNotificationView = new RemoteViews(context.getPackageName(), R.layout.notification_view);
                        myNotificationView.setTextViewText(R.id.notification_title, msg.title);
                        myNotificationView.setTextViewText(R.id.notification_text, msg.text);
                        myNotificationView.setImageViewBitmap(R.id.notification_large_icon1, getLargeIcon(context, msg));
//            myNotificationView.setImageViewResource(R.id.notification_small_icon, getSmallIconId(context, msg));
                        builder.setContent(myNotificationView)
                                .setSmallIcon(getSmallIconId(context, msg))
                                .setTicker(msg.ticker)
                                .setAutoCancel(true);

                        return builder.getNotification();
                    default:
                        //默认为0，若填写的builder_id并不存在，也使用默认。
                        return super.getNotification(context, msg);
                }
            }
        };
        mPushAgent.setMessageHandler(messageHandler);

        /**
         * 自定义行为的回调处理，参考文档：高级功能-通知的展示及提醒-自定义通知打开动作
         * UmengNotificationClickHandler是在BroadcastReceiver中被调用，故
         * 如果需启动Activity，需添加Intent.FLAG_ACTIVITY_NEW_TASK
         * */
        notificationClickHandler = new UmengNotificationClickHandler() {

            @Override
            public void handleMessage(Context context, UMessage uMessage) {
                Log.e("avery_zjz", "dealWithCustomAction" );
                Log.e("avery_zjz", new Boolean(mClickCallBack != null).toString() );
                // msg add to list
                if (mClickCallBack != null) {
                    // for
                    mClickCallBack.onCallBack(EventConstant.CLICK_MSG, uMessage);
                }
                super.handleMessage(context, uMessage);
            }

            @Override
            public void dealWithCustomAction(Context context, UMessage msg) {
                Toast.makeText(context, msg.custom, Toast.LENGTH_LONG).show();
            }
        };
        //使用自定义的NotificationHandler，来结合友盟统计处理消息通知，参考http://bbs.umeng.com/thread-11112-1-1.html
        //CustomNotificationHandler notificationClickHandler = new CustomNotificationHandler();
        mPushAgent.setNotificationClickHandler(notificationClickHandler);

        // 设置 APP在前台的时候 不在通知栏显示
        mPushAgent.setNotificaitonOnForeground(false);

//        mPushAgent.setPushIntentServiceClass(YouMengPushIntentService.class);

        //注册推送服务 每次调用register都会回调该接口
        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String deviceToken) {
                Log.e("avery_zjz", "device token: " + deviceToken);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.e("avery_zjz", "register failed: " + s + " " + s1);
            }
        });
        if (ReactBuildConfig.DEBUG) {
            UMConfigure.getTestDeviceInfo(context);
        }
    }
}

