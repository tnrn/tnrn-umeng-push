package com.tnrn.UMPush;

import com.umeng.message.entity.UMessage;

/**
 * Created by zhangjz on 2019/3/14.
 */

interface PushEventCallBack {
    /**
     * 当接受到消息的回调，
     * @param type 消息类型 目前只有2中类型 0: 接受消息回调 1: 点击通知栏回调
     * */
    void onCallBack(int type, UMessage msg);
}
