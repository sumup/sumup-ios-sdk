# SumUp mPOS SDK - iOS

[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg?style=flat-square)](#prerequisites)
[![Created](https://img.shields.io/badge/Made%20by-SumUp-blue.svg?style=flat-square)]()
[![Supports](https://img.shields.io/badge/Requires-iOS%206+-red.svg?style=flat-square)]()
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/SumupSDK.svg?style=flat)](https://cocoapods.org/pods/SumupSDK)
[![Version](https://img.shields.io/badge/Version-2.3-yellowgreen.svg?style=flat-square)](CHANGELOG.md)
[![License](https://img.shields.io/badge/License-SumUp-brightgreen.svg?style=flat-square)](LICENSE)


This repository provides a native iOS SDK that enables you to integrate SumUp's proprietary
card terminal(s) and its payment platform to accept credit and debit card payments
(incl. VISA, MasterCard, American Express and more). SumUp's SDK communicates transparently
to the card terminal(s) via Bluetooth (BLE 4.0) or an audio cable connection. Upon initiating
a checkout, the SDK guides your user using appropriate screens through each step of the payment
process. As part of the process, SumUp provides also the card terminal setup screen, along with the
cardholder signature verification screen. The checkout result is returned with the relevant
data for your records.

No sensitive card data is ever passed through to or stored on the merchant’s phone.
All data is encrypted by the card terminal, which has been fully certified to the highest
industry standards (PCI, EMV I & II, Visa, MasterCard & Amex).

For more information, please refer to SumUp's
[integration website](https://sumup.com/integration#terminalPaymentSDK).

### Prerequisites
1. Registered for a merchant account via SumUp's [country websites](https://sumup.com/) (or received a test account).
2. Received SumUp card terminal: Air, Air Lite, PIN+ terminal or Chip & Signature reader.
3. Requested an Affiliate (Access) Key via [SumUp Dashboard](https://me.sumup.com/developers) for Developers.
4. Deployment Target iOS 6.0 or later.
5. Xcode 7 and iOS SDK 9 or later.
6. iPhone, iPad or iPod touch.

### Table of Contents
* [Installation](#installation)
    * [CocoaPods](#cocoapods)
    * [Manual Installation](#manual-installation)
    * [Supported device orientation](#supported-device-orientation)
    * [Privacy Info plist keys](#privacy-info-plist-keys)
* [Getting started](#getting-started)
  * [Authenticate app](#authenticate-app)
  * [Login](#login)
  * [Accept card payments](#accept-card-payments)
  * [Update checkout preferences](#update-checkout-preferences)
* [Community](#community)
* [Changelog](#changelog)
* [License](#license)

## Installation

### CocoaPods

CocoaPods is a dependency manager for Objective-C and Swift.
To learn more about setting up your project for CocoaPods, please refer to the [official documentation](https://cocoapods.org/#install).
To integrate SumUp SDK into your Xcode project using CocoaPods, you have to add it to your project's `Podfile`:

```ruby
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'SumupSDK'
end
```

Afterwards, run the following command:

```bash
$ pod install
```

### Manual Installation

The SumUp SDK is provided as an embedded framework `SumupSDK.embeddedframework`
that combines a static library, its headers and bundles containing resources such as
images and localizations. Please follow the steps below to prepare your project:

1. Add the `SumupSDK.embeddedframework` to your Xcode project.
2. Link your app against `SumupSDK.framework`.
3. Link your app against the following system frameworks:

        Accelerate
        AVFoundation
        MapKit

4. Add `-ObjC` to "Other Linker Flags" if not yet included.

5. Add the bundles provided in `SumupSDK.embeddedframework/Resources`
   to your app target.

        SumupSDK.embeddedframework/Resources/SMPSharedResources.bundle
        SumupSDK.embeddedframework/Resources/YTLibResources.bundle


> Note:
> You can use the [sample app](https://github.com/sumup/sumup-ios-sdk/tree/master/SumupSDKSampleApp)
> that is provided with the SumUp SDK as a reference project.
> The Xcode project contains sample apps written in Objective-C and Swift.
> In your debug setup you can also call `+[SumupSDK testSDKIntegration]`.
> It will run various checks and print its findings  to the console.
> Please do not call it in your Release build.



### Supported device orientation
The SDK supports all device orientations on iPad and portrait on iPhone.
Feel free to support other orientations on iPhone but please keep in mind that
the SDK's UI will be presented in portrait on iPhone.
See `UISupportedInterfaceOrientations` in the sample app's
[Info.plist](SumupSDKSampleApp/SumupSDKSampleApp-Info.plist#L56-L67)
or the "General" tab in Xcode's Target Editor.

### Privacy Info plist keys
The SumUp SDK requires access to the user's location, Bluetooth peripherals
and the device's microphone. If your app has not asked for the user's permission,
the SumUp SDK will ask at the time of the first login or checkout attempt. Please add the
following keys to your info plist file:

        NSLocationWhenInUseUsageDescription
        NSBluetoothPeripheralUsageDescription
        NSMicrophoneUsageDescription
        NSLocationUsageDescription (only if deployment target is iOS 6 or 7)

> Note:
> - Please refer to the sample app's [Info.plist](SumupSDKSampleApp/SumupSDKSampleApp-Info.plist#L38-L45)
for more information regarding the listed permissions required.
> - You can provide localization by providing a localized
[InfoPlist.strings](SumupSDKSampleApp/en.lproj/InfoPlist.strings) file.
> - For further information, see the iOS Developer Library on
[location usage on iOS 6 and 7](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW27),
[iOS 8 and later](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW26),
[Bluetooth peripheral usage](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW20)
and [microphone access in iOS 7 and later](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW25).


## Getting started
### Authenticate app
Before calling any additional feature of the SumUp SDK, you are required to set up the SDK with your Affiliate (Access) Key:
```objc
#import <SumupSDK/SumupSDK.h>

// ...

[SumupSDK setupWithAPIKey:@"MyAPIKey"];
```

> Note:
> `setupWithAPIKey:` checks for the user's location permission. Consequently,
do not call this method as part of the app launch.

### Login

Following app authentication, a registered SumUp merchant account needs to be logged in.
Present a login screen from your `UIViewController`, using the following method:
```objc
[SumupSDK presentLoginFromViewController:vc
                                animated:YES
                         completionBlock:nil];
```


> Note:
> To log out of the SDK, please refer to `logoutWithCompletionBlock:`.

### Accept card payments
Once logged in, you can start using the SumUp SDK to accept card payments.

#### Prepare checkout request
Prepare a checkout request that encapsulates the information regarding the transaction.

For this, you will need to create an instance `SMPCheckoutRequest`:


```objc
#import <SumupSDK/SumupSDK.h>

// ...

SMPCheckoutRequest *request = [SMPCheckoutRequest requestWithTotal:[NSDecimalNumber decimalNumberWithString:@"10.00"]
                                                             title:@"your title"
                                                      currencyCode:[[SumupSDK currentMerchant] currencyCode]
                                                    paymentOptions:SMPPaymentOptionAny];
```

Please note that you need to pass an `NSDecimalNumber` as the total value.
While `NSDecimalNumber` is a subclass of `NSNumber` it is not advised to use the
convenience method of `NSNumber` to create an `NSDecimalNumber`.

#### Additional checkout parameters
When setting up the `SMPCheckoutRequest` object, the following optional parameters can be included:

##### Tip amount
An tip amount can be processed in addition to the `totalAmount` using the `tipAmount` parameter.
The tip amount will then be shown during the checkout process and be included in the response.
Please note that a tip amount cannot be changed during/after the checkout.
Just like the `totalAmount` it is an `NSDecimalNumber` so make sure to
not accidentally pass an `NSNumber`.

##### Transaction identifier
The `foreignTransactionID` identifier will be associated with the transaction
and can be used to retrieve details related to the transaction.
See [API documentation](https://sumup.com/docs/rest-api/transactions-api) for details.
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
In combination with the Receipts API your application can also send your own receipts,
see [API documentation](https://sumup.com/docs/rest-api/transactions-api) for details.
Please note success screens will still be shown when using the SumUp Air Lite readers.

#### Initiate Checkout Request
Start a payment by using the checkout request below:


```objc
[SumupSDK checkoutWithRequest:request
           fromViewController:vc
                   completion:^(SMPCheckoutResult *result, NSError *error) {
                   // handle completed and failed payments here
                   // retrieve information via result.additionalInfo
}];
```

### Update checkout preferences
When logged in you can let merchants check and update their checkout
preferences. Merchants can select their preferred card terminal and set up a
new one if needed. The preferences available to a merchant depend on their
respective account settings.

```objc
[SumupSDK presentCheckoutPreferencesFromViewController:self
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
* [Refunds](http://docs.sumup.com/rest-api/transactions-api/#merchant-refunds)
* [Transaction history](http://docs.sumup.com/rest-api/transactions-api/#merchant-transactions)
* [Receipts](http://docs.sumup.com/rest-api/transactions-api/#receipts)
* [Account management](http://docs.sumup.com/rest-api/accounts-api/)

## Community
- **Questions?** Get in contact with our integration team by sending an email to
<a href="mailto:integration@sumup.com">integration@sumup.com</a>.
- **Found a bug?** [Open an issue](https://github.com/sumup/sumup-ios-sdk/issues/new).
Please provide as much information as possible.

## Changelog
[SumUp iOS SDK Changelog](CHANGELOG.md)

## License
[SumUp iOS SDK License](LICENSE)
