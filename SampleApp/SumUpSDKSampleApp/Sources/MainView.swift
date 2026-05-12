import SwiftUI

/**
 Our main application view once we're logged in. This houses a top bar, an amount display, an amount entry
 keypad and a Charge button to begin a checkout process.
 
 The top bar contains reader status, offline status and access to the settings.
 
 No code that directly calls the SumUp SDK lives here. This view calls its view model based on user interaction.
 Check ``MainViewViewModel`` to learn how to call the SDK in response to these interactions.
 */
struct MainView: View {
    enum Constants {
        static let primaryElementSpacing: CGFloat = 24
        static let edgePadding: CGFloat = 24
    }

    @StateObject var viewModel: MainViewViewModel

    // MARK: Body
    
    var body: some View {
        VStack(spacing: 0) {
            TopBarView(
                merchantCode: viewModel.merchantCode,
                readerStatusDisplay: viewModel.readerStatus?.topBarReaderStatus ?? .disconnected,
                readerName: viewModel.readerStatus?.readerType.displayName,
                showsOfflineButton: viewModel.showOfflineButton,
                didTapReaderButton: presentCardReaderSettings,
                didTapSettingsButton: { viewModel.onRequestSettings() }
            )
            .layoutPriority(5)
            
            Spacer()
                .frame(height: Constants.primaryElementSpacing)
                .layoutPriority(-4)
            
            Spacer()
                .layoutPriority(-5)
            
            AmountEntryView(
                currencyCode: viewModel.merchantCurrencyCode,
                amount: $viewModel.paymentAmount)
                .padding([.leading, .trailing], Constants.edgePadding)
                .layoutPriority(2)
            
            Spacer()
                .layoutPriority(-5)
            
            Spacer()
                .frame(height: Constants.primaryElementSpacing)
                .layoutPriority(-4)
            
            NumberKeypadView { key in
                switch key {
                case let .value(number):
                    viewModel.addNumberToAmount(number)
                case .decimalSeparator:
                    viewModel.insertDecimalPoint()
                case .backspace:
                    viewModel.backspacePaymentAmount()
                }
            }
            .padding([.leading, .trailing], Constants.edgePadding)
            .layoutPriority(10)
            
            Spacer()
                .frame(height: Constants.primaryElementSpacing)
            
            chargeButton()
                .padding([.leading, .trailing], Constants.edgePadding)

            Spacer()
                .frame(height: Constants.primaryElementSpacing)
                .layoutPriority(-4)
        }
        .background(.sparkBlue)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alertPresenting(viewModel)
        .onAppear {
            Task {
                await viewModel.onViewAppear()
            }
        }
    }
    
    // MARK: View Helpers
    
    func chargeButton() -> some View {
        let paymentAmount = $viewModel.paymentAmount.wrappedValue
        let disabled = paymentAmount.isZero
        
        return Button(action: didTapCharge) {
            Text(disabled ? "Enter Amount" : "Charge")
                .font(.brandHeadline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.violet)
                .background(.lightSand)
        }
        .buttonStyle(.borderless)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1.0)
    }
    
    // MARK: Actions
    
    func presentCardReaderSettings() {
        Task {
            await viewModel.presentCardReaderSettings()
        }
    }
    
    func didTapCharge() {
        Task {
            await viewModel.charge()
        }
    }
}

// MARK: Preview

#Preview {
    let service = PreviewSumUpSDKService()
    MainView(viewModel: .init(
        sessionState: .previewInstance(),
        sdkService: service,
        checkoutFlow: CheckoutFlow(sdkService: service)
    ))
}
