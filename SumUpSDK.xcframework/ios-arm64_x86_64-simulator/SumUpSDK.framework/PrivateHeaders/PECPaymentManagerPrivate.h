//
//  PECPaymentManagerPrivate.h
//  SumUpCardReaderInternational
//
//  Created by Jade Burton on 12.04.24.
//  Copyright © 2024 SumUp. All rights reserved.
//

@import Foundation;

// Used by SumUpTapCheckoutStarter to access PECPaymentManager without having to import many/large headers.
// Needed for ObjC-Swift briding in the SDK.
@interface PECPaymentManagerPrivate : NSObject
+ (id _Nonnull)sharedInstance;
@end

