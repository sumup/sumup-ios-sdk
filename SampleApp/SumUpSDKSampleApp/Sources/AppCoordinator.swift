import SwiftUI

/// Centralizes navigation state (modals) for the app.
///
/// The coordinator owns a single ``activeModal`` (a ``ModalPresentation``)
/// that carries the view to display and its preferred presentation style.
/// Callers construct the modal content via ``present(_:)`` or the
/// convenience `show*` methods — `RootContentView` presents it generically.
///
/// Alert presentation is handled locally by each view model via the
/// ``AlertStateManaging`` protocol — the coordinator is not involved.
@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: Published Navigation State

    @Published var activeModal: ModalPresentation?

    // MARK: Dependencies

    let sessionState: SessionState
    private let sdkService: any SumUpSDKService

    init(sessionState: SessionState, sdkService: any SumUpSDKService) {
        self.sessionState = sessionState
        self.sdkService = sdkService
    }

    // MARK: Generic Presentation

    func present(_ modal: ModalPresentation) {
        activeModal = modal
    }

    func dismissModal() {
        let onDismiss = activeModal?.onDismiss
        activeModal = nil
        onDismiss?()
    }

    // MARK: Presentation Binding

    /// Binding that drives the ``modalPresentation(item:)`` modifier.
    /// Setting to `nil` calls ``dismissModal()`` so the `onDismiss` closure fires.
    var modalBinding: Binding<ModalPresentation?> {
        Binding(
            get: { [weak self] in self?.activeModal },
            set: { [weak self] newValue in
                if newValue == nil { self?.dismissModal() }
            }
        )
    }

    // MARK: Convenience Presenters

    func showSettings(onDismiss: @escaping () -> Void) {
        let viewModel = makeSettingsViewViewModel()
        let modal = ModalPresentation(onDismiss: onDismiss) { [weak self] in
            SettingsView(
                viewModel: viewModel,
                didTapClose: { self?.dismissModal() }
            )
        }
        present(modal)
    }

    // MARK: View Model Factories

    func makeMainViewViewModel() -> MainViewViewModel {
        let processAsProvider: CheckoutFlow.ProcessAsProvider = { [weak self] in
            await self?.requestProcessAsSelection()
        }

        let checkoutFlow = CheckoutFlow(sdkService: sdkService, processAsProvider: processAsProvider)
        let viewModel = MainViewViewModel(
            sessionState: sessionState,
            sdkService: sdkService,
            checkoutFlow: checkoutFlow
        )

        viewModel.onRequestSettings = { [weak self, weak viewModel] in
            self?.showSettings(onDismiss: {
                Task { await viewModel?.onSettingsClose() }
            })
        }

        return viewModel
    }

    func makeSettingsViewViewModel() -> SettingsViewViewModel {
        SettingsViewViewModel(sessionState: sessionState, sdkService: sdkService)
    }

    // MARK: Private — Process-As Bridge

    /// Bridges the process-as sheet into an async call using a checked continuation.
    /// Returns the user's selection, or `nil` if they cancel.
    private func requestProcessAsSelection() async -> CheckoutFlow.ProcessAsSelection? {
        await withCheckedContinuation { continuation in
            // Guards against double-resume: the confirm/cancel buttons call
            // `dismissModal()` which fires `onDismiss` — without this flag the
            // continuation would be resumed twice. Safe without locking because
            // all paths run on `@MainActor`.
            var resumed = false

            let modal = ModalPresentation(onDismiss: {
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: nil)
            }) {
                ProcessAsDialogView(
                    onConfirm: { [weak self] processAs, installments in
                        guard !resumed else { return }
                        resumed = true
                        self?.dismissModal()
                        continuation.resume(returning: CheckoutFlow.ProcessAsSelection(
                            processAs: processAs,
                            installments: installments
                        ))
                    },
                    onCancel: { [weak self] in
                        guard !resumed else { return }
                        resumed = true
                        self?.dismissModal()
                        continuation.resume(returning: nil)
                    }
                )
            }
            present(modal)
        }
    }
    
    // MARK: Logout
    
    /// Gracefully tear down any presentation to prepare for logout.
    func notifyLogout() {
        activeModal = nil
    }
}
