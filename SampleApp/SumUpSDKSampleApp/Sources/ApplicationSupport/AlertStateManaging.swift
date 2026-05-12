import SwiftUI

// MARK: - Alert Model

/// A lightweight model for alerts presented by any ``AlertStateManaging`` conforming type.
struct AlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    var onDismiss: (() -> Void)?
}

// MARK: - Protocol

/// Provides a shared alert-presentation API for observable objects.
///
/// Conforming types must declare `@Published var alertState: AlertState?` so
/// that SwiftUI views can observe changes.  The protocol extensions supply
/// default `showError` and `dismissAlert` implementations.
@MainActor
protocol AlertStateManaging: ObservableObject {
    var alertState: AlertState? { get set }
}

extension AlertStateManaging {
    func showError(title: String = "Error", message: String, onDismiss: (() -> Void)? = nil) {
        alertState = AlertState(title: title, message: message, onDismiss: onDismiss)
    }

    func showError(_ error: Error) {
        showError(message: error.localizedDescription)
    }

    func showError(_ error: LocalizedError) {
        showError(message: error.errorDescription ?? "Unknown")
    }

    func dismissAlert() {
        let action = alertState?.onDismiss
        alertState = nil
        action?()
    }
}

// MARK: - View Modifier

/// Presents an alert driven by any ``AlertStateManaging`` object.
///
/// Attach via the ``SwiftUICore/View/alertPresenting(_:)`` convenience.
struct AlertModifier<Manager: AlertStateManaging>: ViewModifier {
    @ObservedObject var alertStateManager: Manager

    func body(content: Content) -> some View {
        content
            .alert(
                alertStateManager.alertState?.title ?? "Error",
                isPresented: alertIsPresented,
                actions: {
                    Button("OK") {
                        alertStateManager.dismissAlert()
                    }
                },
                message: {
                    Text(alertStateManager.alertState?.message ?? "")
                }
            )
    }

    private var alertIsPresented: Binding<Bool> {
        Binding(
            get: { alertStateManager.alertState != nil },
            set: { isPresented in
                if !isPresented { alertStateManager.dismissAlert() }
            }
        )
    }
}

extension View {
    /// Attaches an alert driven by the given ``AlertStateManaging`` object.
    func alertPresenting<Manager: AlertStateManaging>(_ alertStateManager: Manager) -> some View {
        modifier(AlertModifier(alertStateManager: alertStateManager))
    }
}
