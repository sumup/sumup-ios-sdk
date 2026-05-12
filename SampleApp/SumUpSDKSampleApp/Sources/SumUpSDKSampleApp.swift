import SwiftUI

/**
 SwiftUI Application definition for our SDK Sample App.
 
 The key functionality of managing transitions between logged-in and logged-out state is handled
 by ``RootContentView``. Navigation presentation (sheets, alerts) is coordinated by ``AppCoordinator``.
 */
@main
struct SumUpSDKSampleApp: App {
    /// Contains SumUp SDK setup calls.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var coordinator = AppCoordinator(
        sessionState: SessionState(),
        sdkService: LiveSumUpSDKService.shared
    )
    
    var body: some Scene {
        WindowGroup {
            RootContentView(coordinator: coordinator)
                .environment(\.sdkService, LiveSumUpSDKService.shared)
        }
    }
}

// MARK: - SwiftUI EnvironmentKey for the SDK service

private struct SDKServiceKey: EnvironmentKey {
    static var defaultValue: any SumUpSDKService { LiveSumUpSDKService.shared }
}

extension EnvironmentValues {
    var sdkService: any SumUpSDKService {
        get { self[SDKServiceKey.self] }
        set { self[SDKServiceKey.self] = newValue }
    }
}
