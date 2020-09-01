//
//  SMPSkipScreenOptions.h
//  SumUpSDK
//
//  Created by Lukas Mollidor on 08.06.17.
//  Copyright (c) 2017 SumUp Payments Limited. All rights reserved.
//

#ifndef SMPSkipScreenOptions_h
#define SMPSkipScreenOptions_h

/**
 *  SMPSkipScreenOptions allow for skipping the confirmation screen.
 */
typedef NS_OPTIONS(NSUInteger, SMPSkipScreenOptions) {
    /**
     *  Never skip confirmation screen.
     */
    SMPSkipScreenOptionNone = 0,
    /**
     *  Skip confirmation screen (i.e. screen that would ask for a receipt) for successful transactions.
     */
    SMPSkipScreenOptionSuccess = 1 << 0,
} NS_SWIFT_NAME(SkipScreenOptions);

#endif
