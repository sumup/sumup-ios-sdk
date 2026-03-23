#import "SMPReaderType.h"

/**
 *  Provides access to information about the reader.
 *
 *  This object is returned by @c SMPSumUpSDK to provide you with information about the current reader. You
 *  do not create it yourself.
 */
@interface SMPReaderStatus : NSObject

/**
 *  The last reported battery level of the reader.
 *
 *  This value is only updated during pairing or transaction processing. Relying on it
 *  closely is not recommended as its freshness can vary on your reader's usage.
 */
@property (nonatomic, assign) NSUInteger batteryLevel;

/// The serial number of the reader. Visible on the back of the physical device.
@property (nonatomic, copy) NSString *serialNumber;

/// The model of the reader. See @c SMPReaderType for more information.
@property (nonatomic, assign) SMPReaderType readerType;

/**
 *  Use to get information about the reader status. When the reader is active or becoming active
 *  (such as after calling `prepareForCheckout:`), this property will be `YES`.
 *  If a reader has never been connected, this will return `NO`.
 *
 *  For readers that have been previously paired but are currently disconnected, this property will also return `NO`.
 *
 *  You can check this property after calling `prepareForCheckout:` including within its completion block.
 *
 *  @return YES if a card reader is currently active (including waking to become active).
 */
@property (nonatomic, assign) BOOL isActive;

/// Object is created and returned by the SDK only.
- (instancetype)init NS_UNAVAILABLE;

@end
