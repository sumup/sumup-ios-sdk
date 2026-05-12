import SumUpSDK
import XCTest
@testable import SumUpSDKSampleApp

@MainActor
final class CheckoutFlowTests: XCTestCase {

    private var mockSDKService: MockSumUpSDKService!

    override func setUp() {
        super.setUp()
        mockSDKService = MockSumUpSDKService()
    }

    override func tearDown() {
        mockSDKService = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(processAsProvider: CheckoutFlow.ProcessAsProvider? = nil) -> CheckoutFlow {
        CheckoutFlow(sdkService: mockSDKService, processAsProvider: processAsProvider)
    }

    private func stubSuccessfulCheckout() {
        mockSDKService.stubbedCheckoutResult = SumUpSDKServiceCheckoutResult(
            MockCheckoutResult(success: true, transactionCode: "TX123")
        )
    }

    private func stubCancelledCheckout() {
        mockSDKService.stubbedCheckoutResult = SumUpSDKServiceCheckoutResult(
            MockCheckoutResult(success: false, transactionCode: nil)
        )
    }

    // MARK: - Guard Conditions

    func test_startCheckout_withNoCurrencyCode_throwsFailedToStartCheckout() async {
        mockSDKService.currentMerchantCurrencyCode = nil
        let sut = makeSUT()

        do {
            try await sut.startCheckout(amount: 10)
            XCTFail("Expected failedToStartCheckout error")
        } catch let error as CheckoutFlowError {
            if case .failedToStartCheckout = error {} else {
                XCTFail("Expected failedToStartCheckout, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertFalse(mockSDKService.checkoutCalled)
    }

    func test_startCheckout_withZeroAmount_throwsFailedToStartCheckout() async {
        let sut = makeSUT()

        do {
            try await sut.startCheckout(amount: 0)
            XCTFail("Expected failedToStartCheckout error")
        } catch let error as CheckoutFlowError {
            if case .failedToStartCheckout = error {} else {
                XCTFail("Expected failedToStartCheckout, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertFalse(mockSDKService.checkoutCalled)
    }

    // MARK: - Direct Checkout (Process-As Not Required)

    func test_startCheckout_whenNotProcessAsRequired_performsCheckoutDirectly() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = false
        let sut = makeSUT()

        let result = try await sut.startCheckout(amount: 10)

        XCTAssertTrue(mockSDKService.checkoutCalled)
        XCTAssertTrue(result.success)
    }

    func test_startCheckout_whenNotProcessAsRequired_setsCorrectTotalOnRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = false
        let sut = makeSUT()

        try await sut.startCheckout(amount: 12)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.totalAmount, NSDecimalNumber(decimal: 12))
    }

    func test_startCheckout_whenNotProcessAsRequired_setsCurrencyCodeOnRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.currentMerchantCurrencyCode = "BRL"
        mockSDKService.isProcessAsRequired = false
        let sut = makeSUT()

        try await sut.startCheckout(amount: 5)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.currencyCode, "BRL")
    }

    func test_startCheckout_forwardsSkipScreenOptionsToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.skipScreenOptions = [.success]
        let sut = makeSUT()

        try await sut.startCheckout(amount: 1)

        let request = mockSDKService.lastCheckoutRequest
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.skipScreenOptions.contains(.success) ?? false)
    }

    func test_startCheckout_forwardsTippingEnabledToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.tippingEnabled = true
        let sut = makeSUT()

