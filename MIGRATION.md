# SumUp mPOS SDK Migration Guides

These guides below are provided to ease the transition of existing applications using the SumUp mPOS SDK from one version to another that introduces breaking API changes.

## SumUp mPOS SDK 4.0.0 Migration Guide

Please follow the steps in the [4.0.0-beta.1 Migration Guide](#sumup-mpos-sdk-400-beta1-migration-guide).
In addition payment options provided when creating a checkout request will be ignored and default to `.any`.
Options presented will be governed by merchant settings.
Please use `-[SMPCheckoutRequest requestWithTotal:title:currencyCode:]` to create a checkout request.

* [SumUp mPOS SDK 4.0.0-beta.1 Migration Guide](#sumup-mpos-sdk-400-beta1-migration-guide)

## SumUp mPOS SDK 4.0.0-beta.1 Migration Guide

With the transition to dynamic frameworks and XCFrameworks, the integration became easier and some previously required steps should be reverted.

### Manual Integration Migration

1. Remove `SumUpSDK.embeddedframework` from the `Link Binary With Libraries` build step.
2. Remove the `SMPSharedResources.bundle` from the `Copy Bundle Resources` build step.
3. Continue with the [installation](README.md).

### Integration via Swift Package Manager

Swift Package Manager is the supported integration path. Add the SumUp SDK package to your project and continue with the [installation](README.md).
