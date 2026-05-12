import Combine
import SumUpSDK
import SwiftUI
@testable import SumUpSDKSampleApp

@MainActor
final class MockSumUpSDKService: SumUpSDKService {
    var isLoggedIn: Bool = true
    var sessionEventPublisher: AnyPublisher<SumUpSDKServiceSessionEvent, Never> {
        Empty().eraseToAnyPublisher()
    }
    var currentMerchantCurrencyCode: String? = "EUR"
    var currentMerchantCode: String? = "MC123456"
    var lastReaderStatus: ReaderStatus? = nil
    var isTipOnCardReaderAvailable: Bool = true
    var customTipRates: [Int]? = nil
    var tippingEnabled: Bool = false
    var isProcessAsRequired: Bool = false
    var skipScreenOptions: SumUpSDKCheckoutSkipScreenOptions = []
    
    var logoutCalled = false
    
    // MARK: - Checkout Stubbing
    
    var checkoutCalled = false
    var lastCheckoutRequest: CheckoutRequest?
    var stubbedCheckoutResult: SumUpSDKServiceCheckoutResult?
    var stubbedCheckoutError: SumUpSDKServiceCheckoutError?
    
    // MARK: - Offline Stubbing
    
    var startOfflineSessionCalled = false
    var endOfflineSessionCalled = false
    var setupOfflineSessionCalled = false
    var uploadOfflineSessionCalled = false
    var offlineSessionDetailsCalled = false
    
    var stubbedOfflineSessionDetails: SumUpSDKServiceOfflineSessionDetails?
    var stubbedOfflineError: Error?
    
    // MARK: - Protocol Methods
    
    func presentLogin() async throws {}
    func presentCardReaderSettings() throws {}
    func checkout(with request: CheckoutRequest) async throws -> SumUpSDKServiceCheckoutResult {
        checkoutCalled = true
        lastCheckoutRequest = request
        if let error = stubbedCheckoutError { throw error }
        guard let result = stubbedCheckoutResult else {
            fatalError("MockSumUpSDKService: stubbedCheckoutResult must be set before calling checkout")
        }
        return result
    }
    func logout() async throws {
        logoutCalled = true
    }
    
    // MARK: - Offline Methods
    
    func setupOfflineSession() async throws -> Bool {
        setupOfflineSessionCalled = true
        if let error = stubbedOfflineError { throw error }
        return true
    }
    
    func startOfflineSession() async throws -> Bool {
        startOfflineSessionCalled = true
        if let error = stubbedOfflineError { throw error }
        return true
    }
    
    func endOfflineSession() async throws -> Bool {
        endOfflineSessionCalled = true
        if let error = stubbedOfflineError { throw error }
        return true
    }
    
    func offlineSessionRemainingTime() async throws -> TimeInterval {
        if let error = stubbedOfflineError { throw error }
        return stubbedOfflineSessionDetails?.remainingTime ?? 0
    }
    
    func offlineSessionDetails() async throws -> SumUpSDKServiceOfflineSessionDetails {
        offlineSessionDetailsCalled = true
        if let error = stubbedOfflineError { throw error }
        guard let details = stubbedOfflineSessionDetails else {
            throw SumUpSDKServiceError.failedToFetchOfflineSessionDetails(
                SumUpSDKServiceError.unknown("No stubbed details")
            )
        }
        return details
    }
    
    func uploadOfflineSession() async throws -> Bool {
        uploadOfflineSessionCalled = true
        if let error = stubbedOfflineError { throw error }
        return true
    }
}

// MARK: - Mock Offline Session Details

struct MockOfflineSessionDetails: SumUpSDKServiceOfflineSessionDetails {
    var remainingTime: TimeInterval
    var approvedTransactionsCount: Int
    var failedTransactionsCount: Int
    var totalApprovedAmount: Decimal
}
