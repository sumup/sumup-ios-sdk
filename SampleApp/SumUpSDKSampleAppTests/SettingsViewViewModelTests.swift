import Combine
import SwiftUI
import XCTest
@testable import SumUpSDKSampleApp

@MainActor
final class SettingsViewViewModelTests: XCTestCase {
    
    private var mockSDKService: MockSumUpSDKService!
    private var sessionState: SessionState!
    private var sut: SettingsViewViewModel!
    
    override func setUp() {
        super.setUp()
        mockSDKService = MockSumUpSDKService()
        sessionState = SessionState()
        sut = SettingsViewViewModel(sessionState: sessionState, sdkService: mockSDKService)
    }
    
    override func tearDown() {
        sut = nil
        sessionState = nil
        mockSDKService = nil
        super.tearDown()
    }
    
    // MARK: - Tipping Enabled
    
    func test_tippingEnabled_get_returnsSDKServiceValue() {
        mockSDKService.tippingEnabled = true
        XCTAssertTrue(sut.tippingEnabled)
        
        mockSDKService.tippingEnabled = false
        XCTAssertFalse(sut.tippingEnabled)
    }
    
    func test_tippingEnabled_set_updatesSDKService() {
        sut.tippingEnabled = true
        XCTAssertTrue(mockSDKService.tippingEnabled)
        
        sut.tippingEnabled = false
        XCTAssertFalse(mockSDKService.tippingEnabled)
    }
    
    // MARK: - Tip On Card Reader Available
    
    func test_isTipOnCardReaderAvailable_returnsSDKServiceValue() {
        mockSDKService.isTipOnCardReaderAvailable = true
        XCTAssertTrue(sut.isTipOnCardReaderAvailable)
        
        mockSDKService.isTipOnCardReaderAvailable = false
        XCTAssertFalse(sut.isTipOnCardReaderAvailable)
    }
    
    // MARK: - Tip Options
    
    func test_tipOptions_initializedFromSDKService() {
        mockSDKService.customTipRates = [5, 12, 18]
        let viewModel = SettingsViewViewModel(sessionState: sessionState, sdkService: mockSDKService)
        
        XCTAssertEqual(viewModel.tipOption1.wrappedValue, "5")
        XCTAssertEqual(viewModel.tipOption2.wrappedValue, "12")
        XCTAssertEqual(viewModel.tipOption3.wrappedValue, "18")
    }
    
    func test_tipOptions_emptyWhenZero() {
        mockSDKService.customTipRates = []
        let viewModel = SettingsViewViewModel(sessionState: sessionState, sdkService: mockSDKService)
        
        XCTAssertEqual(viewModel.tipOption1.wrappedValue, "")
        XCTAssertEqual(viewModel.tipOption2.wrappedValue, "")
        XCTAssertEqual(viewModel.tipOption3.wrappedValue, "")
    }
    
    func test_tipOptions_setUpdatesModel() {
        sut.tipOption1.wrappedValue = "8"
        sut.tipOption2.wrappedValue = "17"
        sut.tipOption3.wrappedValue = "25"
        
        XCTAssertEqual(sut.tipRates.tipRate1, 8)
        XCTAssertEqual(sut.tipRates.tipRate2, 17)
        XCTAssertEqual(sut.tipRates.tipRate3, 25)
    }
    
    func test_tipOptions_setEmptyStringResultsInZero() {
        sut.tipOption1.wrappedValue = "12"
        sut.tipOption1.wrappedValue = ""
        
        XCTAssertEqual(sut.tipRates.tipRate1, 0)
    }
    
    func test_tipOptions_setInvalidStringResultsInZero() {
        sut.tipOption1.wrappedValue = "abc"
        
        XCTAssertEqual(sut.tipRates.tipRate1, 0)
    }
    
    // MARK: - TipRatesModel.allRatesZero
    
    func test_allRatesZero_trueWhenAllZero() {
        let model = SettingsViewViewModel.TipRatesModel(tipRate1: 0, tipRate2: 0, tipRate3: 0)
        XCTAssertTrue(model.allRatesZero)
    }
    
    func test_allRatesZero_falseWhenFirstRateNonZero() {
        let model = SettingsViewViewModel.TipRatesModel(tipRate1: 5, tipRate2: 0, tipRate3: 0)
        XCTAssertFalse(model.allRatesZero)
    }
    
    func test_allRatesZero_falseWhenSecondRateNonZero() {
        let model = SettingsViewViewModel.TipRatesModel(tipRate1: 0, tipRate2: 10, tipRate3: 0)
        XCTAssertFalse(model.allRatesZero)
    }
    
