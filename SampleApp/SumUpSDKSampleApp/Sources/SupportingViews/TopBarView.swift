import SwiftUI

struct TopBarView: View {
    enum Constants {
        static let readerButtonCornerRadius: CGFloat = 24
    }
    
    enum ReaderStatusDisplay {
        case disconnected
        case connected
        
        var displayColor: Color {
            switch self {
            case .disconnected:
                    .violet
            case .connected:
                    .green
            }
        }
    }
    
    var merchantCode: String
    var readerStatusDisplay: ReaderStatusDisplay = .disconnected
    var readerName: String?
    var showsOfflineButton: Bool = false
    
    var didTapReaderButton: (() -> Void) = {}
    var didTapSettingsButton: (() -> Void) = {}
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(merchantCode)
                    .font(.brandHeadlineBold)
                    .foregroundStyle(.lightSand)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Demo App")
                    .font(.brandFootnote)
                    .foregroundStyle(.darkSand)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 8)
            Button(action: didTapReaderButton) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 8, height: 8)
                    .tint(readerStatusDisplay.displayColor)
                
                Text(readerName ?? "No reader")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(.lightSand)
            }
            .padding([.leading, .trailing], 16)
            .topBarButtonStyle()
            .layoutPriority(1)
            offlineButtonIfNeeded()
            Spacer()
                .frame(width: 16)
            Button(action: didTapSettingsButton) {
                Image(systemName: "gearshape")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.lightBlue)
            }
        }
        .padding([.leading, .trailing], 18)
        .frame(height: 70)
        .background(.sparkBlue)
        .overlay(alignment: .bottom) {
            Color.lightBlue
                .frame(height: 1)
        }
    }
    
    @ViewBuilder
    private func offlineButtonIfNeeded() -> some View {
        if showsOfflineButton {
            Button(action: didTapSettingsButton) {
                Image(systemName: "wifi")
                    .foregroundStyle(.darkSand)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .black ))
                            .foregroundStyle(.lightBlue)
                            .offset(x: -2, y: 2)
                    }
            }
            .padding([.leading, .trailing], 12)
            .topBarButtonStyle()
        }
    }
}

// MARK: - Reader Button Style

fileprivate struct TopBarButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 39)
            .buttonStyle(.borderless)
            .tint(.lightBlue)
            .background(.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: TopBarView.Constants.readerButtonCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: TopBarView.Constants.readerButtonCornerRadius)
                    .stroke(.buttonBorder, lineWidth: 2)
            )
    }
}

fileprivate extension View {
    func topBarButtonStyle() -> some View {
        modifier(TopBarButtonStyle())
    }
}

// MARK: Preview

#Preview {
    TopBarView(
        merchantCode: "M0057643",
        readerStatusDisplay: .connected,
        readerName: "Solo",
        showsOfflineButton: true
    )
}
