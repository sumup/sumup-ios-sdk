//
//  Dummy.m
//  SumupSDK
//

#import <Foundation/Foundation.h>
#import <SumUpSDK/SumUpSDK.h>

@interface SumUpDummy : NSObject
@end

@implementation SumUpDummy
/// This dummy method is never called, but tells us if the embedded framework is properly linked.
-(void)test {
  [SMPSumUpSDK testSDKIntegration];
}
@end
