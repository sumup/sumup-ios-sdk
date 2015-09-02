# SumUp iOS SDK Changelog

## Version 1.2.1b1
* [IMPROVEMENT] Rename SBJson to [avoid conflicts](https://github.com/sumup/sumup-ios-sdk/issues/1).

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
