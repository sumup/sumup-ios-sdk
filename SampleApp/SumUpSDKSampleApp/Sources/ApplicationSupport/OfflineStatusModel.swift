import Foundation

/// A local representation of ``SumUpSDKServiceOfflineSessionDetails``, capturing offline session state for use in the app layer.
struct OfflineStatusModel: Equatable {
    /// Maps to ``SumUpSDKServiceOfflineSessionDetails/remainingTime``.
    var remainingTime: TimeInterval
    /// Derived from ``OfflineStatusModel/remainingTime``; the projected end date of the offline session.
    var endDate: Date
    /// Maps to ``SumUpSDKServiceOfflineSessionDetails/approvedTransactionsCount``.
    var approvedTransactionsCount: Int
    /// Maps to ``SumUpSDKServiceOfflineSessionDetails/failedTransactionsCount``.
    var failedTransactionsCount: Int
    /// Maps to ``SumUpSDKServiceOfflineSessionDetails/totalApprovedAmount``.
    var totalApprovedAmount: Decimal

    /// Whether the offline session is still active (i.e. time remains).
    var isSessionActive: Bool {
        remainingTime > 0
    }
}

extension OfflineStatusModel {
    /// Creates an ``OfflineStatusModel`` from SDK session details.
    /// - Parameter details: The offline session details provided by the SumUp SDK via ``SumUpSDKServiceOfflineSessionDetails``.
    init(_ details: SumUpSDKServiceOfflineSessionDetails) {
        remainingTime = details.remainingTime
        endDate = Date(timeIntervalSinceNow: details.remainingTime)
        approvedTransactionsCount = details.approvedTransactionsCount
        failedTransactionsCount = details.failedTransactionsCount
        totalApprovedAmount = details.totalApprovedAmount
    }
}
