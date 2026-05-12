import SwiftUI

/// A stat box displaying an icon, value, and label for offline mode statistics.
struct OfflineModeStatBox<Content: View>: View {
    let systemName: String
    let label: String
    let content: () -> Content
    
    init(systemName: String, label: String, @ViewBuilder content: @escaping () -> Content) {
        self.systemName = systemName
        self.label = label
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .foregroundStyle(.subText)
            content()
            Text(label)
                .font(.brandCallout)
                .foregroundStyle(.subText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .background(.lightSand)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - String Value

/// A stat box displaying a string value.
struct OfflineModeStatBoxString: View {
    let systemName: String
    let value: String
    let label: String
    
    var body: some View {
        OfflineModeStatBox(systemName: systemName, label: label) {
            Text(value)
                .font(.brandHeadline)
                .foregroundStyle(.darkBlue)
        }
    }
}

// MARK: - Countdown Timer

/// A stat box displaying a countdown timer to a target date that stops at zero.
struct OfflineModeStatBoxCountdown: View {
    let systemName: String
    let targetDate: Date
    let label: String
    
    @State private var timeRemaining: TimeInterval = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var displayDate: Date {
        Date(timeIntervalSinceNow: timeRemaining)
    }
    
    var body: some View {
        OfflineModeStatBox(systemName: systemName, label: label) {
            Text(timerInterval: Date()...displayDate, countsDown: true)
                .font(.brandHeadline)
                .foregroundStyle(.darkBlue)
        }
        .onAppear {
            timeRemaining = max(0, targetDate.timeIntervalSinceNow)
        }
        .onReceive(timer) { _ in
            timeRemaining = max(0, targetDate.timeIntervalSinceNow)
        }
    }
}

// MARK: - Previews

#Preview("String Value") {
    HStack {
        OfflineModeStatBoxString(
            systemName: "wallet.pass",
            value: "0/75",
            label: "Transactions"
        )
        OfflineModeStatBoxCountdown(
            systemName: "clock",
            targetDate: Date().addingTimeInterval(180),
            label: "Time left"
        )
    }
    .padding()
    .background(Color.white)
}
