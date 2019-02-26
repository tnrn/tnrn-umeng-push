/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 * @lint-ignore-every XPLATJSCOPYRIGHT1
 */

import React, { Component } from 'react';
import { Platform, StyleSheet, Text, View, Button, Alert } from 'react-native';
import UMPush from 'tnrn-umeng-push';

export default class App extends Component {

  componentDidMount() {
    UMPush.receiveNotification(result => {
      console.log('receiveNotification = ', result)
      this.alert('receiveMsg', JSON.stringify(result))
    })

    UMPush.openNotification(result => {
      console.log('openNotification = ', result)
      this.alert('openMsg', JSON.stringify(result))
    })
  }

  getDeviceToken = () => {
    UMPush.getDeviceToken(result => {
      console.log('deviceToken = ', result)
      this.alert('deviceToken', result)
    })
  }

  getAuthorizationStatus = () => {
    UMPush.getAuthorizationStatus(result => {
      console.log('getAuthorizationStatus = ', result)
      this.alert('status', result)
    })
  }

  addAlias = () => {
    UMPush.addAlias('test', (result) => {
      console.log('addAliais = ', result)
      this.alert('addAlias', JSON.stringify(result))
    })
  }

  alert = (title = 'title', msg = 'msg') => {
    Alert.alert(title, msg,
      [{ text: 'OK' }]
    )
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>友盟消息推送Demo!</Text>
        <Button
          title='UMPush addAlias'
          onPress={this.addAlias}
        />
        <Button
          title='UMPush getDeviceToken'
          onPress={this.getDeviceToken}
        />
        <Button
          title='UMPush getAuthorizationStatus'
          onPress={this.getAuthorizationStatus}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
