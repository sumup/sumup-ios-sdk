import SumUpSDK

@MainActor
final class SessionState: ObservableObject {

    @Published var isLoggedIn: Bool = false
    @Published var merchantCode: String?
    @Published var currencyCode: String?

    init() {
    }

    func update(with sdkService: any SumUpSDKService) {
        let loggedIn = sdkService.isLoggedIn
        let currency = sdkService.currentMerchantCurrencyCode
        
        // Require valid currency code to be considered fully logged in
        isLoggedIn = loggedIn && currency != nil
        merchantCode = sdkService.currentMerchantCode
        currencyCode = currency
    }
}

extension SessionState {
    static func previewInstance(isLoggedIn: Bool = true) -> SessionState {
        let instance = SessionState()
        instance.isLoggedIn = isLoggedIn
        instance.merchantCode = "ZXCVBN123"
        instance.currencyCode = "EUR"
        return instance
    }
}