    func test_allRatesZero_falseWhenThirdRateNonZero() {
        let model = SettingsViewViewModel.TipRatesModel(tipRate1: 0, tipRate2: 0, tipRate3: 15)
        XCTAssertFalse(model.allRatesZero)
    }
    
    func test_allRatesZero_falseWhenAllNonZero() {
        let model = SettingsViewViewModel.TipRatesModel(tipRate1: 5, tipRate2: 10, tipRate3: 15)
        XCTAssertFalse(model.allRatesZero)
    }
    
    // MARK: - Tip Placeholders
    
    func test_tipPlaceholders_returnDefaultValues() {
        XCTAssertEqual(sut.tipPlaceholder1, "10")
        XCTAssertEqual(sut.tipPlaceholder2, "15")
        XCTAssertEqual(sut.tipPlaceholder3, "20")
    }
    
    func test_tipPlaceholders_returnDashWhenAnyRateIsSet() {
        sut.tipOption1.wrappedValue = "5"
        
        XCTAssertEqual(sut.tipPlaceholder1, "-")
        XCTAssertEqual(sut.tipPlaceholder2, "-")
        XCTAssertEqual(sut.tipPlaceholder3, "-")
    }
    
    func test_tipPlaceholders_returnDashWhenAllRatesAreSet() {
        sut.tipOption1.wrappedValue = "5"
        sut.tipOption2.wrappedValue = "10"
        sut.tipOption3.wrappedValue = "15"
        
        XCTAssertEqual(sut.tipPlaceholder1, "-")
        XCTAssertEqual(sut.tipPlaceholder2, "-")
        XCTAssertEqual(sut.tipPlaceholder3, "-")
    }
    
    func test_tipPlaceholders_returnDefaultsAfterClearingAllRates() {
        sut.tipOption1.wrappedValue = "5"
        sut.tipOption1.wrappedValue = ""
        
        XCTAssertEqual(sut.tipPlaceholder1, "10")
        XCTAssertEqual(sut.tipPlaceholder2, "15")
        XCTAssertEqual(sut.tipPlaceholder3, "20")
    }
    
    // MARK: - Commit Tip Rates
    
    func test_commitTipRates_savesValidRatesToSDKService() {
        sut.tipOption1.wrappedValue = "5"
        sut.tipOption2.wrappedValue = "12"
        sut.tipOption3.wrappedValue = "18"
        
        sut.commitTipRates()
        
        XCTAssertEqual(mockSDKService.customTipRates, [5, 12, 18])
    }
    
    func test_commitTipRates_filtersZeroValues() {
        sut.tipOption1.wrappedValue = "8"
        sut.tipOption2.wrappedValue = ""
        sut.tipOption3.wrappedValue = "22"
        
        sut.commitTipRates()
        
        XCTAssertEqual(mockSDKService.customTipRates, [8, 22])
    }
    
    func test_commitTipRates_filtersNegativeValues() {
        sut.tipRates.tipRate1 = -5
        sut.tipOption2.wrappedValue = "12"
        sut.tipOption3.wrappedValue = "25"
        
        sut.commitTipRates()
        
        XCTAssertEqual(mockSDKService.customTipRates, [12, 25])
    }
    
    func test_commitTipRates_filtersValuesOver100() {
        sut.tipOption1.wrappedValue = "8"
        sut.tipOption2.wrappedValue = "150"
        sut.tipOption3.wrappedValue = "25"
        
        sut.commitTipRates()
        
        XCTAssertEqual(mockSDKService.customTipRates, [8, 25])
    }
    
    func test_commitTipRates_sortsValues() {
        sut.tipOption1.wrappedValue = "25"
        sut.tipOption2.wrappedValue = "8"
        sut.tipOption3.wrappedValue = "12"
        
        sut.commitTipRates()
        
        XCTAssertEqual(mockSDKService.customTipRates, [8, 12, 25])
    }
    
    func test_commitTipRates_setsNilWhenAllInvalid() {
        sut.tipOption1.wrappedValue = ""
        sut.tipOption2.wrappedValue = ""
        sut.tipOption3.wrappedValue = ""
        
        sut.commitTipRates()
        
        XCTAssertNil(mockSDKService.customTipRates)
    }
    
    // MARK: - Merchant Code
    
    func test_merchantCode_returnsSessionStateValue() {
        sessionState.merchantCode = "MC123456"
        XCTAssertEqual(sut.merchantCode, "MC123456")
    }
    
    func test_merchantCode_returnsEmptyStringWhenNil() {
        sessionState.merchantCode = nil
        XCTAssertEqual(sut.merchantCode, "")
    }
    
