import SwiftUI
import XCTest
@testable import SumUpSDKSampleApp

@MainActor
final class AppCoordinatorTests: XCTestCase {

    private var mockSDKService: MockSumUpSDKService!
    private var sessionState: SessionState!
    private var sut: AppCoordinator!

    override func setUp() {
        super.setUp()
        mockSDKService = MockSumUpSDKService()
        sessionState = SessionState()
        sut = AppCoordinator(sessionState: sessionState, sdkService: mockSDKService)
    }

    override func tearDown() {
        sut = nil
        sessionState = nil
        mockSDKService = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Creates a modal with an optional `onDismiss` tracking closure.
    private func makeModal(onDismiss: (() -> Void)? = nil) -> ModalPresentation {
        ModalPresentation(style: .sheet, onDismiss: onDismiss) {
            Text("Test")
        }
    }

    // MARK: - dismissModal

    func test_dismissModal_clearsActiveModal() {
        sut.present(makeModal())
        XCTAssertNotNil(sut.activeModal)

        sut.dismissModal()

        XCTAssertNil(sut.activeModal)
    }

    func test_dismissModal_firesOnDismiss() {
        var onDismissCalled = false
        sut.present(makeModal(onDismiss: { onDismissCalled = true }))

        sut.dismissModal()

        XCTAssertTrue(onDismissCalled)
    }

    // MARK: - notifyLogout

    func test_notifyLogout_clearsActiveModal() {
        sut.present(makeModal())
        XCTAssertNotNil(sut.activeModal)

        sut.notifyLogout()

        XCTAssertNil(sut.activeModal)
    }

    func test_notifyLogout_doesNotFireOnDismiss() {
        var onDismissCalled = false
        sut.present(makeModal(onDismiss: { onDismissCalled = true }))

        sut.notifyLogout()

        XCTAssertFalse(onDismissCalled)
    }
}
