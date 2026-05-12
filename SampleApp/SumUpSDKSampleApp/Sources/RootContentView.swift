import SwiftUI

/**
 Manages the root view based on our login session state. Can present the SumUp SDK
 login screen. To aid clarity, this single SDK call is done from this view.

 Navigation modals (settings, process-as dialog) are driven by the
 ``AppCoordinator``'s published ``ModalPresentation`` state. Each modal
 carries its own view and preferred presentation style (sheet vs full-screen
 cover), so this view presents them generically without any knowledge of
 specific modal types.

 Error alerts are handled locally by each view via the
 ``AlertStateManaging`` protocol on their view models.

 # SumUp SDK Interaction
 Jump straight to the methods that call the SDK.

 ## Present Login
 Present the login screen modally.

 ``RootContentView/presentLogin()``
 */
struct RootContentView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject private var sessionState: SessionState
    @Environment(\.sdkService) private var sdkService

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.sessionState = coordinator.sessionState
    }

    var body: some View {
        Group {
            if sessionState.isLoggedIn {
                mainView()
            } else {
                startView()
            }
        }
        .background(HostViewControllerProvider())
        .onReceive(sdkService.sessionEventPublisher) { event in
            withAnimation {
                if case .loggedOut = event {
                    coordinator.notifyLogout()
                }
                sessionState.update(with: sdkService)
            }
        }
        .modalPresentation(item: coordinator.modalBinding)
    }

    // MARK: - Child Views

    func startView() -> some View {
        DemoStartView(loginAction: presentLogin)
            .transition(.opacity)
    }

    func mainView() -> some View {
        MainView(viewModel: coordinator.makeMainViewViewModel())
            .transition(.opacity)
    }

    /// Presents the SumUp SDK login screen modally using the resolved hosting view controller.
    func presentLogin() {
        Task {
            do {
                try await sdkService.presentLogin()
            } catch {
                // The presented login screen will handle errors visually
                print("Failed to login: \(error)")
            }
        }
    }
}
