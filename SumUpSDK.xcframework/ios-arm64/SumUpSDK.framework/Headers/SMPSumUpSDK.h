//
//  SMPSumUpSDK.h
//  SumUpSDK
//
//  Created by Felix Lamouroux on 29.01.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPOfflineSessionDetails.h"
#import "SMPReaderStatus.h"

@class SMPMerchant;
@class SMPCheckoutResult;
@class SMPCheckoutRequest;

NS_ASSUME_NONNULL_BEGIN

/// A common completion block used within the SumUpSDK that is called with a success flag and an optional error object.
typedef void (^SMPCompletionBlock)(BOOL success, NSError * _Nullable error);

typedef void (^SMPOfflineRemainingTimeCompletionBlock)(NSTimeInterval remainingTime, NSError * _Nullable error);

typedef void (^SMPOfflineSessionDetailsCompletionBlock)(SMPOfflineSessionDetails * _Nullable sessionDetails, NSError * _Nullable error);

/**
 *  The completion block type that will be used when calling checkoutWithRequest:fromViewController:completion:
 *
 *  @param result a SMPCheckoutResult that provides information about the checkout process
 *  @param error  an error object in case the checkout can not be performed
 */
typedef void (^SMPCheckoutCompletionBlock)(SMPCheckoutResult * _Nullable result, NSError * _Nullable error);

/// The SMPSumUpSDK class is your central interface with SumUp.
NS_SWIFT_NAME(SumUpSDK)
@interface SMPSumUpSDK : NSObject

/**
 *  YES if a merchant is logged in. NO otherwise.
 */
@property (class, readonly) BOOL isLoggedIn;

/// Returns a copy of the currently logged in merchant or nil if no merchant is logged in.
@property (class, readonly, nullable) SMPMerchant *currentMerchant;

/**
 *  YES if a checkout is in progress. NO otherwise.
 */
@property (class, readonly) BOOL checkoutInProgress;

/**
 *  Returns the SDK's CFBundleIdentifier
 */
@property(class, readonly) NSString *bundleIdentifier;

/**
 *  Returns the SDK's CFBundleVersion
 */
@property(class, readonly) NSString *bundleVersion;

/**
 *  Returns the of the SDK's CFBundleShortVersionString
 */
@property(class, readonly) NSString *bundleVersionShortString;

/**
 *  Sets up the SumUpSDK for use in your app.
 *
 *  Needs to be called from the main thread at some point before starting interaction with the SDK.
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

#pragma mark - Authentication

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
 */
+ (void)presentLoginFromViewController:(UIViewController *)fromViewController
                              animated:(BOOL)animated
                       completionBlock:(nullable SMPCompletionBlock)block;

/**
 *  Logs in a merchant with an access token acquired via https://developer.sumup.com/docs/authorization/.
 *  You must implement the "Authorization code flow", the "Client credentials flow" is not supported.
 *  Make sure that no user is logged in already when calling this method.
 *
 *  @param aToken a user-scoped access token
 *  @param block  a completion block that will run after login has succeeded/failed
 */
+ (void)loginWithToken:(NSString *)aToken completion:(nullable SMPCompletionBlock)block;

/**
 *  Performs a logout of the current merchant and resets the remembered password.
 *
 *  @param block The completion block is called once the logout has finished.
 */
+ (void)logoutWithCompletionBlock:(nullable SMPCompletionBlock)block;

#pragma mark - Checkout

/**
 *  Can be called in advance when a checkout is imminent and a user is logged in.
 *  You should use this method to let the SDK know that the user is most likely starting a
 *  checkout attempt soon, e.g. when entering an amount or adding products to a shopping cart.
 *  This allows the SDK to take appropriate measures, like attempting to wake a connected card terminal.
 */
+ (void)prepareForCheckout;

/**
 *  Call in advance when you know that checkout will occur for the logged-in user.
 *
 *  Functionally the same as @c prepareForCheckout
 *  This version provides the option of supplying a @c SMPCompletionBlock where you can
 *  dismiss custom UI, check the reader status or perform a checkout.
 *
 *  @param block The block is called at the end of the preparation after asking the reader to wake.
 */
+ (void)prepareForCheckout:(nullable SMPCompletionBlock)block;

/**
 *  Presents a checkout view with all necessary steps to charge a customer.
 *
 *  @param request    The SMPCheckoutRequest encapsulates all transaction relevant data such as total amount, label, etc.
 *  @param controller The UIViewController instance from which the checkout should be presented modally.
 *  @param block      The completion block will be called when the view will be dismissed.
 */
