# SumUp mPOS SDK: Air Register Support

The following information is only relevant if you want to support the SumUp
Air Register device. For general setup instructions, please refer to our main
[README](../README.md).

### Table of Contents

* [Installation](#installation)
  * [External Accessory Protocols](#external-accessory-protocols)
  * [MFi Program Authorization](#mfi-program-authorization)
* [Getting started](#getting-started)
  * [Register SDK](#register-sdk)
* [Changelog](#changelog)

## Installation

### External Accessory Protocols

After [integrating the SumUp SDK](../README.md#installation), please perform
this step, regardless of your chosen integration option:

1. Add the following `UISupportedExternalAccessoryProtocols` to your app's
  [Info.plist](../SampleApp/SumUpSDKSampleApp/SumUpSDKSampleApp-Info.plist) file:

        com.sumup.control
        com.sumup.printing
        com.sumup.air_data

> You can add these protocols to the Swift sample app for a working register
demo screen.

### MFi Program Authorization

When your app communicates with the SumUp Air Register, which is an approved
[MFi](https://developer.apple.com/programs/mfi/) device, Apple requires your application to be registered before
submission to the App Store.
This registration process officially associates your app with SumUp Air Register,
and can only be performed by SumUp.
Once your application has been registered, future app versions will not require
additional registrations.
Please get in touch with integration@sumup.com providing your bundle identifier
and team ID before submission.

> This step is only required to publish your app on the App Store. For Ad-Hoc builds
and Enterprise Distribution this is not necessary.

## Getting started

Before accessing `[SMPSumUpRegisterSDK sharedInstance]`, call `[SMPSumUpRegisterSDK registerIsSupported]`
to verify that you have set up the register SDK correctly.

## Register SDK

The SumUp Air Register is automatically used as the preferred card terminal while it is
connected. To use the integrated printer and query its current status, use the
`SumupRegisterSDK` class. Please make sure that all
`UISupportedExternalAccessoryProtocols` are included in your apps
[Info.plist](../SampleApp/SumUpSDKSampleApp/SumUpSDKSampleApp-Info.plist).

```objc
[[SMPSumUpRegisterSDK sharedInstance] setDelegate:self];
[[SMPSumUpRegisterSDK sharedInstance] startListeningForRegister];

- (void)registerDidConnect:(SMPRegisterSDKStatus *)deviceStatus {
    [[SMPSumUpRegisterSDK sharedInstance] printEscPos:@"Device is conntected"];
}

```

> The register-specific APIs are available without login.

## Changelog

[SumUp Air Register SDK Changelog](CHANGELOG.md)
