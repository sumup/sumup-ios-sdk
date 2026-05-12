# `Sources/` - Quick Start

This project is designed to supply you with a quick and meaningful start to using the SumUp SDK. The best way to understand SDK usage is to see it in action. 

##  Files

Inside of this directory are all of the files you'll want to have a look at. Each one contains a documentation header with links to specific tasks we perform using the SDK directly. Files listed below with a 🔎 contain SDK calls. You may consider clicking into these first.

### `SumUpSDKSampleApp.swift`
The SwiftUI root `App` which sets up the environment and session state. It contains a reference to our `AppDelegate` where SDK setup is performed, and injects the SDK service into the environment for use throughout the app.


### `AppDelegate.swift` 🔎
This is where we make the `setup(affiliateKey:)` call to start the SDK upon application start.


### `SumUpSDKService.swift` 🔎
Protocol abstraction for the SumUp SDK's static interface, enabling dependency injection and mocking for previews and tests. Contains both the live implementation (`LiveSumUpSDKService`) and preview implementation (`PreviewSumUpSDKService`).


### `RootContentView.swift` 🔎
The root container view that manages login/logout transitions based on session state. Presents the SDK login screen and hosts all modal presentation driven by the `AppCoordinator`.


### `AppCoordinator.swift`
Centralizes navigation state and modal presentation. Owns the view model factories for `MainView` and `SettingsView`, wiring up dependencies and coordinating the process-as dialog flow during checkout.


### `MainView.swift`
Feature-level application UI for logged-in users containing a number entry pad, charge button and access to both reader settings (SDK-provided) and application settings screens. No SDK calls live here.


### `MainViewViewModel.swift` 🔎
The view model for our `MainView`, this file calls through to the SDK on behalf of it. It is also additionally responsible for the feature state on this screen. Look here for `presentCardReaderSettings()` and `charge()`, which delegates to `CheckoutFlow` for the full checkout lifecycle.


### `CheckoutFlow.swift` 🔎
Manages the checkout lifecycle: amount validation, optional process-as (credit/debit) selection, SDK checkout execution, and result handling. Called by `MainViewViewModel` during `charge()`.


### `SettingsView.swift`
Feature-level application UI for logged in users that provides access to SDK options and the logout functionality. No SDK calls live here.


### `SettingsViewViewModel.swift` 🔎
Calls the SDK on behalf of settings and models the state of those settings. Look here for information about specific feature settings including Tipping, Offline, Installments and toggling Success screens.
 

## Other Files

Inside of the following directories are files and code you will likely not need, but support the Sample App's functionality.

### `ApplicationSupport/`
Here you will find extensions and helpers that may be referenced elsewhere in the project, including:
- `AlertStateManaging.swift` - Shared alert-presentation protocol for view models
- `AppModal.swift` - Modal presentation types and type-erased wrapper
- `BrandTypography.swift` - Dynamic Type compatible font definitions
- `HostViewControllerProvider.swift` - UIKit hosting support for SDK presentation
- `NumpadMathProvider.swift` - Number pad entry logic
- `OfflineStatusModel.swift` - Local representation of SDK offline session details
- `SDKHelpers.swift` - SDK type extensions
- `SessionState.swift` - Observable login state management


### `SupportingViews/`
All of the compositional views that form the UI and exist at a sub-feature level:
- `AmountEntryView.swift` - Currency amount display
- `DemoStartView.swift` - Welcome/login screen
- `NumberKeypadView.swift` - Numeric input pad
- `OfflineModeStatBox.swift` - Stat box component for offline mode statistics
- `ProcessAsDialogView.swift` - Credit/debit process-as selection dialog
- `TopBarView.swift` - Reader status and settings access