+ (void)checkoutWithRequest:(SMPCheckoutRequest *)request
         fromViewController:(UIViewController *)controller
                 completion:(nullable SMPCheckoutCompletionBlock)block;

/**
 *  Presenting card reader settings allows the current merchant to switch to a different
 *  card reader, view general information about the current card reader, and connect to it.
 *  Can only be called when a merchant is logged in and checkout is not in progress.
 *  The completion block will be executed once the screen has been dismissed.
 *  If not successful an error will be provided, see SMPSumUpSDKError.
 *
 *  @param fromViewController The UIViewController instance from which the checkout should be presented modally.
 *  @param animated           Pass YES to animate the transition.
 *  @param block              The completion block is called after the view controller has been dismissed.
 */
+ (void)presentCardReaderSettingsFromViewController:(UIViewController *)fromViewController
                                           animated:(BOOL)animated
                                         completion:(nullable SMPCompletionBlock)externalCompletionBlock;

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
                                          completion:(nullable SMPCompletionBlock)block __attribute__((deprecated("Please use presentCardReaderSettingsFromViewController:animated:completion: instead")));

#pragma mark - Tap to Pay on iPhone

/**
 *  Checks whether the Tap to Pay on iPhone payment method is available for the current merchant and whether or
 *  not it requires activation to be performed via a call to
 *  `presentTapToPayActivationFromViewController:animated:completionBlock:`.
 *
 *  For the merchant to be able to use this payment method the following must be true:
 *
 *    - The feature must be available in the merchant's country
 *
 *    - It must be activated. This is where the merchant's Apple ID is linked with their SumUp account and the 
 *      iPhone is prepared to work as a card reader. As this can take a minute or so the first time, the
 *      merchant is shown a UI that introduces them to the feature as it initializes in the background.
 *
 *  The merchant must be logged in before you call this method.
 *
 *  @param availability YES if the feature is available for the current merchant and it's OK to start activation.
 *  @param isActivated  YES if activation has already been done for this device and merchant account
 */
+ (void)checkTapToPayAvailability:(void (^ _Nonnull)(BOOL isAvailable, BOOL isActivated, NSError * _Nullable error))block NS_SWIFT_NAME(checkTapToPayAvailability(completion:));

/**
 *  Performs activation for Tap to Pay on iPhone. This prepares the device, introduces the merchant to the
 *  feature and links their Apple ID to their SumUp account (which will require confirmation from the merchant.)
 *
 *  Call `checkTapToPayAvailability:` before calling this method to find out if this payment method is available
 *  and if activation is needed.
 *
 *  The merchant must be logged in before you call this method.
 *
 *  Tap to Pay on iPhone requirements:
 *
 *  - The hosting app must have the `com.apple.developer.proximity-reader.payment.acceptance`
 *    entitlement.
 *
 *  - The merchant must have an iPhone XS or later with iOS 16.4 or later (iOS 17 or later recommended.)
 *    The feature does not work with iPads.
 *
 *  @param fromViewController The UIViewController instance from which the UI should be presented modally.
 *  @param animated           Pass YES to animate the transition.
 *  @param block              The completion block is called after the view controller has been dismissed.
 */
+ (void)presentTapToPayActivationFromViewController:(UIViewController *)fromViewController
                                           animated:(BOOL)animated
                                    completionBlock:(nullable SMPCompletionBlock)block;

/**
 *  Returns the localized "Tap To Pay on iPhone" string.
 */
+ (NSString  * _Nonnull)tapToPayProductName;

#pragma mark - Offline Transactions

/**
 * @brief Synchronizes and persists the Offline session, including security definitions and
 * transaction limits.
 *
 * This method downloads the security definitions and transaction limits required for Offline
 * transactions. This data is stored locally on the device for later use. If data is already present, it
 * will be updated only if the method deems it necessary and permitted.
 *
 * Offline session data is unique to each merchant. This data is not shared between different
 * users; therefore, this synchronization must be performed for every merchant account used on
 * the device to ensure the correct limits and security policies are applied.
 *
 * This method is a prerequisite for the Offline feature. If the aforementioned data is not available
 * on the device, any call to Offline-related methods will fail.
 *
 * @note This method must be called while the device is online. The SDK automatically performs
 * this operation after a successful login; calling this method manually immediately after login is
 * redundant and discouraged. The Offline session persists even if the SDK is terminated or the
 * device is disconnected from the network.
 *
 * @param completion Block invoked upon completion. The result of the operation is provided
 * through the block parameters: 'success' indicates whether the synchronization was completed
 * successfully, while 'error' provides details if the operation failed.
 */
