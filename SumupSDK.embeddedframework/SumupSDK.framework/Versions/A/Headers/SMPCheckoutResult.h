//
//  SMPCheckoutResult.h
//  Cashier
//
//  Created by Lukas Mollidor on 10/06/15.
//  Copyright (c) 2015 iosphere GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMPCheckoutResult : NSObject

@property (readonly) BOOL success;
@property (strong, readonly) NSString *transactionCode;

@end
