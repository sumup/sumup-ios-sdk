import Combine
import SumUpSDK
import SwiftUI

// MARK: - SumUpSDKService Protocol

/// Abstracts the SumUp SDK's static interface behind a protocol,
/// enabling dependency injection and mocking for previews and tests.
@MainActor
protocol SumUpSDKService: AnyObject {
    var isLoggedIn: Bool { get }
    var sessionEventPublisher: AnyPublisher<SumUpSDKServiceSessionEvent, Never> { get }
    var currentMerchantCurrencyCode: String? { get }
    var currentMerchantCode: String? { get }
    var lastReaderStatus: ReaderStatus? { get }
    var isTipOnCardReaderAvailable: Bool { get }
    var customTipRates: [Int]? { get set }
    var tippingEnabled: Bool { get set }
    var isProcessAsRequired: Bool { get }
    var skipScreenOptions: SumUpSDKCheckoutSkipScreenOptions { get set }

    func presentLogin() async throws
    func presentCardReaderSettings() async throws
    func checkout(with request: CheckoutRequest) async throws -> SumUpSDKServiceCheckoutResult
    func logout() async throws
    
    // Offline
    func setupOfflineSession() async throws -> Bool
    func startOfflineSession() async throws -> Bool
    func endOfflineSession() async throws -> Bool
    func offlineSessionRemainingTime() async throws -> TimeInterval
    func offlineSessionDetails() async throws -> SumUpSDKServiceOfflineSessionDetails
    func uploadOfflineSession() async throws -> Bool
}

// MARK: - SumUpSDKService Session Events

/// Events emitted by ``SumUpSDKService`` when session state changes.
enum SumUpSDKServiceSessionEvent {
    case loggedIn
    case loggedOut
}

// MARK: - SumUpSDKService Errors

/// Errors thrown by ``SumUpSDKService`` operations.
enum SumUpSDKServiceError: LocalizedError {
    /// The merchant's currency code is not available after login.
    case missingCurrencyCode
    /// Failed to present card reader settings.
    case failedToPresentCardReaderSettings(Error)
    /// Offline mode was not able to be started
    case failedToStartOfflineSession(Error)
    /// Offline mode could not be stopped (Most likely it was not started)
    case failedToEndOfflineSession(Error)
    /// If session details are unavailable (not started, invalid user session)
    case failedToFetchOfflineSessionDetails(Error)
    /// Generic error for unknown cases
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .missingCurrencyCode:
            return "Merchant currency code is missing"
        case .failedToPresentCardReaderSettings(let error):
            return "Failed to present card reader settings: \(error.localizedDescription)"
        case .failedToStartOfflineSession(let error):
            return "Unable to start an Offline Session: \(error.localizedDescription)"
        case .failedToEndOfflineSession(let error):
            return "Unable to end the Offline Session: \(error.localizedDescription)"
        case .failedToFetchOfflineSessionDetails(let error):
            return "Unable to retrieve Offline Session details: \(error.localizedDescription)"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - SumUpSDKService Checkout Errors

/// Errors originating from the SumUp SDK during a checkout operation.
/// Mapped from raw SDK `NSError`s by ``LiveSumUpSDKService``.
enum SumUpSDKServiceCheckoutError: LocalizedError {
    /// The SDK reported that no merchant account is logged in.
    case accountNotLoggedIn(Error?)
    /// Any other SDK error not specifically handled.
    case generalSdkError(Error?)

    var errorDescription: String? {
        switch self {
        case .accountNotLoggedIn(let error):
            "Account is not logged in: \(error?.localizedDescription ?? "Unknown underlying error")"
        case .generalSdkError(let error):
            "General SDK Error: \(error?.localizedDescription ?? "Unknown underlying error")"
        }
    }

    /// Maps a raw SDK error to a typed ``SumUpSDKServiceCheckoutError``.
    init(sdkError: Error) {
        let nsError = sdkError as NSError
        print("Error during checkout: \(nsError)")

        if nsError.domain == SumUpSDKErrorDomain,
           nsError.code == SumUpSDKError.accountNotLoggedIn.rawValue {
            self = .accountNotLoggedIn(nsError)
        } else {
            self = .generalSdkError(nsError)
        }
    }
}

// MARK: - Checkout Result Abstraction

/// Mirrors ``CheckoutResult``'s read-only interface so that test doubles
/// can be substituted without subclassing the SDK's ObjC class.
protocol CheckoutResultType {
    var success: Bool { get }
    var transactionCode: String? { get }
    var additionalInfo: [AnyHashable: Any]? { get }
}

extension CheckoutResult: CheckoutResultType {}

// MARK: - SumUpSDKService Checkout Result

/// Wraps a ``CheckoutResultType`` with decoded transaction information.
struct SumUpSDKServiceCheckoutResult {
    /// Whether the checkout was successful.
    let success: Bool
    /// The transaction code for reference.
    let transactionCode: String?
    /// Decoded transaction information from ``CheckoutResultType/additionalInfo``.
    let transactionInfo: TransactionInfo?
    
