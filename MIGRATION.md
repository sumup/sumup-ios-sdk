# SumUp mPOS SDK Migration Guides

These guides below are provided to ease the transition of existing applications using the SumUp mPOS SDK from one version to another that introduces breaking API changes.

## SumUp mPOS SDK 4.0.0 Migration Guide

Please follow the steps in the 4.0.0-beta.1 Migration Guide](#sumup-mpos-SDK-400-beta1-migration-guide).
In addition payment options provided when creating a checkout request will be ignored and default to `.any`.
Options presented will be governed by merchant settings.
Please use `-[SMPCheckoutRequest requestWithTotal:title:currencyCode:]` to create a checkout request.

* [SumUp mPOS SDK 4.0.0-beta.1 Migration Guide](#sumup-mpos-SDK-400-beta1-migration-guide)

## SumUp mPOS SDK 4.0.0-beta.1 Migration Guide

With the transition to dynamic frameworks and XCFrameworks, the integration became easier and some previously required steps should be reverted.

### Manual Integration Migration

1. Remove `SumUpSDK.embeddedframework` from the `Link Binary With Libraries` build step.
2. Remove the `SMPSharedResources.bundle` from the `Copy Bundle Resources` build step.
3. Continue with the [installation](README.md#manual-integration).

### Integration via CocoaPods Migration

Update the pod version in the Podfile (`pod 'SumUpSDK', '~> 4.0.0-beta.1'`) and run `pod install`.
We have made no changes to requried permissions from v3.5. You might still want to double check your [required Info.plist keys](README.md#privacy-info-plist-keys).

### Integration via Carthage Migration

1. Update the SDK via Carthage
2. Remove `SumUpSDK.embeddedframework` from the `Link Binary With Libraries` build step.
3. Remove the `SMPSharedResources.bundle` from the `Copy Bundle Resources` build step.
4. Continue with the [installation](README.md#integration-via-carthage).
