import SwiftUI

// MARK: - Modal Presentation

/// The SwiftUI presentation style used to display a modal.
enum ModalPresentationStyle {
    case sheet
    case fullScreenCover
}

/// A view that declares its preferred modal presentation style.
///
/// Conforming views provide a ``presentationStyle`` so the coordinator
/// can present them without hard-coding the style at the call site.
protocol ModalPresentable: View {
    static var presentationStyle: ModalPresentationStyle { get }
}

/// A type-erased modal that the coordinator can present.
///
/// Each instance carries its ``style`` (sheet vs full-screen cover) and
/// the view to display, wrapped in `AnyView`. An optional `onDismiss`
/// closure is invoked when the presentation ends — whether
/// programmatically or by a user gesture.
///
/// Because modals are leaf views that are created and destroyed wholesale
/// (not incrementally diffed), the `AnyView` type erasure has no
/// measurable performance impact.
struct ModalPresentation: Identifiable {
    let id = UUID()
    let style: ModalPresentationStyle
    let content: AnyView
    let onDismiss: (() -> Void)?

    /// Creates a presentation whose style is inferred from a ``ModalPresentable`` view.
    init<Content: ModalPresentable>(onDismiss: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.style = Content.presentationStyle
        self.onDismiss = onDismiss
        self.content = AnyView(content())
    }

    /// Creates a presentation with an explicit style for views that don't conform to ``ModalPresentable``.
    init(style: ModalPresentationStyle, onDismiss: (() -> Void)? = nil, @ViewBuilder content: () -> some View) {
        self.style = style
        self.onDismiss = onDismiss
        self.content = AnyView(content())
    }
}

// MARK: - View Modifier

/// Presents a ``ModalPresentation`` using the style declared by the modal itself.
///
/// Internally attaches both `.fullScreenCover(item:)` and `.sheet(item:)`
/// to the modified view, each with a filtered binding that is non-nil only
/// when the modal's style matches. This lets callers present any modal
/// with a single modifier instead of managing two separate bindings.
///
/// `onDismiss` is **not** forwarded to the SwiftUI modifier parameters.
/// Interactive dismissal (e.g. swipe-down on a sheet) sets the binding to
/// `nil`, which flows through the coordinator's ``dismissModal()`` and
/// fires the `onDismiss` closure once.
struct ModalPresentationModifier: ViewModifier {
    @Binding var item: ModalPresentation?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: fullScreenBinding) { $0.content }
            .sheet(item: sheetBinding) { $0.content }
    }

    private var fullScreenBinding: Binding<ModalPresentation?> {
        Binding(
            get: { item?.style == .fullScreenCover ? item : nil },
            set: { if $0 == nil { item = nil } }
        )
    }

    private var sheetBinding: Binding<ModalPresentation?> {
        Binding(
            get: { item?.style == .sheet ? item : nil },
            set: { if $0 == nil { item = nil } }
        )
    }
}

extension View {
    /// Presents a modal using the style carried by the ``ModalPresentation``.
    func modalPresentation(item: Binding<ModalPresentation?>) -> some View {
        modifier(ModalPresentationModifier(item: item))
    }
}