    init(_ checkoutResult: some CheckoutResultType) {
        self.success = checkoutResult.success
        self.transactionCode = checkoutResult.transactionCode
        self.transactionInfo = TransactionInfo(checkoutResult.additionalInfo)
    }
    
    /// Decoded transaction information from ``CheckoutResultType/additionalInfo``.
    struct TransactionInfo {
        let tipAmount: Double?
        let currencyCode: String?
        
        init?(_ dictionary: [AnyHashable: Any]?) {
            guard let dictionary else { return nil }
            self.tipAmount = dictionary["tip_amount"] as? Double
            self.currencyCode = dictionary["currency"] as? String
        }
    }
}

// MARK: SumUpSDKService Offline Session Details

/// Abstracts the offline session details provided by the SumUp SDK, allowing the app layer to
/// consume session state without depending directly on `SMPOfflineSessionDetails`.
protocol SumUpSDKServiceOfflineSessionDetails {
    /// Time remaining in the current offline session, in seconds.
    var remainingTime: TimeInterval { get }
    /// Number of transactions that were approved while offline.
    var approvedTransactionsCount: Int { get }
    /// Number of transactions that failed while offline.
    var failedTransactionsCount: Int { get }
    /// Cumulative monetary amount of all approved offline transactions.
    var totalApprovedAmount: Decimal { get }
}

extension SMPOfflineSessionDetails: SumUpSDKServiceOfflineSessionDetails {}

// MARK: Convenience Service Extensions

extension SumUpSDKService {
    func refreshTippingStatus() {
        tippingEnabled = tippingEnabled && isTipOnCardReaderAvailable
    }
}

// MARK: - Checkout Skip Screen Options

/// App-layer representation of the SDK's ``SkipScreenOptions`` bitmask,
/// decoupled from the SDK's `NS_OPTIONS` type.
struct SumUpSDKCheckoutSkipScreenOptions: OptionSet {
    let rawValue: UInt

    /// Skip the confirmation screen for successful transactions.
    static let success = SumUpSDKCheckoutSkipScreenOptions(rawValue: 1 << 0)
    /// Skip the confirmation screen for failed transactions.
    static let failed = SumUpSDKCheckoutSkipScreenOptions(rawValue: 1 << 1)
}

extension SumUpSDKCheckoutSkipScreenOptions {
    /// The corresponding SDK value for use with ``CheckoutRequest/skipScreenOptions``.
    var sdkValue: SkipScreenOptions {
        var options: SkipScreenOptions = []
        if contains(.success) { options.insert(.success) }
        if contains(.failed) { options.insert(.failed) }
        return options
    }
}

// MARK: - Checkout Process As

/// App-layer representation of the credit/debit transaction type,
/// decoupled from the SDK's ``ProcessAs`` enum.
enum SumUpSDKCheckoutProcessAs {
    case credit
    case debit
}

extension SumUpSDKCheckoutProcessAs {
    /// The corresponding SDK value for use with ``CheckoutRequest/processAs``.
    var sdkValue: ProcessAs {
        switch self {
        case .credit: .credit
        case .debit: .debit
        }
    }
}

// MARK: - Live Implementation

/// Forwards all calls to the real `SumUpSDK` static methods.
@MainActor
final class LiveSumUpSDKService: SumUpSDKService {

    /// Single shared SDK service instance for the entire app.
    /// `nonisolated(unsafe)` is safe here: this is an immutable `let` initialized once at static-init time.
    nonisolated(unsafe) static let shared: any SumUpSDKService = LiveSumUpSDKService()

    private let sessionEventSubject = PassthroughSubject<SumUpSDKServiceSessionEvent, Never>()
    
    var sessionEventPublisher: AnyPublisher<SumUpSDKServiceSessionEvent, Never> {
        sessionEventSubject.eraseToAnyPublisher()
    }

    nonisolated init() {
    }

    var isLoggedIn: Bool {
        SumUpSDK.isLoggedIn
    }

    var currentMerchantCurrencyCode: String? {
        SumUpSDK.currentMerchant?.currencyCode
    }

    var currentMerchantCode: String? {
        SumUpSDK.currentMerchant?.merchantCode
    }

    var lastReaderStatus: ReaderStatus? {
        SumUpSDK.lastReaderStatus
    }

    var isTipOnCardReaderAvailable: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return SumUpSDK.isTipOnCardReaderAvailable
        #endif
    }
    
    // MARK: Tipping
    
    /// We check this value in ``CheckoutFlow``.
    /// Persisted per app run.
    var tippingEnabled: Bool = false
    
    /// We check this value in ``CheckoutFlow``.
    /// Persisted per app run.
    var customTipRates: [Int]? = nil

    var isProcessAsRequired: Bool {
        SumUpSDK.isProcessAsRequired
    }

    var skipScreenOptions: SumUpSDKCheckoutSkipScreenOptions = []

    func presentLogin() async throws {
        try await SumUpSDK.presentLogin(from: HostViewControllerProvider.hostViewController, animated: true)
        
        guard SumUpSDK.currentMerchant?.currencyCode != nil else {
            throw SumUpSDKServiceError.missingCurrencyCode
        }
        
        sessionEventSubject.send(.loggedIn)
    }

