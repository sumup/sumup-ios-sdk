//
//  ViewController.swift
//  SumupSDKSampleApp
//
//  Created by Felix Lamouroux on 10.11.16.
//  Copyright © 2016 SumUp Payments Limited. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var appearCompleted = false

    // MARK: - Storyboard Outlets

    @IBOutlet fileprivate weak var buttonLogin: UIButton?
    @IBOutlet fileprivate weak var buttonLogout: UIButton?
    @IBOutlet fileprivate weak var buttonPreferences: UIButton?
    @IBOutlet fileprivate weak var buttonCharge: UIButton?

    @IBOutlet fileprivate weak var textFieldTotal: UITextField?
    @IBOutlet fileprivate weak var textFieldTitle: UITextField?

    @IBOutlet fileprivate weak var label: UILabel?
    @IBOutlet private weak var versionLabel: UILabel?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel?.text = "Copyright © 2016 SumUp Payments Limited"

        updateButtonStates()
        applyStyle()
        updateCurrency()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !appearCompleted {
            appearCompleted = true
            presentLogin()
        }
    }

    // MARK: - Storyboard Actions

    @IBAction private func buttonLoginTapped(_ sender: Any) {
        presentLogin()
    }

    @IBAction private func buttonLogoutTapped(_ sender: Any) {
        requestLogout()
    }

    @IBAction private func buttonOpenPreferencesTapped(_ sender: Any) {
        presentCheckoutPreferences()
    }

    @IBAction private func buttonChargeTapped(_ sender: Any) {
        requestCheckout()
    }

    // MARK: - SumupSDK interactions

    private func presentCheckoutPreferences() {
        SumupSDK.presentCheckoutPreferences(from: self, animated: true) { [weak self] (success: Bool, presentationError: Error?) in
            guard let safeError = presentationError as? NSError else {
                // no error, nothing else to do
                return
            }

            print("error presenting checkout preferences: \(safeError)")

            let errorMessage: String
            switch (safeError.domain, safeError.code) {
            case (SMPSumupSDKErrorDomain, SMPSumupSDKError.accountNotLoggedIn.rawValue):
                errorMessage = "not logged in"

            case (SMPSumupSDKErrorDomain, SMPSumupSDKError.checkoutInProgress.rawValue):
                errorMessage = "checkout is in progress"

            default:
                errorMessage = "general error"
            }

            self?.showResult(string: errorMessage)
        }
    }

    private func presentLogin() {
        // present login UI and wait for completion block to update button states
        SumupSDK.presentLogin(from: self, animated: true) { [weak self] (success: Bool, error: Error?) in
            guard error == nil else {
                // errors are handled within the SDK, there should be no need
                // for your app to display any error message
                return
            }

            self?.updateCurrency()
            self?.updateButtonStates()
        }
    }

    fileprivate func requestCheckout() {
        // ensure that we have a valid merchant
        guard let merchantCurrencyCode = SumupSDK.currentMerchant()?.currencyCode else {
            showResult(string: "not logged in")
            return
        }

        guard let totalText = textFieldTotal?.text else {
            return
        }

        // create an NSDecimalNumber from the totalText
        // please be aware to not use NSDecimalNumber initializers inherited from NSNumber
        let total = NSDecimalNumber(string: totalText)
        guard total != NSDecimalNumber.zero else {
            return
        }

        // setup payment request
        let request = SMPCheckoutRequest(total: total,
                                         title: textFieldTitle?.text,
                                         currencyCode: merchantCurrencyCode,
                                         paymentOptions: [.cardReader, .mobilePayment])

        // the foreignTransactionID is an **optional** parameter and can be used
        // to retrieve a transaction from SumUp's API. See -[SMPCheckoutRequest foreignTransactionID]
        request.foreignTransactionID = "your-unique-identifier-\(ProcessInfo.processInfo.globallyUniqueString)"

        SumupSDK.checkout(with: request, from: self) { [weak self] (result: SMPCheckoutResult?, error: Error?) in
            if let safeError = error as? NSError {
                print("error during checkout: \(safeError)")

                if (safeError.domain == SMPSumupSDKErrorDomain) && (safeError.code == SMPSumupSDKError.accountNotLoggedIn.rawValue) {
                    self?.showResult(string: "not logged in")
                } else {
                    self?.showResult(string: "general error")
                }

                return
            }

            guard let safeResult = result else {
                print("no error and no result should not happen")
                return
            }

            print("result_transaction==\(safeResult.transactionCode)")

            if safeResult.success {
                print("success")
                self?.showResult(string: "Thank you - \(safeResult.transactionCode)")
            } else {
                print("cancelled: no error, no success")
                self?.showResult(string: "No charge (cancelled)")
            }
        }

        // after the checkout is initiated we expect a checkout to be in progress
        if !SumupSDK.checkoutInProgress() {
            // something went wrong: checkout was not started
            showResult(string: "failed to start checkout")
        }
    }

    fileprivate func requestLogout() {
        SumupSDK.logout() { [weak self] _ in
            self?.updateButtonStates()
        }
    }
}

// MARK: -
// MARK: - Beautify UI

extension ViewController {

    fileprivate func updateButtonStates() {
        let isLoggedIn = SumupSDK.isLoggedIn()
        buttonLogin?.isEnabled = !isLoggedIn
        buttonLogout?.isEnabled = isLoggedIn

        // real apps should usually disable these actions when the user
        // is not logged in - we keep them enabled to demonstrate the
        // error handling

        // buttonCharge?.isEnabled = isLoggedIn
        // buttonPreferences?.isEnabled = isLoggedIn
    }

    fileprivate func applyStyle() {
        // hide alpha and only show for a moment when results appear
        label?.alpha = 0.0
    }

    fileprivate func updateCurrency() {
        // ensure that we have a valid merchant
        guard let merchantCurrencyCode = SumupSDK.currentMerchant()?.currencyCode else {
            return
        }

        guard let textField = textFieldTotal else {
            return
        }

        let currencyLabel: UILabel
        if let rightView = textField.rightView as? UILabel {
            currencyLabel = rightView
        } else {
            currencyLabel = UILabel()
            currencyLabel.backgroundColor = .clear
            currencyLabel.textColor = .lightGray
            textField.rightView = currencyLabel
            textField.rightViewMode = .always
        }

        currencyLabel.text = merchantCurrencyCode
        currencyLabel.sizeToFit()
        // add padding
        currencyLabel.bounds = currencyLabel.bounds.insetBy(dx: -5, dy: 0)
    }

    fileprivate func showResult(string: String) {
        label?.text = string
        // fade in label
        UIView.animateKeyframes(withDuration: 3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            let relativeDuration = TimeInterval(0.15)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: relativeDuration) {
                self.label?.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 1.0 - relativeDuration, relativeDuration: relativeDuration) {
                self.label?.alpha = 0.0
            }
        }, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldTotal {
            textFieldTitle?.becomeFirstResponder()
        } else if SumupSDK.isLoggedIn() {
            requestCheckout()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
