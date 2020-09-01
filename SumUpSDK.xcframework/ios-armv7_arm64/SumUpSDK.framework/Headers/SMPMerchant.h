//
//  SMPMerchant.h
//  SumUpSDK
//
//  Created by Felix Lamouroux on 04.03.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Describes a SumUp merchant.
NS_SWIFT_NAME(Merchant)
@interface SMPMerchant : NSObject

/// The currency code used by the merchant for all payments.
@property (readonly, copy, nullable) NSString *currencyCode;

/// The merchant's identifier within the SumUp system.
@property (readonly, copy, nullable) NSString *merchantCode;

@end
