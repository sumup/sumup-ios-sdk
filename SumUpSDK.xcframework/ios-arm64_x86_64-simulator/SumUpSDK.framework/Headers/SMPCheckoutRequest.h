//
//  SMPCheckoutRequest.h
//  SumUpSDK
//
//  Created by Lukas Mollidor on 23.01.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMPSkipScreenOptions.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS (NSUInteger, SMPPaymentOptions) {
    SMPPaymentOptionAny = 0,
    SMPPaymentOptionCardReader = 1 << 0,
    SMPPaymentOptionMobilePayment = 1 << 1,
} NS_SWIFT_NAME(PaymentOptions);

/// Encapsulates all information that is necessary during a checkout with the SumUp SDK.
NS_SWIFT_NAME(CheckoutRequest)
@interface SMPCheckoutRequest : NSObject

/**
 *  Creates a new checkout request.
 *
 *  Be careful when creating the NSDecimalNumber to not
 *  falsely use the NSNumber class creator methods.
 *  Use SMPPaymentOptionAny to not put restrictions on the desired payment types.
 *
 *  @param totalAmount The total amount to be charged to a customer. Cannot be nil.
 *  @param title An optional title to be displayed in the merchant's history and on customer receipts.
 *  @param currencyCode Currency Code in which the total should be charged (ISO 4217 code, see SMPCurrencyCode). Cannot be nil, has to match the currency of the merchant logged in. Use [[[SMPSumUpSDK currentMerchant] currencyCode] and ensure its length is not 0.
 *  @param paymentOptions Payment options to choose a payment type(card reader, mobile payment...)
 *
 *  @return A new request object or nil if totalAmount or currencyCode are nil.
 */
+ (SMPCheckoutRequest *)requestWithTotal:(NSDecimalNumber *)totalAmount
                                   title:(nullable NSString *)title
                            currencyCode:(NSString *)currencyCode
                          paymentOptions:(SMPPaymentOptions)paymentOptions __deprecated_msg("Payment options will be ignored and default to .any. Options presented will be governed by merchant settings. Please use requestWithTotal:title:currencyCode: instead.");

/**
 *  Creates a new checkout request.
 *
 *  Be careful when creating the NSDecimalNumber to not
 *  falsely use the NSNumber class creator methods.
 *
 *  @param totalAmount The total amount to be charged to a customer. Cannot be nil.
 *  @param title An optional title to be displayed in the merchant's history and on customer receipts.
 *  @param currencyCode Currency Code in which the total should be charged (ISO 4217 code, see SMPCurrencyCode). Cannot be nil, has to match the currency of the merchant logged in. Use [[[SMPSumUpSDK currentMerchant] currencyCode] and ensure its length is not 0.
 *
 *  @return A new request object or nil if totalAmount or currencyCode are nil.
 */
+ (SMPCheckoutRequest *)requestWithTotal:(NSDecimalNumber *)totalAmount
                                   title:(nullable NSString *)title
                            currencyCode:(NSString *)currencyCode;

/**
 *  The total amount to be charged to a customer.
 *
 *  @note Will not be nil if the instance was created using either
 *  requestWithTotal:title:currencyCode:paymentOptions: or
 *  requestWithTotal:title:currencyCode:
 */
@property (nonatomic, readonly, nullable) NSDecimalNumber *totalAmount;

/// A title to be displayed in the merchant's history and on customer receipts.
@property (nonatomic, readonly, nullable) NSString *title;

/**
 *  Currency code in which the total should be charged (ISO 4217 code, see SMPCurrencyCode).
 *
 *  @note Will not be nil if the instance was created using either
 *  requestWithTotal:title:currencyCode:paymentOptions: or
 *  requestWithTotal:title:currencyCode:
 */
@property (nonatomic, readonly, nullable) NSString *currencyCode;

/// Payment options to choose a payment type
@property (nonatomic, readonly) SMPPaymentOptions paymentOptions __deprecated_msg("Payment options will be ignored and default to .any");

/**
 *  An (optional) ID to be associated with this transaction.
 *  See https://docs.sumup.com/rest-api/#tag/Transactions
 *  on how to retrieve a transaction using this ID.
 *  This ID has to be unique in the scope of a SumUp merchant account and its sub-accounts.
 *  It must not be longer than 128 characters and can only contain printable ASCII characters.
 */
@property (nonatomic, copy, nullable) NSString *foreignTransactionID;

/**
 *  An optional additional tip amount to be charged to a customer.
 *
 *  @note This property will be ignored if the connected card reader supports the
 *  Tip on Card Reader (TCR) feature and if it is enabled by setting
 *  tipOnCardReaderIfAvailable to YES.
 *
 *  Important: the customer may use a reader that does not support TCR.
 *  You must handle this case yourself in order to avoid no tip from being prompted.
 *
 *  To do this:
 *
 *  Before calling SMPSumUpSDK checkoutWithRequest:fromViewController:completion:,
 *  check SMPSumUpSDK.isTipOnCardReaderAvailable:
 *
 *    - If NO, you should prompt the user for a tip amount yourself and set tipAmount
 *
 *    - If YES, you may set tipOnCardReaderIfAvailable to YES.
 *      Do not prompt the user for a tip amount or set tipAmount if you do this.
 *
 *  Will be added to the totalAmount. Must be greater than zero if set.
 */
@property (nonatomic, copy, nullable) NSDecimalNumber *tipAmount;

/**
 *  Enables Tip on Card Reader (TCR), if the feature is available.
 *
 *  @note TCR prompts the customer directly on the card reader's display for a tip amount,
 *  rather than prompting for a tip amount on the iPhone or iPad display.
 *
 *  Not all card readers support this feature. To find out if the feature is supported for the
 *  last-used card reader, check SMPSumUpSDK.isTipOnCardReaderAvailable.
 *
 *  Setting this property to YES when the feature is not available will do nothing.
 */
@property (nonatomic) BOOL tipOnCardReaderIfAvailable;

/**
 *  An optional count for the display of the number of sale items throughout the checkout process.
 *  Default is zero which will hide the display of the item count.
 *  This value is currently not reflected in the merchant's history
 *  or the customer receipts.
 */
@property (nonatomic) NSUInteger saleItemsCount;


/**
 *  An optional flag to skip the confirmation screen in checkout.
 *  If set, the checkout will be dismissed w/o user interaction.
 *  Default is SMPSkipScreenOptionNone.
 */
@property (nonatomic) SMPSkipScreenOptions skipScreenOptions;

@end

NS_ASSUME_NONNULL_END
