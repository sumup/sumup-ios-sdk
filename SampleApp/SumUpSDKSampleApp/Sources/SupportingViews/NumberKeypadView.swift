import SwiftUI

struct NumberKeypadView: View {
    
    enum Constants {
        static let keypadButtonAspect: CGFloat = 107/80
        static let keypadButtonCornerRadius: CGFloat = 16
        static let buttonSpacing: CGFloat = 16
        static let heightRatio: CGFloat = 80 * 4 + buttonSpacing * 3
        static let widthRatio: CGFloat = 107 * 3 + buttonSpacing * 2
        static let aspectRatio: CGFloat = widthRatio / heightRatio
    }
    
    enum KeypadAction: Hashable {
        case value(_ value: UInt8)
        case decimalSeparator
        case backspace
        
        var displayValue: String {
            switch self {
                case .value(let value):
                return String(value)
            case .decimalSeparator:
                return Locale.autoupdatingCurrent.decimalSeparator ?? "."
            case .backspace:
                return "⌫"
            }
        }
    }
    
    var onKeyPress: ((KeypadAction) -> Void)?
    
    private let rows: [[KeypadAction]] = [
        [.value(1), .value(2), .value(3)],
        [.value(4), .value(5), .value(6)],
        [.value(7), .value(8), .value(9)],
        [.decimalSeparator, .value(0), .backspace]
    ]
    
    var body: some View {
        VStack(spacing: Constants.buttonSpacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: Constants.buttonSpacing) {
                    ForEach(row, id: \.self) { key in
                        keypadButtonForKey(key)
                    }
                }
            }
        }
        .aspectRatio(Constants.aspectRatio, contentMode: .fit)
        .layoutPriority(5)
    }
    
    private func keypadButtonForKey(_ key: KeypadAction) -> some View {
        Button(action: {
            withAnimation {
                onKeyPress?(key)
            }
        }) {
            Text(key.displayValue)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.borderless)
        .tint(.lightBlue)
        .background(.buttonBackground)
        .aspectRatio(Constants.keypadButtonAspect, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: Constants.keypadButtonCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.keypadButtonCornerRadius)
                .stroke(.buttonBorder, lineWidth: 2)
        )
    }
}

#Preview {
    ZStack {
        NumberKeypadView { key in
            print("Pressed: \(key)")
        }
    }
    .padding(16)
    .background(.sparkBlue)
}
