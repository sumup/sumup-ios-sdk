# SumUp mPOS SDK - iOS

[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg?style=flat-square)](#prerequisites)
[![Created](https://img.shields.io/badge/Made%20by-SumUp-blue.svg?style=flat-square)](https://sumup.com)
[![Supports](https://img.shields.io/badge/Requires-iOS%2010+-red.svg?style=flat-square)]()
[![Version](https://img.shields.io/badge/Version-4.3.0-yellowgreen.svg?style=flat-square)](CHANGELOG.md)
[![License](https://img.shields.io/badge/License-SumUp-brightgreen.svg?style=flat-square)](LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/SumUpSDK.svg?style=flat-square)]()
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This repository provides a native iOS SDK that enables you to integrate SumUp's proprietary
card terminal(s) and its payment platform to accept credit and debit card payments
(incl. VISA, MasterCard, American Express and more). SumUp's SDK communicates transparently
to the card terminal(s) via Bluetooth (BLE 4.0) or an audio cable connection. Upon initiating
a checkout, the SDK guides your user using appropriate screens through each step of the payment
process. As part of the process, SumUp also provides the card terminal setup screen, along with the
cardholder signature verification screen. The checkout result is returned with the relevant
data for your records.

No sensitive card data is ever passed through to or stored on the merchant’s phone.
All data is encrypted by the card terminal, which has been fully certified to the highest
industry standards (PCI, EMV I & II, Visa, MasterCard & Amex).

For more information, please refer to
[SumUp API documentation.](https://developer.sumup.com/).

### Prerequisites
1. Registered for a merchant account via SumUp's [country websites](https://sumup.com/) (or received a test account).
2. Received SumUp card terminal: Solo, Air, Air Lite, PIN+ terminal, Chip & Signature reader, or SumUp Air Register.
3. Requested an Affiliate (Access) Key via [SumUp Dashboard](https://me.sumup.com/developers) for Developers.
4. Deployment Target iOS 12.0 or later.
5. Recommended to use on Xcode 13 and iOS SDK 15 or later.
6. iPhone, iPad or iPod touch.

### Table of Contents
* [Installation](#installation)
  * [Manual Integration](#manual-integration)
  * [Integration via CocoaPods](#integration-via-cocoapods)
  * [Integration via Carthage](#integration-via-carthage)
  * [Integration via Swift PM](#integration-via-swift-pm)
  * [Supported device orientation](#supported-device-orientation)
  * [Privacy Info plist keys](#privacy-info-plist-keys)
* [Getting started](#getting-started)
  * [Import the SDK](#import-the-sdk)
  * [Authenticate app](#authenticate-app)
  * [Login](#login)
  * [Accept card payments](#accept-card-payments)
  * [Update checkout preferences](#update-checkout-preferences)
* [Out of Scope](#out-of-scope)
* [Community](#community)
* [Changelog](#changelog)
* [License](#license)

## Installation

If you want to support the SumUp Air Register, please also read our additional
[Air Register setup guide](AirRegister/README.md).

### Manual Integration

The SumUp SDK is provided as an XCFramework `SumUpSDK.xcframework` that contains
the headers and bundles bundles containing resources such as images and localizations.
Please follow the steps below to prepare your project:

1. Drag and drop the `SumUpSDK.xcframework` to your Xcode project's "Frameworks,
Libraries, and Embedded Content" on the General settings tab.
2. Make sure the [required Info.plist keys](#privacy-info-plist-keys) are present.

> Note:
> You can use the [sample app](SampleApp/SumUpSDKSampleApp)
> that is provided with the SumUp SDK as a reference project.
> The Xcode project contains sample apps written in Objective-C and Swift.
> See [Test your integration](#test-your-integration) for more information.

### Integration via CocoaPods

The SumUp SDK can be integrated via CocoaPods.

```ruby
target '<Your Target Name>' do
    pod 'SumUpSDK', '~> 4.0'
end
```

Make sure the [required Info.plist keys](#privacy-info-plist-keys) are present.

To learn more about setting up your project for CocoaPods, please refer to the [official documentation](https://cocoapods.org/#install).

### Integration via Carthage

:warning: Distributing XCFrameworks with the latest Carthage version (0.35.0) is not yet available.
There is an open issue ([#2799](https://github.com/Carthage/Carthage/issues/2799)) to solve this.
Once that issue is fixed, we expect Carthage to work again.

The SumUp SDK can be integrated with Carthage by following the steps below:

1. Add the following line to your `Cartfile`:

        github "sumup/sumup-ios-sdk"

2. Run `carthage update sumup-ios-sdk`
3. Drag and drop the `Carthage/Build/iOS/SumUpSDK.xcframework` to your Xcode project's "Frameworks,
Libraries, and Embedded Content" on the General settings tab.
4. Make sure the [required Info.plist keys](#privacy-info-plist-keys) are present.

To learn more about setting up your project for Carthage, please refer to the [official documentation](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

> Note:
> See [Test your integration](#test-your-integration) for more information.

### Integration via Swift PM

The latest Swift Package Manager version added support to [distribute binary frameworks as Swift Packages](https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages). Unfortunately there is a bug ([Bug Report SR-13343](https://bugs.swift.org/browse/SR-13343)), that adds the framework as a static library, not as an embedded dynamic framework. Follow this workaround to manage SumUp SDK versions via Swift PM:

Requirement: Xcode 12 beta 6 (swift-tools-version:5.3)

1. Add the package dependency to the repository `https://github.com/sumup/sumup-ios-sdk` (*File > Swift Packages > Add Package Dependency...*) with the version `Up to Next Major: 4.0.0`
2. Leave the checkbox unchecked for the SumUpSDK at the integration popup (*Add Package to ...:*)
![Swift PM - do not auto-integrate SDK](README/setup_swiftpm_skipautointegrate.png)
3. From the Project Navigator, drag and drop the `SumUpSDK/Referenced Binaries/SumUpSDK.xcframework` to your Xcode project's "Frameworks, Libraries, and Embedded Content" on the General settings tab.
4. Make sure the [required Info.plist keys](#privacy-info-plist-keys) are present.

To learn more about adding Swift Package dependencies, please refer to the [official documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

### Test your integration
In your debug setup you can call `+[SMPSumUpSDK testSDKIntegration]`.
It will run various checks and print its findings to the console.
Please do not call it in your Release build.

### Supported device orientation
The SDK supports all device orientations on iPad and portrait on iPhone.
Feel free to support other orientations on iPhone but please keep in mind that
the SDK's UI will be presented in portrait on iPhone.
See `UISupportedInterfaceOrientations` in the sample app's
[Info.plist](SampleApp/SumUpSDKSampleApp/SumUpSDKSampleApp-Info.plist#L54-L65)
or the "General" tab in Xcode's Target Editor.

### Privacy Info plist keys
The SumUp SDK requires access to the user's location and Bluetooth peripherals. If your app has not asked for the user's permission,
the SumUp SDK will ask at the time of the first login or checkout attempt. Please add the
following keys to your info plist file:

        NSLocationWhenInUseUsageDescription
        NSBluetoothAlwaysUsageDescription
        NSBluetoothPeripheralUsageDescription (unless your deployment target is at least iOS 13)

> Note:
> - Please refer to the sample app's [Info.plist](SampleApp/SumUpSDKSampleApp/SumUpSDKSampleApp-Info.plist#L38-L43)
for more information regarding the listed permissions required.
> - You can provide localization by providing a localized
[InfoPlist.strings](SampleApp/SumUpSDKSampleApp/en.lproj/InfoPlist.strings) file.
> - For further information, see the iOS Developer Library on
[location usage on iOS 8 and later](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW26),
[Bluetooth peripheral usage](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW20).

## Getting started

### Import the SDK

To import the SDK in Objective-C source files, you can use `#import <SumUpSDK/SumUpSDK.h>`. If module
support is enabled in your project, you can use `@import SumUpSDK;` instead.

In Swift, use `import SumUpSDK`. You do not have to add any headers to your bridging header.

### Authenticate app
Before calling any additional feature of the SumUp SDK, you are required to set up the SDK with your Affiliate (Access) Key:
```objc
[SMPSumUpSDK setupWithAPIKey:@"MyAPIKey"];
```

> Note:
> `setupWithAPIKey:` checks for the user's location permission. Consequently,
do not call this method as part of the app launch. This method must be called on
the main queue.

### Login

Following app authentication, a registered SumUp merchant account needs to be logged in.
Present a login screen from your `UIViewController`, using the following method:
```objc
[SMPSumUpSDK presentLoginFromViewController:vc
                                   animated:YES
                            completionBlock:nil];
```


> Note:
>  It is also possible to login an account with a token, without the user entering their SumUp login credentials in the SDK. Please refer to section [Transparent Authentication](#transparent-authentication). 
>  
> To log out of the SDK, please refer to `logoutWithCompletionBlock:`.

### Accept card payments
Once logged in, you can start using the SumUp SDK to accept card payments.

#### Prepare checkout request
Prepare a checkout request that encapsulates the information regarding the transaction.

For this, you will need to create an instance of `SMPCheckoutRequest`:


```objc
SMPCheckoutRequest *request = [SMPCheckoutRequest requestWithTotal:[NSDecimalNumber decimalNumberWithString:@"10.00"]
                                                             title:@"your title"
                                                      currencyCode:[[SMPSumUpSDK currentMerchant] currencyCode]];
```

Please note that you need to pass an `NSDecimalNumber` as the total value.
While `NSDecimalNumber` is a subclass of `NSNumber` it is not advised to use the
convenience method of `NSNumber` to create an `NSDecimalNumber`.

#### Additional checkout parameters
When setting up the `SMPCheckoutRequest` object, the following optional parameters can be included:

##### Tip amount
A tip amount can be processed in addition to the `totalAmount` using the `tipAmount` parameter.
The tip amount will then be shown during the checkout process and be included in the response.
Please note that a tip amount cannot be changed during/after the checkout.
Just like the `totalAmount` it is an `NSDecimalNumber` so make sure to
not accidentally pass an `NSNumber`.

##### Transaction identifier
The `foreignTransactionID` identifier will be associated with the transaction
and can be used to retrieve details related to the transaction.
See [API documentation](https://docs.sumup.com/rest-api/#tag/Transactions) for details.
Please make sure that this ID is unique within the scope of the SumUp merchant account
and sub-accounts. It must not be longer than 128 characters.

```
// set an optional identifier
[request setForeignTransactionID:@"my-unique-id"];
```

##### Skip success screen
To skip the screen shown at the end of a successful transaction, the
`SMPSkipScreenOptionSuccess` option can be used.
When setting this option your application is responsible for displaying
the transaction result to the customer.
In combination with the Receipts API, your application can also send your own receipts,
see [API documentation](https://docs.sumup.com/rest-api/#tag/Transactions) for details.
Please note that success screens will still be shown when using the SumUp Air Lite readers.

##### Skip failed screen
To skip the screen shown at the end of a failed transaction, the
`SMPSkipScreenOptionFailed` option can be used.
When setting this option your application is responsible for displaying
the transaction result to the customer.
Please note that failed screens will still be shown when using the SumUp Air Lite readers.

### Prepare the SumUp Card terminal in advance
In order to prepare a SumUp card terminal for checkout, `prepareForCheckout` can be called in advance. A registered SumUp merchant account needs to be logged in, and the card terminal must already be setup. You should use this method to let the SDK know that the user is most likely starting a checkout attempt soon; for example when entering an amount or adding products to a shopping cart. This allows the SDK to take appropriate measures, like attempting to wake a connected card terminal.

### Transparent Authentication
To authenticate an account without the user typing in their SumUp credentials each time, you can generate an access token using OAuth2.0 and use it to transparently login to the SumUp SDK.

```objc
[SMPSumUpSDK loginWithToken:@"MY_ACCESS_TOKEN" 
                 completion:nil];
```

For information about how to obtain a token, please see the [API Documentation](https://developer.sumup.com/docs/authorization/).

If the token is invalid, `SMPSumUpSDKErrorInvalidAccessToken` will be returned.

#### Initiate Checkout Request
Start a payment by using the checkout request below:


```objc
[SMPSumUpSDK checkoutWithRequest:request
              fromViewController:vc
                      completion:^(SMPCheckoutResult *result, NSError *error) {
                      // handle completed and failed payments here
                      // retrieve information via result.additionalInfo
}];
```

#### Checkout Error Codes
Possible values of [error code](./SumUpSDK.xcframework/ios-armv7_arm64/SumUpSDK.framework/Headers/SMPSumUpSDK.h#L155) received in the `checkoutWithRequest:` completion block.

### Update checkout preferences
When logged in you can let merchants check and update their checkout
preferences. Merchants can select their preferred card terminal and set up a
new one if needed. The preferences available to a merchant depend on their
respective account settings.

```objc
[SMPSumUpSDK presentCheckoutPreferencesFromViewController:self
                                                 animated:YES
                                               completion:^(BOOL success, NSError * _Nullable error) {
                                                 if (!success) {
                                                   // there was a problem presenting the preferences
                                                 } else {
                                                   // next checkout will reflect the merchant's changes.
                                                 }
                                               }];
```

## Out of Scope
The following functions are handled by the [SumUp APIs](http://docs.sumup.com/rest-api/):
* [Refunds](https://docs.sumup.com/rest-api/#tag/Refunds)
* [Transaction history](https://docs.sumup.com/rest-api/#tag/Transactions)
* [Receipts](https://docs.sumup.com/rest-api/#tag/Receipts)
* [Account management](https://docs.sumup.com/rest-api/#tag/Account-Details)

## Community
- **Questions?** Get in contact with our integration team by sending an email to integration@sumup.com.
- **Found a bug?** [Open an issue](https://github.com/sumup/sumup-ios-sdk/issues/new).
Please provide as much information as possible.

## Changelog
[SumUp iOS SDK Changelog](CHANGELOG.md)

## License
[SumUp iOS SDK License](LICENSE)
