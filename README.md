# LT SDK for iOS sample
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)

[![cocoapods](https://img.shields.io/cocoapods/v/LTSDK)](https://github.com/LoFTechs/LTSDK-iOS)


## Introduction

With LT SDK, you can build your own customized application with Call function. This document provides a demonstration of the LTCallSDK method, showing how to implement call-related operations.


## Getting started

This section explains the steps you need to take before testing the iOS LTCallSample app.


## Installation

To use our iOS sample, you should first install [LTCallSample for iOS](https://github.com/LoFTechs/LTCallSample-iOS-ObjectiveC) 1.0.0 or higher.
### Requirements

|Sample|iOS|
|---|---|
| LTCallSample |1.0.0 or higher|


### Install LT SDK for iOS

You can install LT SDK for iOS through `cocoapods`.

To install the pod, add following line to your Podfile:


```
pod 'LTSDK'
pod 'LTCallSDK'
``` 

Set Develop api data and password to `LTCallSample/Common/Resource/UserInfo.plist`.

```properties
LICENSEKEY="<YOUR_LINCENSE_KEY>"
USERID="<YOUR_USER_ID>"
UUID="<YOUR_UUID>"
URL="<YOUR_AUTH_API>"
``` 

## FAQ: Common Issues and Why VoIP Push Notifications May Not Be Received

If your iOS app is not receiving VoIP push notifications, refer to the checklist below to troubleshoot common misconfigurations and issues.

### Configuration Issues

 1. `Background Modes` ➜ `Voice over IP` Not Enabled
- ✅ Fix: In Xcode, go to **Signing & Capabilities** > Add `Background Modes` and check **Voice over IP**.

 2. `Push Notifications` Capability Missing
- ✅ Fix: In **Signing & Capabilities**, add the **Push Notifications** capability.

 3. Testing on Simulator
- 🚫 VoIP Push is not supported on iOS simulators.
- ✅ Fix: Always test using a real device.