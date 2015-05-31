//
//  RCTDeviceState.m
//  [redacted]
//
//  Created by Dr. Kibitz <info@drkibitz.com> on 4/13/15.
//  Copyright (c) 2015 Dr. Kibitz <info@drkibitz.com> All rights reserved.
//

#import "RCTDeviceState.h"

#import "RCTAssert.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

NSString *const RCTDeviceOrientationDidChangeEvent = @"orientationDidChange";
NSString *const RCTDeviceBatteryStateDidChangeEvent = @"batteryStateDidChange";
NSString *const RCTDeviceBatteryLevelDidChangeEvent = @"batteryLevelDidChange";

static NSString *RCTConvertDeviceOrientation(UIDeviceOrientation orientation)
{
  static NSDictionary *states;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    states = @{
      @(UIDeviceOrientationPortrait): @"portrait",
      @(UIDeviceOrientationPortraitUpsideDown): @"portrait",
      @(UIDeviceOrientationLandscapeLeft): @"landscape",
      @(UIDeviceOrientationLandscapeRight): @"landscape",
    };
  });

  return states[@(orientation)] ?: @"unknown";
}

static NSString *RCTConvertDeviceBatteryState(UIDeviceBatteryState batteryState)
{
  static NSDictionary *states;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    states = @{
      @(UIDeviceBatteryStateUnknown): @"unknown",
      @(UIDeviceBatteryStateUnplugged): @"unplugged",
      @(UIDeviceBatteryStateCharging): @"charging",
      @(UIDeviceBatteryStateFull): @"full"
    };
  });

  return states[@(batteryState)] ?: @"unknown";
}

@implementation RCTDeviceState
{
  UIDeviceOrientation _lastKnownOrientation;
  UIDeviceBatteryState _lastKnownBatteryState;
  float _lastKnownBatteryLevel;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

#pragma mark - Lifecycle

- (instancetype)init
{
  if ((self = [super init])) {

    _lastKnownOrientation = [[UIDevice currentDevice] orientation];
    _lastKnownBatteryState = [[UIDevice currentDevice] batteryState];
    _lastKnownBatteryLevel = [[UIDevice currentDevice] batteryLevel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleDeviceOrientationDidChange)
                                                name:UIDeviceOrientationDidChangeNotification
                                                object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleDeviceBatteryStateDidChange)
                                                name:UIDeviceBatteryStateDidChangeNotification
                                                object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleDeviceBatteryLevelDidChange)
                                                name:UIDeviceBatteryLevelDidChangeNotification
                                                object:nil];
  }
  return self;
}


- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Device Notification Methods

- (void)handleDeviceOrientationDidChange
{
  UIDeviceOrientation newOrientation = [[UIDevice currentDevice] orientation];
  // Ignore specific orientations
  if (newOrientation == UIDeviceOrientationFaceUp ||
      newOrientation == UIDeviceOrientationFaceDown ||
      newOrientation == UIDeviceOrientationUnknown ||
      _lastKnownOrientation == newOrientation) {
    return;
  }
  // Respond to only landscape or portrait
  _lastKnownOrientation = newOrientation;

  [_bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                              body:@{@"orientation": RCTConvertDeviceOrientation(_lastKnownOrientation)}];
}

- (void)handleDeviceBatteryStateDidChange
{
  UIDeviceBatteryState newBatteryState = [[UIDevice currentDevice] batteryState];
  // Ignore specific states
  if (newBatteryState == UIDeviceBatteryStateUnknown ||
      _lastKnownBatteryState == newBatteryState) {
    return;
  }
  _lastKnownBatteryState = newBatteryState;

  [_bridge.eventDispatcher sendDeviceEventWithName:@"batteryStateDidChange"
                                              body:@{@"batteryState": RCTConvertDeviceBatteryState(_lastKnownBatteryState)}];
}

- (void)handleDeviceBatteryLevelDidChange
{
  float newBatteryLevel = [[UIDevice currentDevice] batteryLevel];
  // Ignore unknown level
  if (newBatteryLevel < 0 ||
      _lastKnownBatteryLevel == newBatteryLevel) {
    return;
  }
  _lastKnownBatteryLevel = newBatteryLevel;

  [_bridge.eventDispatcher sendDeviceEventWithName:@"batteryLevelDidChange"
                                              body:@{@"batteryLevel":[NSNumber numberWithFloat:_lastKnownBatteryLevel]}];
}

#pragma mark - Public API

/**
 * Get the current orientation, batteryState, and batteryLevel of the device
 */
RCT_EXPORT_METHOD(getCurrentDeviceState:(RCTResponseSenderBlock)callback
                  error:(__unused RCTResponseSenderBlock)error)
{
  callback(@[@{
    @"orientation": RCTConvertDeviceOrientation(_lastKnownOrientation),
    @"batteryState": RCTConvertDeviceBatteryState(_lastKnownBatteryState),
    @"batteryLevel": [NSNumber numberWithFloat:_lastKnownBatteryLevel]
  }]);
}

//- (NSDictionary *)constantsToExport
//{
//  return @{
//    @"Orientation": @{
//      @"unknown": @(UIDeviceOrientationUnknown),
//      @"portrait": @(UIDeviceOrientationPortrait),
//      @"portraitUpsideDown": @(UIDeviceOrientationPortraitUpsideDown),
//      @"landscapeLeft": @(UIDeviceOrientationLandscapeLeft),
//      @"landscapeRight": @(UIDeviceOrientationLandscapeRight),
//      @"faceUp": @(UIDeviceOrientationFaceUp),
//      @"faceDown": @(UIDeviceOrientationFaceDown),
//    },
//    @"BatteryState": @{
//      @"unknown": @(UIDeviceBatteryStateUnknown),
//      @"unplugged": @(UIDeviceBatteryStateUnplugged),
//      @"charging": @(UIDeviceBatteryStateCharging),
//      @"full": @(UIDeviceBatteryStateFull),
//    },
//  };
//}

@end
