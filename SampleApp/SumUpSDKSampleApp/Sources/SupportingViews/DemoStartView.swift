import SwiftUI

/// Visual introduction screen with a button to start login.
/// The action is provided externally, so no SDK-interacting code lives here.
struct DemoStartView: View {
    enum Constants {
        static let mainPadding: CGFloat = 24
        static let topPadding: CGFloat = 34
    }
    
    var loginAction: (() -> Void) = {}
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(edges: .all)
            backgroundGradient()
            VStack(alignment: .leading) {
                Image("SumUpLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 127, height: 32)
                    .layoutPriority(5)
                Spacer().layoutPriority(-1)
                Text("Demo App for SumUp Card Reader Integrators")
                    .font(.brandHero)
                    .foregroundStyle(.lightSand)
                    .layoutPriority(1)
                Spacer(minLength: 32).layoutPriority(-2)
                startButton()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .trailing, .bottom], Constants.mainPadding)
            .padding([.top], Constants.topPadding)
        }
    }
    
    func startButton() -> some View {
        Button(action: loginAction) {
            Text("Start")
                .font(.brandHeadline)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.violet)
                .background(.lightSand)
        }
        .buttonStyle(.borderless)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    func backgroundGradient() -> some View {
        let colors = [
            Color.sparkBlue,
            Color.sparkBlue.opacity(0.8)
        ]
        
        return LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom)
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    DemoStartView()
}
