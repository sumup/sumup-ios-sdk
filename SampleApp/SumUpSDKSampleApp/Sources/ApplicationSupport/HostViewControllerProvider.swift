import SwiftUI
import UIKit

/// Attach this as a background to the root `View` in your view hierarchy.
/// ```swift
/// .background(HostViewControllerProvider())
/// ```
/// This is needed because the SDK needs a way to obtain a host `UIViewController` from
/// which to present its own `UIViewControllers`.
struct HostViewControllerProvider: UIViewControllerRepresentable {

    private static var parentProvidingViewController: ParentProvidingViewController?

    static var hostViewController: UIViewController {
        get throws {
            guard let viewController = Self.parentProvidingViewController?.parent else {
                assertionFailure("Please ensure your root View has: .background(HostViewControllerProvider())")
                throw HostViewControllerProviderError.missingHostViewControllerProvider
            }
            return viewController
        }
    }

    func makeUIViewController(context: Context) -> ParentProvidingViewController {
        ParentProvidingViewController()
    }

    func updateUIViewController(_ parentProvidingViewController: ParentProvidingViewController, context: Context) {
        // Re-capture on every SwiftUI update in case the host has moved.
        DispatchQueue.main.async {
            Self.parentProvidingViewController = parentProvidingViewController
        }
    }

    /// A zero-size hosting controller whose sole purpose is to resolve its `parent`
    final class ParentProvidingViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.isHidden = true
            view.frame = .zero
        }
    }
}

enum HostViewControllerProviderError: Error {
    case missingHostViewControllerProvider
}
