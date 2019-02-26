/*
 * index.js
 * tnrn-umeng-push
 * description
 * 
 * Created by winter on 2019-02-19 18:09:43.
 * Copyright (c) 2018 Touna.cn, Inc.
 */

import {
  NativeModules,
  Platform,
  DeviceEventEmitter
} from 'react-native';

const RNUmengPush = NativeModules.RNUmengPush;

export default class UMPush {

  // 获取push devicetoken
  static getDeviceToken(callback = () => { }) {
    RNUmengPush.getDeviceToken(callback)
  }

  // 获取push 权限
  static getAuthorizationStatus(callback = () => { }) {
    RNUmengPush.getAuthorizationStatus(callback)
  }

  // 收到推送消息
  static receiveNotification(callback = () => { }) {
    RNUmengPush.receiveRemoteNotification(callback)
  }

  // 点击推送消息 打开App
  static openNotification(callback = () => { }) {
    RNUmengPush.openRemoteNotification(callback)
  }

  // 给当前设备添加标签
  static addTag(tag = '', callback = () => { }) {
    RNUmengPush.addTag(tag, callback)
  }

  // 删除当前设备的当前标签
  static deleteTag(tag = '', callback = () => { }) {
    RNUmengPush.deleteTag(tag, callback)
  }

  // 列出当前设备的所有标签
  static listTags(callback = () => { }) {
    RNUmengPush.listTag(callback)
  }

  // 设备添加别名 默认平台类型为'tnrn'
  static addAlias(alias = '', callback = () => { }, type = 'tnrn') {
    RNUmengPush.addAlias(alias, type, callback)
  }

  // 重置该设备所有的别名为 alias 默认平台类型为'tnrn'
  static resetAlias(alias = '', callback = () => { }, type = 'tnrn') {
    RNUmengPush.addExclusiveAlias(alias, type, callback)
  }

  // 删除该设备的别名 默认平台类型为'tnrn'
  static deleteAlias(alias = '', callback = () => { }, type = 'tnrn') {
    RNUmengPush.deleteAlias(alias, type, callback)
  }
}