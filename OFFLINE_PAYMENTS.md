# Offline Payments

### Table of Contents

1. [Introduction](#introduction)
2. [API Reference](#api-reference)
3. [Lifecycle](#lifecycle)
    * [Offline Session Preparation](#offline-session-preparation)
    * [Offline Session Activation](#offline-session-activation)
    * [Offline Window](#offline-window)
    * [Reconciliation](#reconciliation)
4. [Minimum requirements](#minimum-requirements)
    * [iOS](#ios)
    * [Card Readers](#card-readers)
    * [Card Schemes](#card-schemes)
5. [Limitations](#limitations)
    * [Tap-to-Pay](#tap-to-pay)
    * [Atomic Operations](#atomic-operations)
    * [Online Prerequisite and Card Reader Serial Binding](#online-prerequisite-and-card-reader-serial-binding)
    * [Transaction Caps](#transaction-caps)
    * [Cumulative Limit](#cumulative-limit)
    * [Time Constraints](#time-constraints)
6. [Associated Risks](#associated-risks)
    * [Deferred Declines](#deferred-declines)
    * [Data Loss](#data-loss)
    * [Data Integrity and Tamper Detection](#data-integrity-and-tamper-detection)
    * [Date Tampering and Clock Synchronization](#date-tampering-and-clock-synchronization)
7. [Suggestions](#suggestions)
8. [Disclaimers](#disclaimers)
9. [Support](#support)

## Introduction
The Offline Payments functionality enables on-device transaction processing, allowing card payments to be provisionally processed independently of internet availability or network signal quality. By shifting the transaction logic to the device, the SDK ensures business continuity in environments where connectivity is absent or unreliable.

Use of this feature is entirely at the discretion of the integrator, who retains full operational control over the lifecycle of the offline session. The SDK does not automatically toggle between modes; instead, it operates based on the session state controlled by the host application.

Once a session is started, the SDK routes all transactions through local logic, validating them against security rules and limits stored on the device. This behavior remains deterministic: the SDK will process payments offline until the session is manually ended. Once the session is terminated, the system reverts to standard online-only processing.

> [!NOTE]
> The merchant bears full liability for all transactions which are provisionally accepted during the offline session, then later rejected once sent to the acquirer.

## API Reference
The following table summarizes the core methods available in the SDK to manage the offline workflow and monitor offline session states.

| Method                           | Description                                                                                      | Online Required |
|----------------------------------|--------------------------------------------------------------------------------------------------|:---------------:|
| `setupOfflineSession`            | Downloads security rules and spending limits from the gateway to configure the device.           |        🟢       |
| `startOfflineSession`            | Activates the offline session, allowing the SDK to begin approving transactions locally.         |        🔴       |
| `getOfflineSessionDetails`       | Returns the current offline session status, including transaction counts and approved volumes.   |        🔴       |
| `getOfflineSessionRemainingTime` | Returns the remaining time before the active offline session expires.                            |        🔴       |
| `uploadOfflineSession`           | Synchronizes stored transactions with the gateway to finalize payments.                          |        🔴       |
| `endOfflineSession`              | Terminates the offline session and restores standard online-only operations.                     |        🟠 (*)   |

> [!NOTE]
> `endOfflineSession`
> 
> (*) _If an internet connection is available when the method is called, the SDK will also attempt to synchronize any stored offline transaction(s). If unsuccessful, the SDK will fail silently._

## Lifecycle
The offline payment lifecycle consists of Preparation, Activation, the Offline Window, and Reconciliation.

### Offline Session Preparation
To enable local processing, the SDK must periodically synchronize security parameters and merchant configurations with the SumUp backend. This data retrieval occurs transparently in the background during the SDK's lifecycle and does not block operations. While the SDK handles this automatically, integrators can also manually trigger this synchronization.

> [!NOTE]
> This requires an active internet connection.

> [!TIP]
> Repeatedly calling `setupOfflineSession` is not recommended as the SDK manages the original setup and updates autonomously. Invoking it while an offline session is already active or expired will have no effect.

### Offline Session Activation
Once the session is prepared, the integrator has the discretion to initialize it at any moment.

> [!NOTE]
> This is a local operation and does not require internet connectivity. The host application can enable offline capabilities based on its own business logic or environmental assessment.

### Offline Window
During an active offline session, the checkout routing is strictly governed by the session's state. This process is seamless: the transaction is validated against the local security context, cryptographically signed, and persisted within the device's secure vault.

> [!TIP]
> The integrator receives a success result immediately. No manual intervention or network dependency is required during the checkout flow, as the SDK handles the transition to local processing seamlessly.

### Reconciliation
Reconciliation synchronizes local records with SumUp's backend. The SDK triggers this automatically upon offline session deactivation or during the subsequent online transaction. The process is complete once the backend confirms receipt, transitioning transactions from "Pending" to "Cleared"

> [!TIP]
> **Proactive Synchronization**
> 
> To minimize "Time-at-Risk", we strongly recommend triggering a synchronization manually as soon as a stable Wi-Fi or cellular connection is restored. This ensures locally stored transactions are transmitted for final clearing and settlement as quickly as possible

## Minimum requirements
To ensure security and functionality, the following minimum requirements must be met:

### iOS

#### Minimum Version
iOS `16.0` or higher.

#### Secure Enclave Processor
The device must be equipped with a Secure Enclave[^1]. This hardware component is mandatory to ensure the highest level of security for local data handling.

#### Storage
A minimum of 10 MB of free disk space is recommended.

### Card Readers

A compatible Card Reader with updated firmware is required:

#### Solo

##### Minimum firmware version
`3.3.31.0` or higher.

#### Solo Lite

##### Minimum firmware version
`2.2.1.19` or higher.

### Card Schemes

Offline processing is currently limited to:
* Visa
* Mastercard

## Limitations
To maintain a secure and reliable payment environment, the offline mode is subject to several technical and operational constraints. These boundaries ensure data integrity and define the specific conditions under which local transactions can be safely processed.

### Tap-to-Pay
Offline Payments do not support Tap-to-Pay on iPhone. To enable and use the functionality, payments must be performed exclusively through a physical SumUp Card Reader.

### Atomic Operations
The SDK is designed to process offline-related requests as strictly atomic and serial operations. To maintain the integrity of the local environment and prevent state inconsistencies, APIs must not be invoked concurrently. Every request must be initiated only after the preceding operation has fully completed. This strict serial requirement is a core security design choice to ensure that the local system remains tamper-proof.

### Online Prerequisite and Card Reader Serial Binding
To enable offline transactions, a merchant must first complete at least one successful online transaction on the specific iOS device.

> [!NOTE]
> Once an offline session is active, the first offline transaction performed will bind the session to the Serial Number of the Card Reader in use.

> [!WARNING]
> From that moment, the offline session is locked to that specific hardware. Switching to a different Card Reader while the session is open will result in the immediate suspension of offline processing.

### Transaction Caps
Individual transaction amounts are subject to limits defined by the merchant's profile. Transactions exceeding these thresholds will be rejected while offline.

### Cumulative Limit
There is a maximum total volume (sum of all successful offline transactions) that can be stored on the device. Once this limit is reached, synchronization is mandatory before new offline payments can be accepted.

### Time Constraints
Offline sessions are time-bound. If the device remains offline beyond the validity period defined within the session configuration, all subsequent transaction requests will be rejected until synchronization.

## Associated Risks
Processing payments without a real-time connection introduces specific financial and technical vulnerabilities.

### Deferred Declines
Transactions accepted offline are subject to Deferred Declines. Since real-time authorization with the issuing bank is not possible, a transaction may be declined during the reconciliation phase due to insufficient funds or card status (stolen/expired) not present in local blocklists.

### Data Loss
Stored transactions are local to the device and are not included in iCloud or iTunes backups.

> [!WARNING]
> If the device is lost, physically destroyed, or factory reset before a synchronization occurs, all offline transaction data will be irretrievably lost.

### Data Integrity and Tamper Detection
The SDK includes security measures to ensure the integrity of locally stored data. If the system detects that the local environment has been compromised or the data altered, offline processing will be disabled to protect SumUp and the merchant from potential fraud. In such cases, any unsynchronized transactions may become unrecoverable.

### Date Tampering and Clock Synchronization
For security and compliance reasons, the SDK requires an accurate system clock to validate offline transactions.

> [!CAUTION]
> If the SDK detects a significant discrepancy in the device's date and time settings, offline processing will be blocked.

> [!TIP]
> To ensure uninterrupted service, we highly recommend enabling the "Set Automatically" feature in the iOS Date & Time settings[^2].

## Suggestions

### Code-Level Documentation
For a deeper understanding of the available properties and methods, we strongly recommend exploring the documentation comments provided directly within the SDK

## Disclaimers
It is important to understand the responsibilities of the merchant and the necessary compliance standards before enabling offline transaction processing.

### Liability
Offline payments are accepted at the merchant's sole risk. SumUp assumes no liability for financial losses resulting from deferred declines, hardware malfunctions, or the loss of local data before synchronization.

### Compliance
Merchants are responsible for ensuring that their use of offline transactions and processing complies with local financial regulations, industry standards, and SumUp’s Terms of Service.

## Support
For technical issues regarding synchronization failures or offline session management, please refer to the SumUp Developer Support portal.

### Partnerships & Enablement
integrations@sumup.com

### General
Your SumUp technical contact

[^1]: https://support.apple.com/guide/security/sec59b0b31ff
[^2]: https://support.apple.com/guide/iphone/change-the-date-and-time-iph65f82af3e/ios