+ (void)setupOfflineSessionWithCompletion:(nullable SMPCompletionBlock)completion;

/**
 * @brief Activates the local Offline session.
 *
 * This method enables Offline transaction processing. Once the session is active, the SDK will
 * only allow Offline transactions.
 *
 * While an Offline session is active, transactions are authorized or declined based on local
 * logic that may differ from the real-time authorization logic typically used by the SumUp
 * backend.
 *
 * The Offline session state persists even if the SDK is terminated or the device is disconnected
 * from the network. To exit this state and resume standard online operations, you must use
 * either `endOfflineSessionWithCompletion:` or `uploadOfflineSessionWithCompletion:`.
 *
 * Note that these deactivation methods may require an active internet connection, especially if
 * Offline transactions were processed while the session was active.
 *
 * @warning Once activated, an Offline session has a finite duration. Use
 * `getOfflineSessionRemainingTime` to monitor its validity.
 *
 * @param completion Block invoked upon completion. The result of the operation is provided
 * through the block parameters: 'success' indicates whether the Offline session was started
 * successfully, while 'error' provides details if the operation failed.
 */
+ (void)startOfflineSessionWithCompletion:(nullable SMPCompletionBlock)completion;

/**
 * @brief Deactivates the local Offline session.
 *
 * This method prevents the SDK from accepting further Offline transactions and restores
 * standard online operations.
 *
 * Transitioning from an active to a deactivated Offline session is always permitted. However, the
 * reverse (re-activating a session) is not always guaranteed, as it depends on the validity of the
 * local security definitions. Therefore, this method should be used only when the merchant is
 * certain they no longer require Offline capabilities for the foreseeable future.
 *
 * This method will also attempt to upload any stored Offline transactions and update the local
 * security definitions, similar to `uploadOfflineSessionWithCompletion:`. However, if
 * an error occurs during either the upload or the update process, it will not be reported; the
 * priority is finalizing the session state. Stored transactions will not be deleted unless they have
 * been successfully uploaded.
 *
 * @note This method may require an active internet connection to synchronize the final session
 * state with the SumUp backend.
 *
 * @param completion Block invoked upon completion. The result of the operation is provided
 * through the block parameters: 'success' indicates whether the Offline session was ended
 * successfully, while 'error' provides details if the operation failed.
 */
+ (void)endOfflineSessionWithCompletion:(nullable SMPCompletionBlock)completion;

/**
 * @brief Queries the remaining time-to-live (TTL) of the current Offline session.
 *
 * For security and compliance reasons, the Offline session has a limited validity period.
 * This method retrieves the remaining time, in seconds, before the local session expires and
 * requires a new online synchronization.
 *
 * When this value reaches zero, the SDK will block any further Offline checkouts.
 * Depending on the previous state and the presence of stored transactions, the session
 * can be restarted by first finalizing the current state (via
 * `endOfflineSessionWithCompletion:` or
 * `uploadOfflineSessionWithCompletion:`) and then calling
 * `startOfflineSessionWithCompletion:`.
 *
 * @param completion Block invoked upon completion. The result of the operation is provided
 * through the block parameters: 'remainingTime' indicates the validity in seconds
 * (NSTimeInterval), while 'error' provides details if no session is active or the data is
 * inaccessible.
 */
+ (void)getOfflineSessionRemainingTimeWithCompletion:(nonnull SMPOfflineRemainingTimeCompletionBlock)completion;

/**
 * @brief Retrieves the details of the current Offline session.
 *
 * This method returns an `SMPOfflineSessionDetails` object reflecting the current state of
 * the Offline session. It provides granular data including the number of approved and
 * failed transactions, the total accumulated amount, and the remaining session time.
 *
 * This information is essential for merchant-facing dashboards to track "Pending Sync" totals
 * and to monitor the consumption of local limits before an upload to the backend is required.
 *
 * @param completion Block invoked upon completion. The result of the operation is provided
 * through the block parameters: 'sessionDetails' contains the `SMPOfflineSessionDetails` object,
 * while 'error' provides details if no Offline session is currently active.
 */
+ (void)getOfflineSessionDetailsWithCompletion:(nonnull SMPOfflineSessionDetailsCompletionBlock)completion;

