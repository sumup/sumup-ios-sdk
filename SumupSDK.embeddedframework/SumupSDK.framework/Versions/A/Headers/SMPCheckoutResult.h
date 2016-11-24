//
//  SMPCheckoutResult.h
//  SumupSDK
//
//  Created by Lukas Mollidor on 10/06/15.
//  Copyright (c) 2015 SumUp Payments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMPCheckoutResult : NSObject

/**
 *  A boolean indicating whether the checkout was sucessful.
 */
@property (readonly) BOOL success;

/**
 *  The transaction code to be used as a reference to this transaction.
 *  Can be nil if the checkout failed in an early stage and did not reach SumUp's backend.
 */
@property (strong, readonly, nullable) NSString *transactionCode;

/**
 *  Additional information on the transaction like card information.
 *  Can be nil if the checkout failed prior to payment type selection or card insertion.
 *  Please see https://sumup.com/integration#TransactionHistoryModel for details.
 */
@property (strong, readonly, nullable) NSDictionary *additionalInfo;

@end
