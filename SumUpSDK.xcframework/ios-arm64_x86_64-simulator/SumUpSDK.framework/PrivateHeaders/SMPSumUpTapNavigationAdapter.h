//
//  SMPSumUpTapNavigationAdapter.h
//  SumUpCardReaderInternational
//
//  Created by Jade Burton on 22.12.22.
//  Copyright © 2022 SumUp. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import SumUpTap;

NS_ASSUME_NONNULL_BEGIN

@class SMPJSSignupScreen;
@class SMPCheckoutPageWrapperVC;

/// Notification name constant, published when a tap transaction  succedes
extern NSString *const SMPSumUpTapTransactionSuccessScreenNotification;
/// Notification name constant, published when a tap transaction  fails
extern NSString *const SMPSumUpTapTransactionFailedScreenNotification;

@protocol SMPNextScreenPresenter
- (void)presentNextScreens:(NSArray<SMPJSSignupScreen *> *)screens;
@end

// To work around an issue where the NavCon is not yet available at the time of initialization, we use a block and get it later.
typedef UINavigationController<SMPNextScreenPresenter> *_Nullable(^DeferredNavigationControllerGetter)(void);

// Enables the SumUpTap framework to manipulate SMPPaymentNavigationController, navigating and controlling the checkout flow.
@interface SMPSumUpTapNavigationAdapter : NSObject<SumUpTapNavigation>

// Using id due to circular reference with bridging
- (instancetype)initWithPaymentNavigationController:(DeferredNavigationControllerGetter)paymentNavigationControllerGetter
                          transactionStatusProvider:(id)transactionStatusProvider
                            checkoutRequestProvider:(id)checkoutRequestProvider
                                 notificationCenter:(NSNotificationCenter *)notificationCenter
                                              isSDK:(BOOL)isSDK;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)wrapAndPushViewController:(UIViewController *)viewController;
- (void)navigateToTransactionFailedScreenButUnknownResult;

+ (SMPCheckoutPageWrapperVC *)wrapViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
