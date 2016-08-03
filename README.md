# SumUp iOS SDK

## Version 1.3.0b4

- [Changelog](CHANGELOG.md)

#### Deployment Target
The SumUp SDK is suitable from iOS 6.0 to iOS 9 for iPad and iPhone,
so please set your deployment target to 6.0 or later.

## Getting started

### Preparing your Xcode project
*You can use the sample App that is provided with the SumUp SDK as a reference project.*


The SumUp SDK is provided to you as an embedded framework `SumupSDK.embeddedframework` that combines a static library, its headers and a bundle containing resources such as images and localizations.

Add the `SumupSDK.embeddedframework` to your Xcode project (e.g. in the group Frameworks). If you haven't done so already when adding it, ensure that

* `SumupSDK.embeddedframework/SumupSDK.framework`
* `SumupSDK.embeddedframework/Reources/SMPSharedResources.bundle`
* `SumupSDK.embeddedframework/Resources/YTLibResources.bundle`

are members of your app's target. Make sure your app is linked to `SumupSDK.framework`.

Lastly, the SumUp SDK has a few dependencies to system frameworks. Please make sure that your app links against the following frameworks:

* AVFoundation
* Accelerate
* MapKit

Please make sure to add `-ObjC` to "Other Linker Flags" if it is not included.


### Location/Microphone usage Info.plist keys
The SumUp SDK needs to access the user's location and the device's microphone.
If your app has not asked for the user's permission the SumUp SDK will ask at
the first login or checkout attempt. Please add the keys
`NSLocationWhenInUseUsageDescription` and `NSMicrophoneUsageDescription` to your
info plist file and add a (most likely english) explanation why the app needs
the user's location. You can provide localization using a localized
`InfoPlist.strings` file. For reference see the iOS Developer Library on
[location usage on iOS 6 and 7](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW27),
[iOS 8 and later](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW26)
and [microphone access in iOS 7 and later](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW25).

## Integrating the SumUp SDK with your app

Before calling any other method of the SumUp SDK you need setup the SumUp SDK with your API key:

```objc
#import <SumupSDK/SumupSDK.h>

// ...

[SumupSDK setupWithAPIKey:@"MyAPIKey"];
```
As this might ask for the user's location it should not necessarily be part
of the app launch.

Once the SumUp SDK is setup, you can start interacting with it.

### Login to SumUp

The logical next step after the setup is to allow the user to login to their SumUp account. You can present a login screen from your `UIViewController` using the following method:
```objc
[SumupSDK presentLoginfromViewController:vc
                                animated:YES
                         completionBlock:nil];
```

### Accept card payments

Once the user is logged in, you can use the SumUp SDK to accept card payments.

Before accepting card payment you need to prepare a checkout request that encapsulates the information regarding the transaction.

For this you will need to create an instance of `SMPCheckoutRequest`:


```objc
#import <SumupSDK/SumupSDK.h>

// ...

SMPCheckoutRequest *request = [SMPCheckoutRequest requestWithTotal:[NSDecimalNumber decimalNumberWithString:@"10.00"]
                                                             title:self.textFieldTitle.text
                                                      currencyCode:[[SumupSDK currentMerchant] currencyCode]
                                                    paymentOptions:SMPPaymentOptionAny];

// set an optional identifier
[request setForeignTransactionID:@"my-unique-id"];
```

Please be aware that you need to pass an `NSDecimalNumber` as the total value. While `NSDecimalNumber` is a subclass of `NSNumber` it is not advised to use the convenience method of `NSNumber` to create a `NSDecimalNumber`.

You can pass an optional transaction identifier in `foreignTransactionID`. This identifier will be associated with the transaction and can be used to retrieve this transaction later. See [API documentation](https://sumup.com/integration#transactionReportingAPIs) for details. Please make sure that this ID is unique within the scope of your SumUp SDK key. It must not be longer than 128 characters.

Using this checkout request you can then start accepting payments:


```objc
[SumupSDK checkoutWithRequest:request
           fromViewController:vc
                   completion:^(SMPCheckoutResult *result, NSError *error) {
                   // handle completed and failed payments here
                   // retrieve information via result.additionalInfo
}];
```
