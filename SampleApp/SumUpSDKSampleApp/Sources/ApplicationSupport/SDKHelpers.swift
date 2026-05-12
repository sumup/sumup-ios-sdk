import SumUpSDK

/// Adds user-readable values to the SumUp SDK ``ReaderType``.
extension ReaderType {
    var displayName: String {
        switch self {
        case .air:
            "Air"
        case .pinPlus:
            "Pin+"
        case .solo:
            "Solo"
        case .soloLite:
            "Solo Lite"
        case .threeG:
            "3G"
        case .unknown:
            fallthrough
        @unknown default:
            "Unknown"
        }
    }
}

/// Helps provide a meaningful value to ``TopBarView`` for ``TopBarView/readerStatusDisplay``.
extension ReaderStatus {
    var topBarReaderStatus: TopBarView.ReaderStatusDisplay {
        isActive ? .connected : .disconnected
    }
}
