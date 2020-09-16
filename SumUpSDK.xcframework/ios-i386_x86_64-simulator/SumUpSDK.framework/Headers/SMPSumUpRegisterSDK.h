//
//  SMPSumUpRegisterSDK.h
//  SumUpSDK
//
//  Created by Felix Schneider on 22.03.2017.
//  Copyright (c) 2017 SumUp Payments Limited. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 *   IMPORTANT NOTE:
 *
 *   Using API declared in this header to support the SumUp Air Register
 *   requires additional setup steps and MFi approval.
 *
 *   Further reading: https://github.com/sumup/sumup-ios-sdk/tree/master/AirRegister
 */

NS_ASSUME_NONNULL_BEGIN

/// A common completion block used within the SumUpRegisterSDK that is called with a success value and an error object.
typedef void (^SMPRegisterCompletionBlock)(BOOL success, NSError * _Nullable error);

/// The SMPRegisterSDKStatus class wraps the device status of your register
NS_SWIFT_NAME(RegisterStatus)
@interface SMPRegisterSDKStatus : NSObject

/// YES if iPad is connected to the SumUp Air Register's card reader.
@property (readonly) BOOL isReaderConnected;
/// YES if the Register is connected to external power
@property (readonly) BOOL isCharging;
/// 0-100% Battery Level of the internal battery of the Register
@property (readonly) NSUInteger batteryLevel;
/// YES if the device should be connected to external power soon
@property (readonly) BOOL isBatteryLow;

/// SumUp Air Register serial number, should only be needed for support purposes
@property (nullable, readonly) NSString *serialNumber;
/// SumUp Air Register Software Version, should only be needed for support purposes
@property (nullable, readonly) NSString *firmwareVersion;

@end

/// Wraps the status of the registers integrated printer
NS_SWIFT_NAME(RegisterPrinterStatus)
@interface SMPRegisterSDKPrinterStatus : NSObject

/// YES if printer is ready to print
@property (readonly) BOOL isPrinterReady;
/// YES if paper is empty or cover is opened
@property (readonly) BOOL isPaperEmpty;
/// YES if a generic error occured
@property (readonly) BOOL genericErrorDidOccur;

@end

/// This delegate is used to notify you of all changes of the SumUp Air Register
NS_SWIFT_NAME(RegisterSDKDelegate)
@protocol SMPSumUpRegisterSDKDelegate <NSObject>

/// Called whenever a register device is detected. This is also called when a register is already present during App launch.
- (void)registerDidConnect:(SMPRegisterSDKStatus *)deviceStatus;
/// Called on any disconection event (e.g removal of iPad, empty battery).
- (void)registerDidDisconnect;

/// Called on all status changes around power events, including disconnects. Status is nil after disconnect.
- (void)registerStatusDidChange:(nullable SMPRegisterSDKStatus *)deviceStatus;

/// Called whenever an attached drawer was opened
- (void)drawerDidOpen;

/// Called whenever an attached drawer was closed
- (void)drawerDidClose;

/// Called on all status changes around printer events, including disconnects. Status is nil after disconnect.
- (void)printerStatusDidChange:(nullable SMPRegisterSDKPrinterStatus *)status;

@end

#pragma mark - Error Domain and Codes

NS_SWIFT_NAME(SumUpRegisterSDKErrorDomain)
extern NSString * const SMPSumUpRegisterSDKErrorDomain;

/**
 *  The error codes returned from the SDK
 */
typedef NS_ENUM(NSInteger, SMPSumUpRegisterSDKError) {
    /// General error
    SMPSumUpRegisterSDKErrorGeneral = 0,

    /// The register is not connected
    SMPSumUpRegisterSDKErrorNotConnected = 10,

    /// Firmware update is in progress
    SMPSumUpRegisterSDKErrorFirmwareUpdateInProgress = 20,

    /// General timeout that indicates the operation failed.
    SMPSumUpRegisterSDKErrorTimeout = 30,

    /// Timeout during firmware update. It is strongly recommended
    /// to reboot and reconnect the device after encountering this error.
    SMPSumUpRegisterSDKErrorTimeoutFirmwareUpdate = 31,
} NS_SWIFT_NAME(SumUpRegisterSDKError);

/// Main SumUp Air Register entry point, might be used without logging in to the main SumUp SDK.
NS_SWIFT_NAME(SumUpRegisterSDK)
@interface SMPSumUpRegisterSDK : NSObject

/// Register support requires additional setup, see AirRegister/README.md.
/// Do not use any register method or property (incl. 'sharedInstance')
/// unless this property returns 'YES'.
@property (class, readonly) BOOL registerIsSupported;

/// This class is a singleton, do not try to allocate instances of this class on your own.
/// Will be 'nil' if 'registerIsSupported' returns 'NO'.
@property (class, readonly, nullable) SMPSumUpRegisterSDK *sharedInstance NS_SWIFT_NAME(shared);

/// Set the delegate before calling `-startListeningForRegister`
@property (nullable, weak) id<SMPSumUpRegisterSDKDelegate> delegate;

/// Returns the current register device status. Is nil if the register is not connected.
@property (readonly, nullable) SMPRegisterSDKStatus *deviceStatus;

/// Returns the current printer status. Is nil if the entire register is not connected.
@property (readonly, nullable) SMPRegisterSDKPrinterStatus *printerStatus;

/// @return YES if an attached cash drawer is opened
@property (readonly) BOOL drawerIsOpen;

/// DO NOT USE, use `+sharedInstance` instead
+ (instancetype)new NS_UNAVAILABLE;
/// DO NOT USE, use `+sharedInstance` instead
- (instancetype)init NS_UNAVAILABLE;

/// Initialize the SumUp Register SDK. Please set the delegate before calling this.
- (void)startListeningForRegister;
/// Stops all activities of the SumUp Register SDK. You will not receive any callbacks after calling this.
- (void)stopListeningForRegister;

/// Prints ESCPOS data. Please contact us for a reference manual.
- (void)printEscPos:(NSString *)escposString;

/// Call this to open an attached cash drawer
- (void)openDrawer;

/// Starts updating the register firmware. Completion will always be called on the main queue.
- (void)startFirmwareUpdateWithCompletion:(SMPRegisterCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
