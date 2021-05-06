# SumUp iOS SDK Changelog

## Version 4.1.1

* [BUGFIX] Podspec fix. The release v4.1.0 does not work with Cocoapods due to an issue in the Podspec file. All changes mentioned in v4.1.0 are available in this release.

## Version 4.1.0

* [ADDED] Introduced support for Brazilian PIN+ Contactless Card Reader.
* [REMOVED] Dropped support for PIN+ card reader in cable mode. Merchants are advised to switch from cable to Bluetooth connection to continue using their PIN+ reader.
* [IMPROVEMENT] Introduced an error code for [duplicate foreign transaction ID](https://github.com/sumup/sumup-ios-sdk#transaction-identifier) - SMPSumUpSDKErrorDuplicateForeignID & for invalid access token - SMPSumUpSDKErrorInvalidAccessToken. See [API documentation](https://developer.sumup.com/rest-api/#tag/Transactions) for details.
* [IMPROVEMENT] Miscellaneous bug fixes and UI enhancements.

## Version 4.0.1

* [UPDATE] Replaced deprecated `UIAlertView` usage with `UIAlertController`. (Solves [issue #93](https://github.com/sumup/sumup-ios-sdk/issues/93))

## Version 4.0.0

* [REMOVED] Payment options provided when creating a checkout request will be ignored and default to `.any`. Options presented will be governed by merchant settings.
* [ADDED] Added Swift Package Manager support. See [integration instructions](README.md#integration-via-swift-pm).
* [BUGFIX] Remove pre-release version from CFBundleShortVersionString in XCFramework's Info.plist to pass ASC [validation](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleshortversionstring) which requires this to be a period-separated list of at most three non-negative integers.
* [UPDATE] Deprecated method `+[SMPSumUpSDK checkoutWithRequest:fromViewController:completionBlock:]` has been removed from the interface, please use `+[SMPSumUpSDK checkoutWithRequest:fromViewController:completion:]` instead.

Sample application:

* [UPDATE] Do not provide payment options when creating a checkout request.

## Version 4.0.0-beta.1

* [CHANGED] The SumUp SDK is now a dynamic framework and is shipped as an XCFramework. If you had previous versions installed, check out the [Migration Guide](MIGRATION.md).
* [CHANGED] The `SMPSharedResources.bundle` is now part of the XCFramework and should
not be added to the app target
* :warning: The latest Carthage (0.35.0) is not yet compatible with
XCFrameworks ([#2799](https://github.com/Carthage/Carthage/issues/2799))

Sample application:

* [UPDATE] Remove `-ObjC` from Other Linker Flags

## Version 3.5

This is the last version published as a static library. Upcoming versions will be provided as
an xcframework to be compatible with future versions of Xcode.

* [UPDATE] Deployment target raised to iOS 10.0
* [UPDATE] This version of the SumUp SDK is built on Xcode 11.3.1 against iOS SDK 13.2
* [UPDATE] Does not link against UIWebView to be compliant with [ASC policy](https://developer.apple.com/news/?id=12232019b)
* [UPDATE] Sample apps' deployment target raised to iOS 10.0

## Version 3.4

*SDK versions v3.3 and earlier are currently not able to connect to SumUp on iOS 13.3 Beta 1 and Beta 2.*

* [UPDATE] Address an issue with changes to [trusted certificates introduced with iOS 13](https://support.apple.com/en-us/HT210176)
* [BUGFIX] Fix an issue where the host app's bundle name would not be displayed properly. Reported as part of [issue #84](https://github.com/sumup/sumup-ios-sdk/issues/84)

## Version 3.3

* [UPDATE] This version of the SumUp SDK is ready to be used with
  Xcode 11 and the iOS 13 SDK
* [ADDED] Added support for the latest generation of SumUp's Air and PIN+ readers
* [BUGFIX] Fix a crash in checkout preferences when trying to disable all options

## Version 3.2

* [UPDATE] Style updated to match our iOS app v2.0
* [UPDATE] Base SDK updated to iOS 12, built with Xcode 10.1
* [IMPROVEMENT] Location permissions are handled when presenting the
  login view controller. The merchant is asked to grant location
  permissions if needed and restricted from logging in when denied.
* [IMPROVEMENT] Added a section to the README on how to
  [integrate with Carthage](https://github.com/sumup/sumup-ios-sdk/blob/master/README.md#integration-via-carthage).
  Heavily inspired by [Zyphrax's](https://github.com/Zyphrax) help in
  [PR #42](https://github.com/sumup/sumup-ios-sdk/pull/43) addressing
  [issue #37](https://github.com/sumup/sumup-ios-sdk/issues/37).
* [BUGFIX] Fix a crash in checkout when trying to use an audio
  connection to a PIN+ or C&S readers when microphone permissions have
  been denied.
* [ADDED] Added support for the SumUp 3G reader

## Version 3.1

* [CHANGED] If you integrate the SDK manually, please link to the `ExternalAccessory`
  framework as per our [setup guide](README.md)
* [UPDATE] Deployment target raised to iOS 9.0
* [CHANGED] The login mask does not show the "Reveal password" button anymore
* [ADDED] SumUp [Air Register](AirRegister/README.md) support
* [IMPROVEMENT] Dedicated error code for currency mismatches – please refer to our
  [README](README.md) for hints regarding correct currency handling
* [[IMPROVEMENT]](https://github.com/sumup/sumup-ios-sdk/issues/11) Populate
  `NSLocalizedDescriptionKey` in SDK errors – you can still access
  `NSUnderlyingErrorKey` for more details regarding the underlying error
* [ADDED] New currency code constant (`CLP`) and new languages (`es-CL`, `et`)

## Version 3.0

* [UPDATE] Update target SDK to iOS 11, deployment target raised to iOS 8.0
* [REMOVED] Drop support for audio connection to first generation PIN+ devices.
  This implies that the `YTLibResources.bundle` has been removed.
* [IMPROVEMENT] Add module map for Swift integration without bridging headers
* [IMPROVEMENT] Prefer readonly properties over methods to improve Swift signatures
* [ADDED] Add CocoaPods integration support – use `pod SumUpSDK` in your Podfile

Sample application:

* [UPDATE] Update deployment target of Obj-C app to iOS 8
* [UPDATE] AVFoundation is linked as required since weak linking was only needed
  when running on iOS 5
* [IMPROVEMENT] Swift sample app uses modular imports instead of bridging headers

## Transition Guide to 3.0

When improving imported Swift names we took the opportunity to rename
and prefix some classes and enums. We've also renamed the SDK to
SumUpSDK to make it easier to integrate with CocoaPods.
Migrating your code base is easy.

* Remove the `SumupSDK.embeddedframework` and add the new
  one called `SumUpSDK.embeddedframework`. Make sure your target still links
  against the framework and still copies the resource bundle.
* Rename your imports `<SumupSDK/SumupSDK.h>` to `<SumUpSDK/SumUpSDK.h>`
  * If your project uses modules, you can use `@import SumUpSDK;` in Objective-C
  * Swift projects should always use `import SumUpSDK` instead global bridging header imports
* Rename all occurrences of `SumUpCompletionBlock` to `SMPCompletionBlock`
* In ObjC:
  - rename all case-sensitive occurrences of
  `SumupSDK` to `SMPSumUpSDK` (except for imports, see above),
* In Swift:
  - rename all case-sensitive occurrences of `SumupSDK` and `SMPSumupSDK`
  to `SumUpSDK`
  - remove trailing parantheses from `SumUpSDK`'s `isLoggedIn`,
  `checkoutInProgress`, `bundleVersion `, and `bundleVersionShortString`
  - rename `SMPSkipScreenOptions` to `SkipScreenOptions`

## Version 2.3.2

* [BUGFIX] Fix a crash in checkout on iPad Pro when building against iOS 11
* [IMPROVEMENT] Fix an outdated link to API docs.
  See [issue #49](https://github.com/sumup/sumup-ios-sdk/issues/49)


## Version 2.3.1

* [IMPROVEMENT] Fix layout issues in login and checkout when building against iOS 11
* [IMPROVEMENT] Add comment to point out that `setupWithAPIKey:`
  needs to be called on the main thread.
  See https://github.com/sumup/sumup-ios-sdk/issues/46


## Version 2.3

* [IMPROVEMENT] Support for future SumUp terminal.
* [ADDED] Add `SMPSkipScreenOptions` to allow for skipping the screen
  shown at the end of a successful transaction.
* [ADDED] Add `-[SMPCheckoutRequest tipAmount]` to provide an additional
  tip amount to be added to the total in checkout.

  Sample application:

* [ADDED] Add option to skip the receipt screen by setting the
  appropriate `SMPSkipScreenOptions` of the checkout request.
* [ADDED] Add option to specify tip amount.
* [IMPROVEMENT] Convert to Auto Layout

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
