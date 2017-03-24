# SumUp iOS SDK Changelog

## Version 2.2

* [BUGFIX] Fix a crash when trying to re-connect to an Air/PIN+ terminal,
  see [issue #33](https://github.com/sumup/sumup-ios-sdk/issues/33)
* [ADDED] Add `+[SumupSDK prepareForCheckout]` to prepare the SDK when a
  checkout attempt is imminent.
* [ADDED] Add `+[SumupSDK testSDKIntegration]` to validate your integration.
  Please do not call in Release builds but only in development.
* [IMPROVEMENT] Speed up wake on Bluetooth
* [IMPROVEMENT] Fix an issue where subsequent checkout attempts would keep
  failing when BT connection to Air/PIN+ Terminal has been lost during checkout.

Sample application:

* [ADDED] Tapping "Next" on the keyboard when entering an amount will wake a
  connected terminal by calling `+[SumupSDK prepareForCheckout]`.
* [ADDED] Run `+[SumupSDK testSDKIntegration]` when building in
  Debug configuration.


## Version 2.1

* [ADDED] Provide method to let merchants change their checkout preferences
  `+[SumupSDK presentCheckoutPreferencesFromViewController:animated:completion:]`

Sample application:

* [ADDED] Add button to present checkout preferences
* [BUGFIX] Add missing `-ObjC` linker flag to Swift sample app


## Version 2.0

* [IMPROVEMENT] Support latest Air and Air Lite terminals
* [IMPROVEMENT] Hosting app is no longer required to support any landscape
  device orientation on iPhone
* [IMPROVEMENT] Assert that SMPSharedResources is available when setting up SDK
  on simulator.
* [ADDED] Swift sample app
* [ADDED] Includes upcoming SSL certificate - Certificates included in any
  previous SDK version will expire Friday, 24th Feb 2017

## Version 1.3

**Deployment target changed to iOS 6.**

* [UPDATE] Base SDK is iOS 9.3, deployment target is iOS 6
* [ADDED] Provide additional information on transaction and payment
  instrument in `-[SMPCheckoutResult additionalInfo]`.
* [ADDED] New terminal including US support
* [BUGFIX] Fix an issue where some C&S transactions and mobile payments
  would incorrectly be reported as failed
* [IMPROVEMENT] Improve layout on iPhone 6, iPhone 6 Plus, and iPad Pro
* [IMPROVEMENT] Match style of SumUp iOS app version 1.60 and later
* [IMPROVEMENT] Improve support of Wake-on-Bluetooth PIN+ readers
* [IMPROVEMENT] Add nullability annotations
* [IMPROVEMENT] Prefix some internal classes to avoid duplicated symbols,
  see [issue 15](https://github.com/sumup/sumup-ios-sdk/issues/15).

Sample application:

* [UPDATE] Application supports large screens
* [UPDATE] Deployment target has been raised to iOS 6
* [IMPROVEMENT] Remove `-w` in other linker flags and hint from README.
* [IMPROVEMENT] Add NSBluetoothPeripheralUsageDescription to Info.plist

## Version 1.2.2

* [ADDED] `+[SumupSDK loginWithToken:completion:]` provides a way to log in a
merchant with an access token acquired using the
[authentication API](https://sumup.com/integration#APIAuth).
* [IMPROVEMENT] Always provide an error object if login fails in
`+[SumupSDK presentLoginFromViewController:animated:completionBlock]`
* [IMPROVEMENT] no need to link against `stdc++` anymore

## Version 1.2.1
* [IMPROVEMENT] Rename SBJson to [avoid conflicts](https://github.com/sumup/sumup-ios-sdk/issues/1).
* [UPDATE] Remove CFBundleExecutable entries from info.plist files of bundles to [fix ITMS-90535 error when submitting to iTC](https://github.com/sumup/sumup-ios-sdk/issues/4).
* [UPDATE] Add `-w` to `OTHER_LDFLAGS` of sample App to work around [linker warnings](http://stackoverflow.com/a/32543155).

## Version 1.2
**Important**: `AVFoundation` needs to be linked as **optional** if your deployment target is iOS 5.x

* [ADDED] `+[SumupSDK checkoutWithRequest:fromViewController:completion:]` returns the transaction code as well as the status of the checkout process.
* [ADDED] SMPCheckoutRequest can pass a foreign transaction ID to be associated with the transaction. Maximum length is 128 characters.
* [ADDED] Supports latest PIN+ readers and wake on bluetooth
* [IMPROVEMENT] Simplifies layout of sample code
* [IMPROVEMENT] Clarified usage of currency code in checkout by passing current merchant's transaction code in sample code.
* [DEPRECATED] `+[SumupSDK checkoutWithRequest:fromViewController:completionBlock:]` is deprecated
* [DEPRECATED] The sandbox environment is not supported anymore. Please get in touch and we will create a sandboxed test account for you.
* [REMOVED] Currency RUB is no longer supported

Needs to be linked against `Accelerate` framework.

### Version 1.1
* [UPDATE] Built on iOS 8.1
* [UPDATE] slices for armv7 arm64, i386 and x86_64
* [UPDATE] add `NSLocationWhenInUseUsageDescription` to sample app's Info.plist file and to Getting Started section
* [BUGFIX] accept WhenInUse location usage permission

### Version 1.0.2
* [BUGFIX] Stability improvements

### Version 1.0.1
* [UPDATE] Return an error in +[SumupSDK checkoutWithRequest:fromViewController:completionBlock:] if merchant is not logged in.
* [UPDATE] Return an error in +[SumupSDK checkoutWithRequest:fromViewController:completionBlock:] if another checkout is in progress.
* [BUGFIX] Fix connection to server in sandbox mode.

### Version 1.0
Initial version to support PIN+.
