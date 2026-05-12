import SwiftUI
import SumUpSDK

/**
 Supports the ``SettingsView`` and interacts with the injected SumUp SDK on its behalf.
 
 # SumUp SDK Interaction
 Jump straight to the methods that call the SDK.
 
 ## Tipping
 ### Interact with the SDK to enable and disable.
 ``SettingsViewViewModel/tippingEnabled``
 
 ### Check whether the current/last card reader supports tipping
 ``SettingsViewViewModel/isTipOnCardReaderAvailable``
 
 ### Save custom tip rates to the SDK
 ``SettingsViewViewModel/commitTipRates()``
 
 ## Offline Payments
 ### Query the current offline session state from the SDK.
 ``SettingsViewViewModel/checkOfflineSessionDetails()``
 
 ### Start an offline payment session.
 ``SettingsViewViewModel/startOfflineSession()``
 
 ### Stop the active offline payment session.
 ``SettingsViewViewModel/stopOfflineSession()``
 
 ### Check for offline configuration updates from the backend.
 ``SettingsViewViewModel/checkOfflineUpdates()``
 
 ### Upload queued offline transaction data to SumUp servers.
 ``SettingsViewViewModel/uploadOfflineData()``
 
 ### The current offline session state, derived from ``SumUpSDKServiceOfflineSessionDetails``.
 ``SettingsViewViewModel/offlineStatus``
 
 ## Logging Out
 ### End the current user's session in the SDK.
 ``SettingsViewViewModel/logout()``
 */
@MainActor
final class SettingsViewViewModel: ObservableObject, AlertStateManaging {
    private static let defaultTipRates = TipRatesModel.defaultValues
    
    let sessionState: SessionState
    private let sdkService: any SumUpSDKService

    init(
        sessionState: SessionState,
        sdkService: any SumUpSDKService
    ) {
        self.sessionState = sessionState
        self.sdkService = sdkService
        self.tipRates = TipRatesModel(sdkService.customTipRates ?? [])
    }

    // MARK: Alert State (AlertStateManaging)

    @Published var alertState: AlertState?
    
    // MARK: View Properties
    
    @Published var tapToPayEnabled = false
    @Published var isOfflineBusy = true

    /// Whether the SumUp success screen is shown after a successful transaction.
    /// Inverts the SDK's skip-screen option: `true` = show (don't skip), `false` = skip.
    var transactionSuccessEnabled: Bool {
        get { !sdkService.skipScreenOptions.contains(.success) }
        set {
            if newValue {
                sdkService.skipScreenOptions.remove(.success)
            } else {
                sdkService.skipScreenOptions.insert(.success)
            }
            objectWillChange.send()
        }
    }

    var installmentsEnabled: Bool {
        sdkService.isProcessAsRequired
    }
    
    var tippingEnabled: Bool {
        get { sdkService.tippingEnabled }
        set { sdkService.tippingEnabled = newValue; objectWillChange.send() }
    }

    // MARK: - Tipping
    
    @Published var tipRates: TipRatesModel
    
    var isTipOnCardReaderAvailable: Bool {
        sdkService.isTipOnCardReaderAvailable
    }
    
    var tipOption1: Binding<String> {
        Binding(
            get: { self.tipRates.tipRate1.stringOrEmptyIfZero },
            set: { self.tipRates.tipRate1 = $0.intOrZero }
        )
    }
    
    var tipOption2: Binding<String> {
        Binding(
            get: { self.tipRates.tipRate2.stringOrEmptyIfZero },
            set: { self.tipRates.tipRate2 = $0.intOrZero }
        )
    }
    
    var tipOption3: Binding<String> {
        Binding(
            get: { self.tipRates.tipRate3.stringOrEmptyIfZero },
            set: { self.tipRates.tipRate3 = $0.intOrZero }
        )
    }
    
    var tipPlaceholder1: String {
        tipRates.allRatesZero ? String(Self.defaultTipRates.tipRate1) : "-"
    }
    
    var tipPlaceholder2: String {
        tipRates.allRatesZero ? String(Self.defaultTipRates.tipRate2) : "-"
    }
    
    var tipPlaceholder3: String {
        tipRates.allRatesZero ? String(Self.defaultTipRates.tipRate3) : "-"
    }
    
    func commitTipRates() {
        let rates = [tipRates.tipRate1, tipRates.tipRate2, tipRates.tipRate3]
        let validRates = rates.filter { $0 > 0 && $0 <= 100 }.sorted()
        tipRates = TipRatesModel(validRates)
        sdkService.customTipRates = validRates.isEmpty ? nil : validRates
    }
    
    // MARK: - Offline
    
    @Published var offlineStatus: OfflineStatusModel?
    
    var isStartOfflineButtonDisabled: Bool {
        offlineStatus?.isSessionActive ?? false
    }
    
    var isEndOfflineButtonDisabled: Bool {
        !(offlineStatus?.isSessionActive ?? false)
    }
    
    func checkOfflineSessionDetails() async {
        isOfflineBusy = true
        defer { isOfflineBusy = false }
        
        do {
            let details = try await sdkService.offlineSessionDetails()
            offlineStatus = .init(details)
        } catch {
            offlineStatus = nil
        }
    }
    
    func startOfflineSession() async {
        isOfflineBusy = true
        defer { isOfflineBusy = false }
        
        do {
            _ = try await sdkService.startOfflineSession()
            await checkOfflineSessionDetails()
        } catch {
            showError(error)
        }
    }
    
    func stopOfflineSession() async {
        isOfflineBusy = true
        defer { isOfflineBusy = false }
        
        do {
            _ = try await sdkService.endOfflineSession()
            await checkOfflineSessionDetails()
        } catch {
            showError(error)
        }
    }
    
    func checkOfflineUpdates() async {
        do {
            _ = try await sdkService.setupOfflineSession()
        } catch {
            showError(error)
        }
    }
    
    func uploadOfflineData() async {
        do {
            _ = try await sdkService.uploadOfflineSession()
        } catch {
            showError(error)
        }
    }
    
    // MARK: - Account
    
    var merchantCode: String {
        sessionState.merchantCode ?? ""
    }
    
    // MARK: - App Version
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
    }
    
    // MARK: - View Actions
    
    func logout() async {
        do {
            try await sdkService.logout()
        } catch {
            print("Error logging out: \(error)")
        }
    }
    

    
    // MARK: Other models
    
    /// Holds our tip rate settings for modification and easy portability.
    struct TipRatesModel {
        var tipRate1: Int
        var tipRate2: Int
        var tipRate3: Int
        
        var allRatesZero: Bool {
            tipRate1 == 0 && tipRate2 == 0 && tipRate3 == 0
        }
        
        /// Represents the default tip values provided by the SDK.
        /// Check ``SumUpSDK.customTipRates`` for more information.
        static var defaultValues: TipRatesModel {
            TipRatesModel(tipRate1: 10, tipRate2: 15, tipRate3: 20)
        }
    }
}

// MARK: Private Helper Extensions

fileprivate extension SettingsViewViewModel.TipRatesModel {
    init(_ tipRates: [Int]) {
        self.tipRate1 = tipRates.count > 0 ? tipRates[0] : 0
        self.tipRate2 = tipRates.count > 1 ? tipRates[1] : 0
        self.tipRate3 = tipRates.count > 2 ? tipRates[2] : 0
    }
}

fileprivate extension Int {
    var stringOrEmptyIfZero: String {
        self == 0 ? "" : String(self)
    }
}

fileprivate extension String {
    var intOrZero: Int {
        Int(self) ?? 0
    }
}
