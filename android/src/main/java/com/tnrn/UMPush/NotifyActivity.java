package com.tnrn.UMPush;

import android.content.ComponentName;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.umeng.message.UmengNotifyClickActivity;

import org.android.agoo.common.AgooConstants;

/**
 * @author avery-zjz
 * @description 该activity 是 Umeng 接受友盟离线推送的
 * */
public class NotifyActivity extends UmengNotifyClickActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notify);
    }

    /**
     * 该方法是接受到友盟离线推送的回调
     * */
    @Override
    public void onMessage(Intent intent) {
        super.onMessage(intent);  //此方法必须调用，否则无法统计打开数
        String body = intent.getStringExtra(AgooConstants.MESSAGE_BODY);
        Log.i("avery_zjz", body);

        // 传递消息到 RNUMPushModule
        RNUMPushModule.onMessageOutLine(body);

        // 跳转到 主activity
        Intent newIntent = new Intent();
        newIntent.setClassName("com.rongxin.wellloan", "com.rongxin.wellloan.MainActivity");

        this.startActivity(newIntent);
        this.finish();
    }
}
