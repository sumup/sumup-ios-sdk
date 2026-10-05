import SumUpSDK

/**
 This ViewModel supports the ``MainView`` and interacts with the SumUp SDK on its behalf.
 
 # SumUp SDK Interaction
 Jump straight to the methods that call the SDK.
 
 ## Reader Settings
 Show card reader status/settings and connect to a new card reader.
 
 ``MainViewViewModel/presentCardReaderSettings()``
 
 ## Perform a checkout
 Create a new checkout request and begin the checkout.
 
 ``MainViewViewModel/charge()``
 */
@MainActor
final class MainViewViewModel: ObservableObject, AlertStateManaging {

    private enum Flags {
        static let showErrorForCanceledTransaction = false
    }

    let sessionState: SessionState
    private let sdkService: any SumUpSDKService
    private let numpadMathProvider: NumpadMathProvider
    let checkoutFlow: CheckoutFlow

    // MARK: Navigation Closures (set by coordinator)

    /// Called when the user taps the settings button.
    var onRequestSettings: () -> Void = {}

    // MARK: Alert State (AlertStateManaging)

    @Published var alertState: AlertState?

    init(
        sessionState: SessionState,
        sdkService: any SumUpSDKService,
        checkoutFlow: CheckoutFlow,
        numpadMathProvider: NumpadMathProvider = .init()
    ) {
        self.sessionState = sessionState
        self.sdkService = sdkService
        self.checkoutFlow = checkoutFlow
        self.numpadMathProvider = numpadMathProvider
    }
    
    // MARK: View Properties
    
    @Published var paymentAmount: Decimal = 0
    @Published var readerStatus: ReaderStatus?
    @Published var showOfflineButton = false
    
    var merchantCode: String {
        sessionState.merchantCode ?? ""
    }
    
    var merchantCurrencyCode: String {
        guard let code = sessionState.currencyCode else {
            assertionFailure("Currency code should be set when logged in")
            return ""
        }
        return code
    }
    
    func onViewAppear() async {
        readerStatus = sdkService.lastReaderStatus
        await updateOfflineDisplay()
    }
    
    func onSettingsClose() async {
        await updateOfflineDisplay()
    }
    
    // MARK: View Actions
    
    func presentCardReaderSettings() async {
        do {
            try await sdkService.presentCardReaderSettings()
        } catch {
            showError(SumUpSDKServiceError.failedToPresentCardReaderSettings(error))
        }
    }
    
    func charge() async {
        do {
            let result = try await checkoutFlow.startCheckout(amount: numpadMathProvider.amount)

            print("Transaction Result Code: \(String(describing: result.transactionCode))")

            if let tipAmount = result.transactionInfo?.tipAmount, tipAmount > 0 {
                print("Tip: \(tipAmount) \(result.transactionInfo?.currencyCode ?? "")")
            }

            resetInput()
        } catch let error as CheckoutFlowError {
            if case .cancelled = error, !Flags.showErrorForCanceledTransaction { return }
            showError(error)
        } catch {
            showError(error)
        }
    }
    
    private func updateOfflineDisplay() async {
        if let details = try? await sdkService.offlineSessionDetails() {
            let status = OfflineStatusModel(details)
            showOfflineButton = status.isSessionActive
        } else {
            showOfflineButton = false
        }
    }
    
    func resetInput() {
        numpadMathProvider.clear()
        paymentAmount = numpadMathProvider.amount
    }
    

    
    // MARK: Numpad Methods
        
    func addNumberToAmount(_ number: UInt8) {
        numpadMathProvider.addDigitToEnd(number)
        paymentAmount = numpadMathProvider.amount
    }
    
    func insertDecimalPoint() {
        numpadMathProvider.addDecimal()
        paymentAmount = numpadMathProvider.amount
    }
    
    func backspacePaymentAmount() {
        numpadMathProvider.removeLastDigit()
        paymentAmount = numpadMathProvider.amount
    }
}
