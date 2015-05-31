//
//  DeviceState.ios.js
//  [redacted]
//
//  Created by Dr. Kibitz <info@drkibitz.com> on 4/13/15.
//  Copyright (c) 2015 Dr. Kibitz <info@drkibitz.com> All rights reserved.
//
'use strict';

var NativeModules = require('NativeModules');
var RCTDeviceEventEmitter = require('RCTDeviceEventEmitter');
var RCTDeviceState = NativeModules.DeviceState;

var logError = require('logError');

var DeviceStateIOS = {

    Event: {
        ORIENTATION_DID_CHANGE: 'orientationDidChange',
        BATTERY_STATE_DID_CHANGE: 'batteryStateDidChange',
        BATTERY_LEVEL_DID_CHANGE: 'batteryLevelDidChange',
        DEVICE_READY: 'deviceReady',
    },

    currentState: {
        orientation: (null : ?String),
        batteryState: (null : ?String),
        batteryLevel: (null : ?Number),
    }
};

RCTDeviceEventEmitter.addListener(DeviceStateIOS.Event.ORIENTATION_DID_CHANGE, (newState) => {
    DeviceStateIOS.currentState.orientation = newState.orientation;
});

RCTDeviceEventEmitter.addListener(DeviceStateIOS.Event.BATTERY_STATE_DID_CHANGE, (newState) => {
    DeviceStateIOS.currentState.batteryState = newState.batteryState;
});

RCTDeviceEventEmitter.addListener(DeviceStateIOS.Event.BATTERY_LEVEL_DID_CHANGE, (newState) => {
    DeviceStateIOS.currentState.batteryLevel = newState.batteryLevel;
});

RCTDeviceState.getCurrentDeviceState(
    (newState) => {
        DeviceStateIOS.currentState.orientation = newState.orientation;
        DeviceStateIOS.currentState.batteryState = newState.batteryState;
        DeviceStateIOS.currentState.batteryLevel = newState.batteryLevel;
        RCTDeviceEventEmitter.emit(DeviceStateIOS.Event.DEVICE_READY);
    },
    logError
);

module.exports = DeviceStateIOS;
