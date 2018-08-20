//
//  SMPSumUpSDK.h
//  SumUpSDK
//
//  Created by Felix Lamouroux on 29.01.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMPMerchant;
@class SMPCheckoutResult;
@class SMPCheckoutRequest;

NS_ASSUME_NONNULL_BEGIN

/// A common completion block used within the SumUpSDK that is called with a success value and an error object.
typedef void (^SMPCompletionBlock)(BOOL success, NSError * _Nullable error);

/**
 *  The completion block type that will be used when calling checkoutWithRequest:fromViewController:completion:
 *
 *  @param result a SMPCheckoutResult that provides information about the checkout process
 *  @param error  an error object in case the checkout can not be performed
 */
typedef void (^SMPCheckoutCompletionBlock)(SMPCheckoutResult * _Nullable result ,NSError * _Nullable error);

/// The SMPSumUpSDK class is your central interface with SumUp.
NS_SWIFT_NAME(SumUpSDK)
@interface SMPSumUpSDK : NSObject

/**
 *  @return YES if a merchant is logged in. NO otherwise.
 */
@property (class, readonly) BOOL isLoggedIn;

/// Returns a copy of the currently logged in merchant or nil if no merchant is logged in.
@property (class, readonly, nullable) SMPMerchant *currentMerchant;

/**
 *  @return YES if a checkout is in progress. NO otherwise.
 */
@property (class, readonly) BOOL checkoutInProgress;

/**
 *  Returns the SDK's CFBundleVersion
 *
 *  @return the SDK version
 */
@property(class, readonly) NSString *bundleVersion;

/**
 *  Returns the of the SDK's CFBundleShortVersionString
 *
 *  @return the short SDK version
 */
@property(class, readonly) NSString *bundleVersionShortString;

/**
 *  Sets up the SumUpSDK for use in your app.
 *
 *  Needs to be called from on the main thread at some point before starting interaction with the SDK.
 *  As this might ask for the user's location it should not necessarily be part
 *  of the app launch. Make sure to only setup once per app lifecycle.
 *
 *  If the user did not previously grant your app the permission to use her location,
 *  calling this method will prompt the user to grant such permission.
 *
 *  @param apiKey Your application's API Key for the SumUpSDK.
 *  @return YES if setup was successful. NO otherwise or if SDK has been set up before.
 */
+ (BOOL)setupWithAPIKey:(NSString *)apiKey;

/**
 *  Presents the login modally from the given view controller.
 *
 *  The login is automatically dismissed if login was successful or cancelled by the user.
 *  If error is nil and success is NO, the user cancelled the login.
 *  Errors are handled internally and usually do not need any display to the user.
 *  Does nothing if merchant is already logged in (calls completion block with success=NO, error=nil).
 *
 *  @param fromViewController The UIViewController instance from which the login should be presented modally.
 *  @param animated Pass YES to animate the transition.
 *  @param block The completion block is called after each login attempt.
 *
 */
+ (void)presentLoginFromViewController:(UIViewController *)fromViewController
                              animated:(BOOL)animated
                       completionBlock:(nullable SMPCompletionBlock)block;

/**
 *  Logs in a merchant with an access token acquired via http://docs.sumup.com/oauth/
 *  Make sure that no user is logged in already when calling this method.
 *
 *  @param aToken an access token
 *  @param block  a completion block that will run after login has succeeded/failed
 */
+ (void)loginWithToken:(NSString *)aToken completion:(nullable SMPCompletionBlock)block;

/**
 *  Can be called in advance when a checkout is imminent and a user is logged in.
 *  You should use this method to let the SDK know that the user is most likely starting a
 *  checkout attempt soon, e.g. when entering an amount or adding products to a shopping cart.
 *  This allows the SDK to take appropriate measures, like attempting to wake a connected card terminal.
 */
+ (void)prepareForCheckout;

/**
 *
 *  Presents a checkout view with all necessary steps to charge a customer.
 *
 *  Does nothing if merchant is not logged in or a checkout is already in progress.
 *  The completion block is always called.
 *
 *  @param request The SMPCheckoutRequest encapsulates all transaction relevant data such as total amount, label, etc.
 *  @param controller The UIViewController instance from which the checkout should be presented modally.
 *  @param block The completion block will be called when the view will be dismissed.
 */
