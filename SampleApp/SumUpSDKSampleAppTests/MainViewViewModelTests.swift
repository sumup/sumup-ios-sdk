import SumUpSDK
import XCTest
@testable import SumUpSDKSampleApp

@MainActor
final class MainViewViewModelTests: XCTestCase {

    private var mockSDKService: MockSumUpSDKService!
    private var sessionState: SessionState!
    private var checkoutFlow: CheckoutFlow!
    private var sut: MainViewViewModel!

    // Closure-tracking flags
    private var settingsRequested = false

    override func setUp() {
        super.setUp()
        mockSDKService = MockSumUpSDKService()
        sessionState = SessionState()
        sessionState.currencyCode = "EUR"
        sessionState.merchantCode = "MC123456"
        checkoutFlow = CheckoutFlow(sdkService: mockSDKService)
        sut = MainViewViewModel(
            sessionState: sessionState,
            sdkService: mockSDKService,
            checkoutFlow: checkoutFlow
        )

        // Reset tracking flags
        settingsRequested = false

        // Wire closure tracking
        sut.onRequestSettings = { [unowned self] in
            settingsRequested = true
        }
    }

    override func tearDown() {
        sut = nil
        checkoutFlow = nil
        sessionState = nil
        mockSDKService = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func enterAmount(_ digits: [UInt8]) {
        for digit in digits {
            sut.addNumberToAmount(digit)
        }
    }

    // MARK: - Charge: Zero Amount Guard

    func test_charge_withZeroAmount_showsError() async {
        await sut.charge()

        XCTAssertNotNil(sut.alertState)
        XCTAssertFalse(mockSDKService.checkoutCalled)
    }

    func test_charge_withNonZeroAmount_delegatesToCheckoutFlow() async {
        mockSDKService.stubbedCheckoutResult = SumUpSDKServiceCheckoutResult(
            MockCheckoutResult(success: true, transactionCode: "TX123")
        )
        enterAmount([1, 0])

        await sut.charge()

        XCTAssertTrue(mockSDKService.checkoutCalled)
    }

    // MARK: - Merchant Code

    func test_merchantCode_returnsSessionStateValue() {
        sessionState.merchantCode = "MX999"
        XCTAssertEqual(sut.merchantCode, "MX999")
    }

    func test_merchantCode_returnsEmptyStringWhenNil() {
        sessionState.merchantCode = nil
        XCTAssertEqual(sut.merchantCode, "")
    }

    // MARK: - Reset Input

    func test_resetInput_clearsPaymentAmount() {
        enterAmount([5, 0])
        XCTAssertEqual(sut.paymentAmount, 50)

        sut.resetInput()

        XCTAssertEqual(sut.paymentAmount, 0)
    }

    // MARK: - showError (formatting)

    func test_showError_callsOnShowErrorWithFormattedMessage() {
        let error = SumUpSDKServiceCheckoutError.generalSdkError(
            NSError(domain: "Test", code: 1)
        )

        sut.showError(error)

        XCTAssertNotNil(sut.alertState)
        XCTAssertEqual(sut.alertState?.title, "Error")
        XCTAssertNotNil(sut.alertState?.message)
    }

    // MARK: - Numpad

    func test_addNumberToAmount_updatesPaymentAmount() {
        sut.addNumberToAmount(5)

        XCTAssertEqual(sut.paymentAmount, 5)
    }

    func test_backspacePaymentAmount_removesLastDigit() {
        enterAmount([1, 2, 3])

        sut.backspacePaymentAmount()

        XCTAssertEqual(sut.paymentAmount, 12)
    }
}
