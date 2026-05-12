import SwiftUI

struct AmountEntryView: View {
    @State var currencyCode: String
    @Binding var amount: Decimal
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                Text(amount,
                     format: .currency(code: currencyCode)
                    .presentation(.narrow)
                )
                .font(.brandAmountDisplay)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
            }
            .foregroundStyle(.lightSand)
            
            Text("Amount")
                .font(.brandCalloutMedium)
                .foregroundStyle(.lightBlue)
        }
    }
}

#Preview {
    ZStack(alignment: .center) {
        AmountEntryView(
            currencyCode: "DKK",
            amount: .constant(18500.00)
        )
        .background(.sparkBlue)
    }
}