/**
 * @brief Synchronizes stored Offline transactions for settlement.
 *
 * This method is responsible for uploading all Offline transactions stored on the device to the
 * backend. Offline transactions are not finalized, and funds are not settled, until they are
 * successfully uploaded.
 *
 * Once the upload completes successfully, the local Offline session is deactivated, restoring
 * standard online operations. Stored transactions will not be deleted unless they have been
 * successfully uploaded.
 *
 * During this process, the SDK will also attempt to update the local security definitions.
 * However, if this update fails, the error will not be reported to prioritize the upload success.
 *
 * @note This method requires an active internet connection. It should be called as soon as the
 * app detects network availability to ensure timely settlement of Offline transactions.
 *
 * @param completion Block invoked upon completion. The result of the operation is provided
 * through the block parameters: 'success' indicates whether the transactions were uploaded
 * and the session was ended successfully, while 'error' provides details if the operation failed.
 */
+ (void)uploadOfflineSessionWithCompletion:(nullable SMPCompletionBlock)completion;

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
    SMPSumUpSDKErrorCheckoutCurrencyCodeMismatch   = 52,
    /// The foreign transaction ID specified in the checkout request has already been used.
    SMPSumUpSDKErrorDuplicateForeignID             = 53,
    /// The access token is invalid. Login to get a valid access token.
    SMPSumUpSDKErrorInvalidAccessToken             = 54,
    /// The amount entered contains invalid number of decimals.
    SMPSumUpSDKErrorInvalidAmountDecimals          = 55,
    /// The processAs property of CheckoutRequest is not valid
    SMPSumUpSDKErrorInvalidProcessAs               = 56,
    /// The numberOfInstallments property of CheckoutRequest is not valid
    SMPSumUpSDKErrorInvalidNumberOfInstallments    = 57,
    /// Reader wake error during Prepare for Checkout process.
    /// Includes when a reader has never been paired.
    SMPSumUpSDKErrorPrepareCheckoutReaderWakeFailed = 60,
    /// Tap to Pay on iPhone payment method is not available for the current merchant. This may be
    /// because the payment method is not available in their country.
    SMPSumUpSDKErrorTapToPayNotAvailable           = 100,
    /// Tap to Pay on iPhone: activation is required. Call `presentTapToPayActivationFromViewController:animated:completionBlock:`.
    SMPSumUpSDKErrorTapToPayActivationNeeded       = 101,
    /// Tap to Pay on iPhone: an unspecified error occurred
    SMPSumUpSDKErrorTapToPayInternalError          = 102,
    /// Tap to Pay on iPhone requires an iPhone XS or later and does not work on iPads.
    SMPSumUpSDKErrorTapToPayMinHardwareNotMet      = 103,
    /// Tap to Pay on iPhone requires a newer version of iOS; please check the documentation for the
    /// minimum supported version.
    SMPSumUpSDKErrorTapToPayiOSVersionTooOld       = 104,
    /// Tap to Pay on iPhone has some other (unspecified) requirement(s) that are not met.
    SMPSumUpSDKErrorTapToPayRequirementsNotMet     = 105,
} NS_SWIFT_NAME(SumUpSDKError);

#pragma mark - Features

/**
 *  Returns YES if the last-used card reader, if any, supports the Tip on Card Reader feature (TCR).
 *  TCR prompts the customer directly on the card reader's display for a tip amount, rather than
 *  prompting for a tip amount on the iPhone or iPad display.
 *  This property will equal NO if no card reader has been used before. You can optionally present
 *  the Checkout Preferences screen to configure a card reader before the first transaction occurs
 *  to avoid this.
 */
@property (class, readonly) BOOL isTipOnCardReaderAvailable;

/**
 *  `YES` if the merchant's country requires the `processAs` property to be set for each transaction.
 *
 *  Warning: The transaction will fail if `isProcessAsRequired` is `YES` but `processAs`on
 *  `SMPCheckoutRequest` is `SMPProcessAsNotSet`.
 *
 *  When the payment method is card reader and `processAs` is `SMPProcessAsNotSet`,
 *  for backwards-compatibility it will be automatically set to `SMPProcessAsPromptUser`.
 *  However, `SMPProcessAsPromptUser` will be completely removed in a future version of
 *  the SDK and transactions may start failing because `processAs` was not set.
 *
 *  Please migrate your code to always set `processAs` if `isProcessAsRequired` is YES.
 */
@property (class, readonly) BOOL isProcessAsRequired;

#pragma mark - Reader Status

/**
 *  The most recently reported information about a saved or connected reader.
 *
 *  See @c SMPReaderStatus for more information.
 *
 *  @returns An `SMPReaderStatus`; or `nil` if not logged in, or no reader has yet been connected and saved.
 */
@property (class, readonly, copy, nullable) SMPReaderStatus *lastReaderStatus;

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