    // MARK: - Installments Enabled
    
    func test_installmentsEnabled_returnsTrueWhenSDKServiceIsProcessAsRequired() {
        mockSDKService.isProcessAsRequired = true
        XCTAssertTrue(sut.installmentsEnabled)
    }
    
    func test_installmentsEnabled_returnsFalseWhenSDKServiceIsProcessAsNotRequired() {
        mockSDKService.isProcessAsRequired = false
        XCTAssertFalse(sut.installmentsEnabled)
    }
    
    // MARK: - Transaction Success
    
    func test_transactionSuccessEnabled_get_returnsTrueWhenSkipScreenOptionsEmpty() {
        mockSDKService.skipScreenOptions = []
        XCTAssertTrue(sut.transactionSuccessEnabled)
    }
    
    func test_transactionSuccessEnabled_get_returnsFalseWhenSuccessOptionSet() {
        mockSDKService.skipScreenOptions = [.success]
        XCTAssertFalse(sut.transactionSuccessEnabled)
    }
    
    func test_transactionSuccessEnabled_set_true_removesSuccessOption() {
        mockSDKService.skipScreenOptions = [.success]
        sut.transactionSuccessEnabled = true
        XCTAssertFalse(mockSDKService.skipScreenOptions.contains(.success))
    }
    
    func test_transactionSuccessEnabled_set_false_insertsSuccessOption() {
        mockSDKService.skipScreenOptions = []
        sut.transactionSuccessEnabled = false
        XCTAssertTrue(mockSDKService.skipScreenOptions.contains(.success))
    }
    
    func test_transactionSuccessEnabled_set_preservesOtherOptions() {
        mockSDKService.skipScreenOptions = [.failed]
        sut.transactionSuccessEnabled = false
        XCTAssertTrue(mockSDKService.skipScreenOptions.contains(.success))
        XCTAssertTrue(mockSDKService.skipScreenOptions.contains(.failed))
        
        sut.transactionSuccessEnabled = true
        XCTAssertFalse(mockSDKService.skipScreenOptions.contains(.success))
        XCTAssertTrue(mockSDKService.skipScreenOptions.contains(.failed))
    }
    
    // MARK: - Check Offline Session Details
    
    func test_checkOfflineSessionDetails_setsOfflineStatusOnSuccess() async {
        mockSDKService.stubbedOfflineSessionDetails = MockOfflineSessionDetails(
            remainingTime: 600,
            approvedTransactionsCount: 3,
            failedTransactionsCount: 1,
            totalApprovedAmount: 42.50
        )
        
        await sut.checkOfflineSessionDetails()
        
        XCTAssertNotNil(sut.offlineStatus)
        XCTAssertEqual(sut.offlineStatus?.remainingTime, 600)
        XCTAssertEqual(sut.offlineStatus?.approvedTransactionsCount, 3)
        XCTAssertEqual(sut.offlineStatus?.failedTransactionsCount, 1)
        XCTAssertEqual(sut.offlineStatus?.totalApprovedAmount, 42.50)
    }
    
    func test_checkOfflineSessionDetails_setsOfflineStatusNilOnError() async {
        mockSDKService.stubbedOfflineError = SumUpSDKServiceError.unknown("test error")
        
        await sut.checkOfflineSessionDetails()
        
        XCTAssertNil(sut.offlineStatus)
    }
    
    func test_checkOfflineSessionDetails_setsIsOfflineBusyFalseAfterCompletion() async {
        mockSDKService.stubbedOfflineSessionDetails = MockOfflineSessionDetails(
            remainingTime: 0,
            approvedTransactionsCount: 0,
            failedTransactionsCount: 0,
            totalApprovedAmount: 0
        )
        
        await sut.checkOfflineSessionDetails()
        
        XCTAssertFalse(sut.isOfflineBusy)
    }
    
    // MARK: - Offline Status Button States
    
    func test_offlineStatus_activeSession_disablesStartEnablesEnd() {
        sut.offlineStatus = OfflineStatusModel(
            remainingTime: 300,
            endDate: Date(timeIntervalSinceNow: 300),
            approvedTransactionsCount: 0,
            failedTransactionsCount: 0,
            totalApprovedAmount: 0
        )
        
        XCTAssertTrue(sut.isStartOfflineButtonDisabled)
        XCTAssertFalse(sut.isEndOfflineButtonDisabled)
    }
    
    func test_offlineStatus_inactiveSession_enablesStartDisablesEnd() {
        sut.offlineStatus = OfflineStatusModel(
            remainingTime: 0,
            endDate: Date(),
            approvedTransactionsCount: 0,
            failedTransactionsCount: 0,
            totalApprovedAmount: 0
        )
        
        XCTAssertFalse(sut.isStartOfflineButtonDisabled)
        XCTAssertTrue(sut.isEndOfflineButtonDisabled)
    }
    