+ (void)checkoutWithRequest:(SMPCheckoutRequest *)request
         fromViewController:(UIViewController *)controller
            completionBlock:(nullable SMPCompletionBlock)block DEPRECATED_MSG_ATTRIBUTE("Please use checkoutWithRequest:fromViewController:completion: instead.");


/**
 *  Presents a checkout view with all necessary steps to charge a customer.
 *
 *  @param request    request The SMPCheckoutRequest encapsulates all transaction relevant data such as total amount, label, etc.
 *  @param controller fromViewController The UIViewController instance from which the checkout should be presented modally.
 *  @param block      completion The completion block will be called when the view will be dismissed.
 */
+ (void)checkoutWithRequest:(SMPCheckoutRequest *)request
         fromViewController:(UIViewController *)controller
                 completion:(nullable SMPCheckoutCompletionBlock)block;

/**
 *  Presenting checkout preferences allows the current merchant to configure the checkout options and
 *  change the card terminal. Merchants can also set up the terminal when applicable.
 *  Can only be called when a merchant is logged in and checkout is not in progress.
 *  The completion block will be executed once the preferences have been dismissed.
 *  The success parameter indicates whether the preferences have been presented.
 *  If not successful an error will be provided, see SMPSumUpSDKError.
 *
 *  @param fromViewController The UIViewController instance from which the checkout should be presented modally.
 *  @param animated           Pass YES to animate the transition.
 *  @param block              The completion block is called after the view controller has been dismissed.
 */
+ (void)presentCheckoutPreferencesFromViewController:(UIViewController *)fromViewController
                                            animated:(BOOL)animated
                                          completion:(nullable SMPCompletionBlock)block;

/**
 *  Performs a logout of the current merchant and resets the remembered password.
 *
 *  @param block The completion block is called once the logout has finished.
 */
+ (void)logoutWithCompletionBlock:(nullable SMPCompletionBlock)block;

/**
 *  If enabled the SDK automatically displays UI notifications (similar to the ringer UI notifications from iOS) to the user when the reader state changes. Default is YES.
 *
 *  Notifications are only displayed once the SDK sees fit to do so. If you want to allow UI notifications to appear earlier,
 *  call this method with YES at any point after +setupWithAPIKey:. Be aware that this will prompt the user to grant permissions
 *  to your app to use the device's microphone.
 */
+ (void)setUINotificationsForReaderStatusEnabled:(BOOL)enabled;

#pragma mark - Error Domain and Codes

NS_SWIFT_NAME(SumUpSDKErrorDomain)
extern NSString * const SMPSumUpSDKErrorDomain;

/**
 *  The error codes returned from the SDK
 */
typedef NS_ENUM(NSInteger, SMPSumUpSDKError) {
    /// General error
    SMPSumUpSDKErrorGeneral                        = 0,
    /// The merchant's account is not activated
    SMPSumUpSDKErrorActivationNeeded               = 1,
    /// General error with the merchant's account
    SMPSumUpSDKErrorAccountGeneral                 = 20,
    /// The merchant is not logged in to their account
    SMPSumUpSDKErrorAccountNotLoggedIn             = 21,
    /// A merchant is logged in already. Call logout before logging in again.
    SMPSumUpSDKErrorAccountIsLoggedIn              = 22,
    /// Generel checkout error
    SMPSumUpSDKErrorCheckoutGeneral                = 50,
    /// Another checkout process is currently in progress.
    SMPSumUpSDKErrorCheckoutInProgress             = 51,
    /// The currency code specified in the checkout request does not match that of the current merchant.
    SMPSumUpSDKErrorCheckoutCurrencyCodeMismatch   = 52
} NS_SWIFT_NAME(SumUpSDKError);

#pragma mark - SDK Integration

/**
 *  You can use this method to test if you have integrated the SDK correctly.
 *
 *  The method will log several tests to the console. If you see any errors, please check the README for setup instructions.
 *
 *  @warning While not harmful, this method is not meant to be used in production. Use this in temporary code or in debug configurations only.
 *
 *  @return YES if the SDK is set up correctly, NO if any error was found.
 */
+ (BOOL)testSDKIntegration;

@end

NS_ASSUME_NONNULL_END
