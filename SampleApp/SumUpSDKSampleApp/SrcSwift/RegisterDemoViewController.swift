//
//  RegisterDemoViewController.swift
//  SumUpSDKSampleAppSwift
//
//  Created by Hagi on 14.11.17.
//  Copyright © 2017 SumUp Payments Limited. All rights reserved.
//

import SumUpSDK
import UIKit

class RegisterDemoViewController: UITableViewController {

    // MARK: - Outlets

    @IBOutlet private weak var labelReaderConnected: UILabel?
    @IBOutlet private weak var labelReaderBattery: UILabel?
    @IBOutlet private weak var labelRegisterSerial: UILabel?
    @IBOutlet private weak var labelRegisterFirmware: UILabel?
    @IBOutlet private weak var buttonUpdateFirmware: UIButton?

    @IBOutlet private weak var labelPrinterStatus: UILabel?
    @IBOutlet private weak var labelPrinterPaper: UILabel?
    @IBOutlet private weak var buttonPrintDemo: UIButton?

    @IBOutlet private weak var labelDrawerStatus: UILabel?
    @IBOutlet private weak var buttonOpenDrawer: UIButton?

    // MARK: - Firmware Update Handling

    private weak var alertWhileWaitingForReconnect: UIAlertController?

    // MARK: - Controller Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let registerSDK = SumUpRegisterSDK.shared else {
            print("Error: Register not supported")
            return
        }

        registerSDK.delegate = self
        registerSDK.startListeningForRegister()

        updateFor(registerStatus: registerSDK.deviceStatus)
        updateFor(printerStatus: registerSDK.printerStatus)
        updateFor(drawerIsOpen: registerSDK.drawerIsOpen)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SumUpRegisterSDK.shared?.stopListeningForRegister()
    }

    // MARK: - Display Updates

    private func updateFor(registerStatus newStatus: RegisterStatus?) {
        let registerIsConnected = (newStatus != nil)

        let readerIsConnected = newStatus?.isReaderConnected ?? false
        labelReaderConnected?.text = readerIsConnected ? "Yes" : "No"
        labelReaderConnected?.textColor = readerIsConnected ? .green : .red

        var batteryText = readerIsConnected ? "\(newStatus?.batteryLevel ?? 0) %" : "n/a"

        if readerIsConnected && newStatus?.isBatteryLow ?? false {
            batteryText += "(low)"
        }

        if readerIsConnected && newStatus?.isCharging ?? false {
            batteryText += " - charging"
        }

        labelReaderBattery?.text = batteryText

        labelRegisterSerial?.text = "Serial: \(newStatus?.serialNumber ?? "n/a")"
        labelRegisterFirmware?.text = "Firmware: \(newStatus?.firmwareVersion ?? "n/a")"

        buttonUpdateFirmware?.isEnabled = registerIsConnected
        buttonOpenDrawer?.isEnabled = registerIsConnected
    }

    private func updateFor(printerStatus newStatus: RegisterPrinterStatus?) {
        let printerStatusText: String
        let textColor: UIColor

        switch (newStatus?.isPrinterReady ?? false, newStatus?.genericErrorDidOccur ?? false) {
        case (_, true):
            printerStatusText = "Error occurred"
            textColor = .red
        case (false, _):
            printerStatusText = "Not ready"
            textColor = .red
        case (true, _):
            printerStatusText = "Ready"
            textColor = .green
        }

        labelPrinterStatus?.text = printerStatusText
        labelPrinterStatus?.textColor = textColor

        if let status = newStatus {
            labelPrinterPaper?.text = status.isPaperEmpty ? "Empty" : "OK"
        } else {
            labelPrinterPaper?.text = "n/a"
        }

        buttonPrintDemo?.isEnabled = (newStatus != nil)
    }

    private func updateFor(drawerIsOpen: Bool) {
        labelDrawerStatus?.text = drawerIsOpen ? "Open" : "Closed"
        labelDrawerStatus?.textColor = drawerIsOpen ? .green : .red
    }

}

// MARK: - Register Delegate

extension RegisterDemoViewController: RegisterSDKDelegate {
    func registerDidConnect(_ deviceStatus: RegisterStatus) {
        updateFor(registerStatus: deviceStatus)

        if let blockingAlert = alertWhileWaitingForReconnect {
            blockingAlert.dismiss(animated: true, completion: nil)
        }
    }

    func registerDidDisconnect() {
        updateFor(registerStatus: nil)
    }

    func registerStatusDidChange(_ deviceStatus: RegisterStatus?) {
        updateFor(registerStatus: deviceStatus)
    }

    func printerStatusDidChange(_ status: RegisterPrinterStatus?) {
        updateFor(printerStatus: status)
    }

    func drawerDidOpen() {
        updateFor(drawerIsOpen: true)
    }

    func drawerDidClose() {
        updateFor(drawerIsOpen: false)
    }

}

// MARK: - Storyboard Actions

extension RegisterDemoViewController {

    @IBAction private func dismiss(from sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func updateFirmware(from sender: UIButton) {
        guard SumUpRegisterSDK.shared?.deviceStatus != nil else {
            return
        }

        let alert = UIAlertController(title: "Updating Firmware", message: "Please wait…", preferredStyle: .alert)
        present(alert, animated: true) {
            SumUpRegisterSDK.shared?.startFirmwareUpdate { [weak self] success, error in
                alert.dismiss(animated: true, completion: nil)

                let title: String
                var message: String
                var requiresReconnect = false

                if success {
                    title = "Success"
                    message = "Firmware update installed successfully."
                } else if let nsError = error as NSError?,
                    let sumUpErrorCode = SumUpRegisterSDKError(rawValue: nsError.code),
                    nsError.domain == SumUpRegisterSDKErrorDomain {
                    message = "Error details: \(nsError)"

                    switch sumUpErrorCode {
                    case .general:
                        title = "Error"

                    case .firmwareUpdateInProgress:
                        title = "Update In Progress"

                    case .notConnected:
                        title = "Register Not Connected"

                    case .timeout:
                        title = "Firmware Update Timed Out."

                    case .timeoutFirmwareUpdate:
                        /*
                         *   When encountering timeouts during firmware
                         *   updates, the device should be re-connected.
                         */
                        title = "Please re-connect"
                        message = "Please re-connect to finish the firmware update."
                        requiresReconnect = true
                    @unknown default:
                        assertionFailure("Unknown SumUp SDK error code encountered: \(sumUpErrorCode)")
                        title = "Error"
                        message = "Failed with unknown error: \(String(describing: error))"
                    }
                } else {
                    title = "Error"
                    message = "Failed with unknown error: \(String(describing: error))"
                }

                let feedback = UIAlertController(title: title, message: message, preferredStyle: .alert)

                if requiresReconnect {
                    self?.alertWhileWaitingForReconnect = feedback
                } else {
                    feedback.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }

                self?.present(feedback, animated: true, completion: nil)
            }
        }
    }

    @IBAction private func printDemo(from sender: UIButton) {
        guard SumUpRegisterSDK.shared?.deviceStatus != nil else {
            return
        }

        SumUpRegisterSDK.shared?.printEscPos("Hello SumUp \n\n\n\n")
    }

    @IBAction private func openDrawer(from sender: UIButton) {
        guard let registerSDK = SumUpRegisterSDK.shared, registerSDK.deviceStatus != nil else {
            return
        }

        guard !registerSDK.drawerIsOpen else {
            let alert = UIAlertController(title: nil, message: "Drawer is already open", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        registerSDK.openDrawer()
    }

}
