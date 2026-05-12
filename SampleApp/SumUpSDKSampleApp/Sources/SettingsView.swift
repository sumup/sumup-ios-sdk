import SwiftUI

/**
 The Settings screen accessed from the ``MainView`` which provides access to various SDK options.
 
 Direct interactions with the SumUp SDK don't live in this file. You can see these in ``SettingsViewViewModel``.
 */
struct SettingsView: View {
    enum Constants {
        static let leadingTrailingPadding: CGFloat = 24
        static let sectionInternalItemSpacing: CGFloat = 16
    }
    
    @StateObject var viewModel: SettingsViewViewModel
    
    var didTapClose: () -> Void = {}
    
    @FocusState private var isTipFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            topBar()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    tippingSection()
                    
                    offlineModeSection()
                    
                    tapToPaySection()
                    
                    developmentOptionsSection()
                    
                    accountSection()
                    
                    Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                        .font(.brandCaption)
                        .foregroundStyle(.subText)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(.lightSand, ignoresSafeAreaEdges: .all)
        .alertPresenting(viewModel)
    }
    
    func topBar() -> some View {
        HStack {
            Text("Settings")
                .font(.brandTitle)
            
            Spacer()
            
            Button(action: didTapClose) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .fixedSize()
            }
        }
        .padding([.leading, .trailing], Constants.leadingTrailingPadding)
        .frame(height: 70)
        .foregroundStyle(.sparkBlue)
    }
    
    // MARK: - Section Definitions
    
    // MARK: Tap to Pay
    
    func tapToPaySection() -> some View {
        settingsSection(title: "Tap To Pay", imageSystemName: "wave.3.right") {
            settingsToggle(
                isOn: $viewModel.tapToPayEnabled,
                title: "Tap to Pay",
                subtitle: "Take payments using your phone"
            ).disabled(true)
        }
    }
    
    // MARK: Tipping
    
    func tippingSection() -> some View {
        settingsSection(title: "Tipping", imageSystemName: "banknote") {
            settingsToggle(
                isOn: $viewModel.tippingEnabled.animation(.easeInOut),
                title: "Tipping",
                subtitle: "Allow customers to add tips"
            )
            .disabled(!viewModel.isTipOnCardReaderAvailable)
            
            if !viewModel.isTipOnCardReaderAvailable {
                Text("On-reader tipping is not available using the connected reader")
                    .font(.brandFootnote)
                    .foregroundStyle(.danger)
            }
            
            if viewModel.tippingEnabled {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Default tip options")
                        .font(.brandSubheadline)
                        .foregroundStyle(.darkBlue)
                    
                    HStack(spacing: 12) {
                        tipPercentageField(
                            value: viewModel.tipOption1,
                            placeholder: viewModel.tipPlaceholder1
                        )
                        tipPercentageField(
                            value: viewModel.tipOption2,
                            placeholder: viewModel.tipPlaceholder2
                        )
                        tipPercentageField(
                            value: viewModel.tipOption3,
                            placeholder: viewModel.tipPlaceholder3
                        )
                    }
                }
                .animation(.easeInOut, value: viewModel.tippingEnabled)
            }
        }
    }
    
    // MARK: Offline Mode
    
    func offlineModeSection() -> some View {
        settingsSection(title: "Offline Mode", imageSystemName: "wifi.slash") {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Offline Transactions")
                            .font(.brandHeadline)
                            .foregroundStyle(.darkBlue)
                        Text("Start an offline session when needed and end the session to process the transactions")
                            .font(.brandFootnote)
                            .foregroundStyle(.subText)
                    }
                    
                    Spacer()
                    ProgressView()
                        .opacity(viewModel.isOfflineBusy ? 1 : 0)
                }
                offlineModeDetailsContent()
                offlineModeButtonContent()
            }
            .disabled(viewModel.isOfflineBusy)
            .opacity(viewModel.isOfflineBusy ? 0.7 : 1)
        }
        .animation(.easeInOut, value: viewModel.offlineStatus)
        .task {
            await viewModel.checkOfflineSessionDetails()
        }
    }
    
    func offlineModeButtonContent() -> some View {
        let isActive = viewModel.offlineStatus?.isSessionActive ?? false
        
        return VStack(spacing: 16) {
            if isActive {
                offlineModeFilledButton(title: "End session", systemName: "stop.fill") {
                    Task {
                        await viewModel.stopOfflineSession()
                    }
                }
            } else {
                offlineModeFilledButton(title: "Start", systemName: "play.fill") {
                    Task {
                        await viewModel.startOfflineSession()
                    }
                }
                
                Divider()
                
                offlineModeButton(title: "Upload transactions", systemName: "arrow.up.circle") {
                    Task {
                        await viewModel.uploadOfflineData()
                    }
                }
                offlineModeButton(title: "Check for Updates", systemName: "shield") {
                    Task {
                        await viewModel.checkOfflineUpdates()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func offlineModeDetailsContent() -> some View {
        if let offlineStatus = viewModel.offlineStatus, offlineStatus.isSessionActive {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                    Text("Offline session active")
                        .font(.brandCalloutMedium)
                        .foregroundStyle(.sparkBlue)
                }
                
                HStack(alignment: .top, spacing: 8) {
                    OfflineModeStatBoxCountdown(
                        systemName: "clock",
                        targetDate: offlineStatus.endDate,
                        label: "Time left"
                    )
                    OfflineModeStatBoxString(
                        systemName: "wallet.pass",
                        value: String(offlineStatus.approvedTransactionsCount),
                        label: "Transactions"
                    )
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    func offlineModeButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemName)
                Text(title)
                    .font(.brandCalloutMedium)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.violet)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.violet, lineWidth: 2)
        )
    }
    
    func offlineModeFilledButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemName)
                Text(title)
                    .font(.brandCalloutMedium)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(.lightSand)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.violet)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Development Options
    
    func developmentOptionsSection() -> some View {
        settingsSection(title: "Development Options", imageSystemName: "chevron.left.forwardslash.chevron.right") {
            settingsToggle(
                isOn: .constant(viewModel.installmentsEnabled),
                title: "Installments",
                subtitle: "This feature is market-specific and cannot be manually enabled or disabled"
            )
            .disabled(true)
            
            Divider()
            
            settingsToggle(
                isOn: $viewModel.transactionSuccessEnabled,
                title: "Transaction Success",
                subtitle: "Display SumUp screen after a successful transaction"
            )
        }
    }
    
    // MARK: Account
    
    func accountSection() -> some View {
        settingsSection(title: "Account", imageSystemName: "person") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Demo App")
                    .font(.brandHeadline)
                    .foregroundStyle(.darkBlue)
                Text(viewModel.merchantCode)
                    .font(.brandFootnote)
                    .foregroundStyle(.subText)
            }
            Button(action: logout) {
                HStack {
                    Image(systemName: "arrow.right.square")
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text("Logout")
                        .font(.brandHeadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderless)
            .background(.sparkBlue)
            .foregroundStyle(.lightSand)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    // MARK: Section Builders
    
    func settingsSection(title: String, imageSystemName: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: Constants.sectionInternalItemSpacing) {
            sectionHeader(title: title, systemName: imageSystemName)
            
            VStack(alignment: .leading, spacing: Constants.sectionInternalItemSpacing, content: content)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding([.leading, .trailing], Constants.leadingTrailingPadding)
    }
    
    func sectionHeader(title: String, systemName: String) -> some View {
        HStack {
            Image(systemName: systemName)
            Text(title)
                .font(.brandSubheadlineBold)
                .textCase(.uppercase)
            Spacer()
        }
        .foregroundStyle(.sparkBlue)
    }
    
    func settingsToggle(isOn: Binding<Bool>, title: String, subtitle: String) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.brandHeadline)
                    .foregroundStyle(.darkBlue)
                Text(subtitle)
                    .font(.brandFootnote)
                    .foregroundStyle(.subText)
            }
        }
        .tint(.sparkBlue)
    }
    
    func tipPercentageField(value: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 4) {
            Text("+")
                .font(.brandCallout)
                .foregroundStyle(.subText)
            
            TextField("", text: value, prompt: Text(placeholder).foregroundColor(.subText))
                .font(.brandHeadline)
                .foregroundStyle(.darkBlue)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .focused($isTipFieldFocused)
                .onChange(of: isTipFieldFocused) { isFocused in
                    if !isFocused {
                        viewModel.commitTipRates()
                    }
                }
            
            Text("%")
                .font(.brandCallout)
                .foregroundStyle(.subText)
        }
        .padding(8)
        .background(.lightSand)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: Actions
    
    func logout() {
        Task {
            await viewModel.logout()
        }
    }
}

// MARK: - ModalPresentable

extension SettingsView: ModalPresentable {
    static var presentationStyle: ModalPresentationStyle { .fullScreenCover }
}

#Preview {
    let sessionState = SessionState.previewInstance()
    let sdkService = PreviewSumUpSDKService()
    SettingsView(
        viewModel: .init(sessionState: sessionState, sdkService: sdkService),
        didTapClose: {})
}
