//
//  SMPAccessTokenProvider.h
//  SumUpSDK
//
//  Created by Giulio Lombardo on 18/09/2026.
//  Copyright © 2026 SumUp. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The completion handler passed to an access token provider.
 *
 *  @param accessToken A non-empty, currently valid merchant access token.
 *  @param error       The reason why no token could be provided.
 */
typedef void (^SMPAccessTokenCompletionHandler)(NSString * _Nullable accessToken, NSError * _Nullable error) NS_SWIFT_NAME(AccessTokenCompletionHandler);

/**
 *  Supplies merchant access tokens to the SumUp SDK.
 *
 *  Implement this protocol to keep the SDK authenticated for the whole lifetime of a session,
 *  instead of logging out and logging in again every time a token expires.
 *
 *  Install your implementation and log in in a single step with
 *  @c +[SMPSumUpSDK loginWithTokenProvider:completion:] .
 *
 *  ## Contract
 *
 *  - The SDK can ask for a token at any time and from any thread, not only while logging in.
 *  - The completion handler can be called on any thread, and has to be called exactly once,
 *    within 30 seconds. Later calls are ignored, and a missing call fails the operation that is
 *    waiting for the token.
 *  - Every token has to belong to the same merchant for the whole session.
 *  - An empty token is treated as an error.
 */
NS_SWIFT_NAME(AccessTokenProvider)
@protocol SMPAccessTokenProvider <NSObject>

/**
 *  Asks for an access token.
 *
 *  @param completionHandler Called with either a non-empty token or an error.
 */
- (void)getAccessTokenWithCompletionHandler:(SMPAccessTokenCompletionHandler _Nonnull)completionHandler
NS_SWIFT_NAME(accessToken(completionHandler:))
NS_SWIFT_ASYNC_NAME(accessToken());

@end