    func test_offlineStatus_nil_enablesStartDisablesEnd() {
        sut.offlineStatus = nil
        
        XCTAssertFalse(sut.isStartOfflineButtonDisabled)
        XCTAssertTrue(sut.isEndOfflineButtonDisabled)
    }
    
    // MARK: - Start Offline Session
    
    func test_startOfflineSession_callsSDKService() async {
        mockSDKService.stubbedOfflineSessionDetails = MockOfflineSessionDetails(
            remainingTime: 600,
            approvedTransactionsCount: 0,
            failedTransactionsCount: 0,
            totalApprovedAmount: 0
        )
        
        await sut.startOfflineSession()
        
        XCTAssertTrue(mockSDKService.startOfflineSessionCalled)
    }
    
    func test_startOfflineSession_refreshesDetailsOnSuccess() async {
        mockSDKService.stubbedOfflineSessionDetails = MockOfflineSessionDetails(
            remainingTime: 600,
            approvedTransactionsCount: 0,
            failedTransactionsCount: 0,
            totalApprovedAmount: 0
        )
        
        await sut.startOfflineSession()
        
        XCTAssertTrue(mockSDKService.offlineSessionDetailsCalled)
        XCTAssertNotNil(sut.offlineStatus)
    }
    
    func test_startOfflineSession_showsErrorOnFailure() async {
        mockSDKService.stubbedOfflineError = SumUpSDKServiceError.failedToStartOfflineSession(
            SumUpSDKServiceError.unknown("test")
        )
        
        await sut.startOfflineSession()
        
        XCTAssertNotNil(sut.alertState)
        XCTAssertNotNil(sut.alertState?.message)
    }
    
    // MARK: - Stop Offline Session
    
    func test_stopOfflineSession_callsSDKService() async {
        mockSDKService.stubbedOfflineSessionDetails = MockOfflineSessionDetails(
            remainingTime: 0,
            approvedTransactionsCount: 0,
            failedTransactionsCount: 0,
            totalApprovedAmount: 0
        )
        
        await sut.stopOfflineSession()
        
        XCTAssertTrue(mockSDKService.endOfflineSessionCalled)
    }
    
    func test_stopOfflineSession_refreshesDetailsOnSuccess() async {
        mockSDKService.stubbedOfflineSessionDetails = MockOfflineSessionDetails(
            remainingTime: 0,
            approvedTransactionsCount: 5,
            failedTransactionsCount: 2,
            totalApprovedAmount: 100
        )
        
        await sut.stopOfflineSession()
        
        XCTAssertTrue(mockSDKService.offlineSessionDetailsCalled)
        XCTAssertNotNil(sut.offlineStatus)
    }
    
    func test_stopOfflineSession_showsErrorOnFailure() async {
        mockSDKService.stubbedOfflineError = SumUpSDKServiceError.failedToEndOfflineSession(
            SumUpSDKServiceError.unknown("test")
        )
        
        await sut.stopOfflineSession()
        
        XCTAssertNotNil(sut.alertState)
        XCTAssertNotNil(sut.alertState?.message)
    }
    
    // MARK: - Check Offline Updates
    
    func test_checkOfflineUpdates_callsSDKService() async {
        await sut.checkOfflineUpdates()
        
        XCTAssertTrue(mockSDKService.setupOfflineSessionCalled)
    }
    
    func test_checkOfflineUpdates_showsErrorOnFailure() async {
        mockSDKService.stubbedOfflineError = SumUpSDKServiceError.unknown("setup error")
        
        await sut.checkOfflineUpdates()
        
        XCTAssertNotNil(sut.alertState)
        XCTAssertNotNil(sut.alertState?.message)
    }
    
    // MARK: - Upload Offline Data
    
    func test_uploadOfflineData_callsSDKService() async {
        await sut.uploadOfflineData()
        
        XCTAssertTrue(mockSDKService.uploadOfflineSessionCalled)
    }
    
    func test_uploadOfflineData_showsErrorOnFailure() async {
        mockSDKService.stubbedOfflineError = SumUpSDKServiceError.unknown("upload error")
        
        await sut.uploadOfflineData()
        
        XCTAssertNotNil(sut.alertState)
        XCTAssertNotNil(sut.alertState?.message)
    }
    
    // MARK: - Logout
    
    func test_logout_callsSDKService() async {
        await sut.logout()
        XCTAssertTrue(mockSDKService.logoutCalled)
    }
}

