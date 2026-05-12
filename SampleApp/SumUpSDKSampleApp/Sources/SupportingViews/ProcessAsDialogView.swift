import SwiftUI

/// A dialog presented before checkout when the merchant's market requires
/// the customer to choose between Credit and Debit processing.
/// When Credit is selected, a grid allows choosing the number of installments (1–12).
struct ProcessAsDialogView: View {
    typealias ProcessAs = SumUpSDKCheckoutProcessAs
    let onConfirm: (ProcessAs, Int) -> Void
    let onCancel: () -> Void

    @State private var selectedProcessAs: ProcessAs = .debit
    @State private var selectedInstallments: Int = 1
    @State private var contentHeight: CGFloat = 1.0

    private let installmentRange = Array(1...12)
    private let gridColumns = Array(
        repeating: GridItem(.flexible(minimum: 44), spacing: 8),
        count: 4
    )

    var body: some View {
        VStack(spacing: 24) {
            header()
            processAsToggle()

            if selectedProcessAs == .credit {
                installmentsSection()
            }

            confirmButton()
        }
        .padding(24)
        .background(.lightSand)
        .overlay(
            GeometryReader { geo in
                Color.clear.preference(key: ContentHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(ContentHeightKey.self) { newHeight in
            contentHeight = max(1.0, newHeight)
        }
        .presentationDetents([.height(contentHeight)])
    }

    // MARK: - Subviews

    private func header() -> some View {
        HStack {
            Text("Payment method")
                .font(.brandHeadlineBold)
                .foregroundStyle(.darkBlue)

            Spacer()

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.brandCalloutMedium)
                    .foregroundStyle(.darkBlue)
            }
            .accessibilityLabel("Close")
        }
    }

    private func processAsToggle() -> some View {
        HStack(spacing: 0) {
            processAsTab(.debit, label: "Debit")
            processAsTab(.credit, label: "Credit")
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkSand)
        )
    }

    private func processAsTab(_ processAs: ProcessAs, label: String) -> some View {
        let isSelected = selectedProcessAs == processAs
        return Button {
            selectedProcessAs = processAs
        } label: {
            Text(label)
                .font(.brandHeadline)
                .foregroundStyle(isSelected ? .sparkBlue : .darkBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func installmentsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Installments")
                .font(.brandSubheadline)
                .foregroundStyle(.darkBlue)

            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(installmentRange, id: \.self) { count in
                    installmentButton(count)
                }
            }
        }
    }

    private func installmentButton(_ count: Int) -> some View {
        let isSelected = selectedInstallments == count
        return Button {
            selectedInstallments = count
        } label: {
            Text("\(count)")
                .font(.brandCalloutMedium)
                .foregroundStyle(isSelected ? .lightSand : .darkBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.sparkBlue : .white)
                )
                .overlay(
                    Group {
                        if !isSelected {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.buttonBorder, lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func confirmButton() -> some View {
        Button(action: didTapConfirm) {
            Text("Confirm")
                .font(.brandHeadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.lightSand)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.violet)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func didTapConfirm() {
        let installments = selectedProcessAs == .credit ? selectedInstallments : 0
        onConfirm(selectedProcessAs, installments)
    }
}

// MARK: - ModalPresentable

extension ProcessAsDialogView: ModalPresentable {
    static var presentationStyle: ModalPresentationStyle { .sheet }
}

// MARK: - Content Height Measurement

private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#Preview {
    ProcessAsDialogView(
        onConfirm: { processAs, installments in
            print("Confirmed: \(processAs), installments: \(installments)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