    func presentCardReaderSettings() async throws {
        try await SumUpSDK.presentCardReaderSettings(from: HostViewControllerProvider.hostViewController, animated: true)
        refreshTippingStatus()
    }

    func checkout(with request: CheckoutRequest) async throws -> SumUpSDKServiceCheckoutResult {
        do {
            let result = try await SumUpSDK.checkout(with: request, from: HostViewControllerProvider.hostViewController)
            return SumUpSDKServiceCheckoutResult(result)
        } catch {
            throw SumUpSDKServiceCheckoutError(sdkError: error)
        }
    }

    func logout() async throws {
        defer { sessionEventSubject.send(.loggedOut) }
        try await SumUpSDK.logout()
    }
    
    // MARK: - Live Offline Implementation
    
    func setupOfflineSession() async throws -> Bool {
        try await SumUpSDK.setupOfflineSession()
    }
    
    func startOfflineSession() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            SumUpSDK.startOfflineSession { success, error in
                
                if !success && error == nil {
                    continuation.resume(throwing: SumUpSDKServiceError.failedToStartOfflineSession(
                        SumUpSDKServiceError.unknown("The user session may be invalid or the user may not be Offline-enabled.")
                    ))
                    return
                }
                
                if let error {
                    continuation.resume(throwing: SumUpSDKServiceError.failedToStartOfflineSession(error))
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    func endOfflineSession() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            SumUpSDK.endOfflineSession { success, error in
                
                if !success && error == nil {
                    continuation.resume(throwing: SumUpSDKServiceError.failedToEndOfflineSession(
                        SumUpSDKServiceError.unknown("The user session or affiliate may be invalid.")
                    ))
                    return
                }
                
                if let error {
                    continuation.resume(throwing: SumUpSDKServiceError.failedToEndOfflineSession(error))
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    func offlineSessionRemainingTime() async throws -> TimeInterval {
        try await SumUpSDK.offlineSessionRemainingTime()
    }
    
    func offlineSessionDetails() async throws -> SumUpSDKServiceOfflineSessionDetails {
        try await withCheckedThrowingContinuation { continuation in
            SumUpSDK.getOfflineSessionDetails { details, error in
                if let error {
                    continuation.resume(throwing: SumUpSDKServiceError.failedToFetchOfflineSessionDetails(error))
                } else if let details {
                    continuation.resume(returning: details)
                } else {
                    continuation.resume(throwing: SumUpSDKServiceError.failedToFetchOfflineSessionDetails(
                        SumUpSDKServiceError.unknown("Unable to retrieve offline session details.")
                    ))
                }
            }
        }
    }
    
    func uploadOfflineSession() async throws -> Bool {
        try await SumUpSDK.uploadOfflineSession()
    }
}

// MARK: - Preview Implementation

@MainActor
final class PreviewSumUpSDKService: SumUpSDKService {
    nonisolated init() {
    }

    var isLoggedIn: Bool {
        true
    }
    
    var sessionEventPublisher: AnyPublisher<SumUpSDKServiceSessionEvent, Never> {
        Empty().eraseToAnyPublisher()
    }

    var currentMerchantCurrencyCode: String? {
        "EUR"
    }

    var currentMerchantCode: String? {
        "M12345678"
    }

    var lastReaderStatus: ReaderStatus? {
        nil
    }

    var isTipOnCardReaderAvailable: Bool {
        true
    }
    
    var customTipRates: [Int]? = [10, 15, 20]
    
    var tippingEnabled: Bool = true

    var isProcessAsRequired: Bool { false }

    var skipScreenOptions: SumUpSDKCheckoutSkipScreenOptions = []

    func presentLogin() async throws {
    }

    func presentCardReaderSettings() async throws {
    }

    func checkout(with request: CheckoutRequest) async throws -> SumUpSDKServiceCheckoutResult {
        SumUpSDKServiceCheckoutResult(MockCheckoutResult(success: false, transactionCode: nil, additionalInfo: nil))
    }

    func logout() async throws {
    }
    
    func startOfflineSession() async throws -> Bool {
        true
    }
    
    func endOfflineSession() async throws -> Bool {
        true
    }
    
    func offlineSessionRemainingTime() async throws -> TimeInterval {
        1600
    }
    
    func offlineSessionDetails() async throws -> SumUpSDKServiceOfflineSessionDetails {
        PreviewOfflineSessionDetails(
            remainingTime: 600,
            approvedTransactionsCount: 23,
            failedTransactionsCount: 2,
            totalApprovedAmount: 1234.56
        )
    }
    
    func uploadOfflineSession() async throws -> Bool {
        true
    }
    
    func setupOfflineSession() async throws -> Bool {
        false
    }
    
    struct PreviewOfflineSessionDetails: SumUpSDKServiceOfflineSessionDetails {
        var remainingTime: TimeInterval
        var approvedTransactionsCount: Int
        var failedTransactionsCount: Int
        var totalApprovedAmount: Decimal
    }
}

// MARK: - Mock Checkout Result

struct MockCheckoutResult: CheckoutResultType {
    var success: Bool
    var transactionCode: String?
    var additionalInfo: [AnyHashable: Any]?
}
