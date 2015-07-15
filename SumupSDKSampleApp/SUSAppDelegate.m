//
//  SUSAppDelegate.m
//  SumupSDKSampleAPP
//
//  Created by Felix Lamouroux on 29.01.14.
//  Copyright (c) 2014 SumUp Payments Limited. All rights reserved.
//

#import "SUSAppDelegate.h"
#import <SumupSDK/SumupSDK.h>

@implementation SUSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*
     *   This will setup the SumUpSDK
     *   You might consider moving this to a later point in your application's lifecycle,
     *   as this will start updating for locations.
     *   Also remember to provide the NSLocationUsageDescription key in your info.plist
     *   and to properly localize it.
     */
    
    [SumupSDK setupWithAPIKey:@"c5e0068f-b776-4fa3-9051-f6f448e1a66d"];
    return YES;
}


@end