        try await sut.startCheckout(amount: 1)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.tipOnCardReaderIfAvailable, true)
    }

    func test_startCheckout_forwardsTippingDisabledToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.tippingEnabled = false
        let sut = makeSUT()

        try await sut.startCheckout(amount: 1)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.tipOnCardReaderIfAvailable, false)
    }

    func test_startCheckout_forwardsCustomTipRatesToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.customTipRates = [10, 15, 20]
        let sut = makeSUT()

        try await sut.startCheckout(amount: 1)

        let expected: [NSNumber] = [10, 15, 20]
        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.customTipRates, expected)
    }

    func test_startCheckout_forwardsNilCustomTipRatesToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.customTipRates = nil
        let sut = makeSUT()

        try await sut.startCheckout(amount: 1)

        XCTAssertNil(mockSDKService.lastCheckoutRequest?.customTipRates)
    }

    // MARK: - Process-As Required — Provider Returns Selection

    func test_startCheckout_whenProcessAsRequired_callsProcessAsProvider() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        var providerCalled = false
        let sut = makeSUT {
            providerCalled = true
            return CheckoutFlow.ProcessAsSelection(processAs: .credit, installments: 1)
        }

        try await sut.startCheckout(amount: 5)

        XCTAssertTrue(providerCalled)
        XCTAssertTrue(mockSDKService.checkoutCalled)
    }

    func test_startCheckout_credit_setsProcessAsOnRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .credit, installments: 3)
        }

        try await sut.startCheckout(amount: 5)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.processAs, .credit)
    }

    func test_startCheckout_debit_setsProcessAsOnRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .debit, installments: 0)
        }

        try await sut.startCheckout(amount: 5)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.processAs, .debit)
    }

    func test_startCheckout_creditWithInstallments_setsInstallmentsOnRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .credit, installments: 6)
        }

        try await sut.startCheckout(amount: 10)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.numberOfInstallments, 6)
    }

    func test_startCheckout_debit_doesNotSetInstallments() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .debit, installments: 0)
        }

        try await sut.startCheckout(amount: 10)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.numberOfInstallments, 0)
    }

    func test_startCheckout_processAs_passesTotalToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .credit, installments: 1)
        }

        try await sut.startCheckout(amount: 25)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.totalAmount, NSDecimalNumber(decimal: 25))
    }

    func test_startCheckout_processAs_passesCurrencyCodeToRequest() async throws {
        stubSuccessfulCheckout()
        mockSDKService.currentMerchantCurrencyCode = "BRL"
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .credit, installments: 1)
        }

        try await sut.startCheckout(amount: 5)

        XCTAssertEqual(mockSDKService.lastCheckoutRequest?.currencyCode, "BRL")
    }

    // MARK: - Process-As Required — Provider Returns nil (Cancel)

    func test_startCheckout_whenProcessAsProviderReturnsNil_throwsCancelled() async {
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT { nil }

        do {
            try await sut.startCheckout(amount: 5)
            XCTFail("Expected cancelled error")
        } catch let error as CheckoutFlowError {
            if case .cancelled = error {} else {
                XCTFail("Expected cancelled, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertFalse(mockSDKService.checkoutCalled)
    }

    // MARK: - Checkout Result Handling

    func test_successfulCheckout_returnsResult() async throws {
        stubSuccessfulCheckout()
        let sut = makeSUT()

        let result = try await sut.startCheckout(amount: 15)

        XCTAssertTrue(result.success)
        XCTAssertEqual(result.transactionCode, "TX123")
    }

    func test_cancelledCheckout_throwsCancelled() async {
        stubCancelledCheckout()
        let sut = makeSUT()

        do {
            try await sut.startCheckout(amount: 15)
            XCTFail("Expected cancelled error")
        } catch let error as CheckoutFlowError {
            if case .cancelled = error {} else {
                XCTFail("Expected cancelled, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_checkoutThrows_throwsGeneralSdkError() async {
        mockSDKService.stubbedCheckoutError = .generalSdkError(NSError(domain: "TestDomain", code: 99))
        let sut = makeSUT()

        do {
            try await sut.startCheckout(amount: 1)
            XCTFail("Expected generalSdkError")
        } catch let error as SumUpSDKServiceCheckoutError {
            if case .generalSdkError = error {} else {
                XCTFail("Expected generalSdkError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_checkoutThrowsAccountNotLoggedIn_throwsAccountNotLoggedInError() async {
        mockSDKService.stubbedCheckoutError = .accountNotLoggedIn(
            NSError(domain: SumUpSDKErrorDomain, code: SumUpSDKError.accountNotLoggedIn.rawValue)
        )
        let sut = makeSUT()

        do {
            try await sut.startCheckout(amount: 1)
            XCTFail("Expected accountNotLoggedIn error")
        } catch let error as SumUpSDKServiceCheckoutError {
            if case .accountNotLoggedIn = error {} else {
                XCTFail("Expected accountNotLoggedIn, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Process-As with Checkout Result Handling

    func test_processAs_successfulCheckout_returnsResult() async throws {
        stubSuccessfulCheckout()
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .credit, installments: 1)
        }

        let result = try await sut.startCheckout(amount: 20)

        XCTAssertTrue(result.success)
    }

    func test_processAs_checkoutThrows_throwsError() async {
        mockSDKService.stubbedCheckoutError = .generalSdkError(NSError(domain: "TestDomain", code: 42))
        mockSDKService.isProcessAsRequired = true
        let sut = makeSUT {
            CheckoutFlow.ProcessAsSelection(processAs: .debit, installments: 0)
        }

        do {
            try await sut.startCheckout(amount: 5)
            XCTFail("Expected error")
        } catch is SumUpSDKServiceCheckoutError {
            // Expected
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
