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

/*
 *  Currency codes to be used in checkout (ISO 4217 code).
 *  Other currency codes are permissible in the request object,
 *  but are likely not to be accepted during the checkout.
 */

NS_SWIFT_NAME(CurrencyCodeBGN)
extern NSString * const SMPCurrencyCodeBGN;
NS_SWIFT_NAME(CurrencyCodeBRL)
extern NSString * const SMPCurrencyCodeBRL;
NS_SWIFT_NAME(CurrencyCodeCHF)
extern NSString * const SMPCurrencyCodeCHF;
NS_SWIFT_NAME(CurrencyCodeCLP)
extern NSString * const SMPCurrencyCodeCLP;
NS_SWIFT_NAME(CurrencyCodeCZK)
extern NSString * const SMPCurrencyCodeCZK;
NS_SWIFT_NAME(CurrencyCodeDKK)
extern NSString * const SMPCurrencyCodeDKK;
NS_SWIFT_NAME(CurrencyCodeEUR)
extern NSString * const SMPCurrencyCodeEUR;
NS_SWIFT_NAME(CurrencyCodeGBP)
extern NSString * const SMPCurrencyCodeGBP;
NS_SWIFT_NAME(CurrencyCodeHUF)
extern NSString * const SMPCurrencyCodeHUF;
NS_SWIFT_NAME(CurrencyCodeNOK)
extern NSString * const SMPCurrencyCodeNOK;
NS_SWIFT_NAME(CurrencyCodePLN)
extern NSString * const SMPCurrencyCodePLN;
NS_SWIFT_NAME(CurrencyCodeRON)
extern NSString * const SMPCurrencyCodeRON;
NS_SWIFT_NAME(CurrencyCodeSEK)
extern NSString * const SMPCurrencyCodeSEK;
NS_SWIFT_NAME(CurrencyCodeUSD)
extern NSString * const SMPCurrencyCodeUSD;

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
                          paymentOptions:(SMPPaymentOptions)paymentOptions;

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
@property (nonatomic, readonly) SMPPaymentOptions paymentOptions;

/**
 *  An (optional) ID to be associated with this transaction.
 *  See http://docs.sumup.com/rest-api/transactions-api/#merchant-transactions
 *  on how to retrieve a transaction using this ID.
 *  This ID has to be unique in the scope of a SumUp merchant account and its sub-accounts.
 *  It must not be longer than 128 characters and can only contain printable ASCII characters.
 */
@property (nonatomic, copy, nullable) NSString *foreignTransactionID;


/**
 *  An optional additional tip amount to be charged to a customer.
 *
 *  @note Will be added to the totalAmount. Must be greater zero if passed.
 */
@property (nonatomic, copy, nullable) NSDecimalNumber *tipAmount;

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
