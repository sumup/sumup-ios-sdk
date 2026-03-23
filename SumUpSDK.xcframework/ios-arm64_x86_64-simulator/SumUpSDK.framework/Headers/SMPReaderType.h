/**
 *  An enumeration of the types of readers the SDK can connect to.
 *
 *  Reader model names are indicated on the backs of the physical readers.
 */
typedef NS_ENUM(NSUInteger, SMPReaderType) {
    /// The reader type is unknown, or if none has ever been connected.
    SMPReaderTypeUnknown NS_SWIFT_NAME(unknown)     = 0,
    /// Pin Plus, Pin Plus Contactless
    SMPReaderTypePinPlus NS_SWIFT_NAME(pinPlus)     = 1,
    /// 3G
    SMPReaderTypeThreeG NS_SWIFT_NAME(threeG)       = 2,
    /// Air, Air Lite
    SMPReaderTypeAir NS_SWIFT_NAME(air)             = 3,
    /// Solo
    SMPReaderTypeSolo NS_SWIFT_NAME(solo)           = 4,
    /// Solo Lite
    SMPReaderTypeSoloLite NS_SWIFT_NAME(soloLite)   = 5,
} NS_SWIFT_NAME(ReaderType);
