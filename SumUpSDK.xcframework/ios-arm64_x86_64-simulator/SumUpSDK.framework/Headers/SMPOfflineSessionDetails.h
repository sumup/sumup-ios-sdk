//
//  SMPOfflineSessionDetails.h
//  SumUpSDK
//
//  Created by Giulio Lombardo on 20/03/2026.
//  Copyright © 2026 SumUp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMPOfflineSessionDetails : NSObject

@property (nonatomic, readonly) NSTimeInterval remainingTime;
@property (nonatomic, readonly) NSInteger approvedTransactionsCount;
@property (nonatomic, readonly) NSInteger failedTransactionsCount;
@property (nonatomic, readonly) NSDecimal totalApprovedAmount;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
