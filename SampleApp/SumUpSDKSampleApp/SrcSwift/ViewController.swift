//
//  ViewController.swift
//  SumUpSDKSampleApp
//
//  Created by Felix Lamouroux on 10.11.16.
//  Copyright © 2016 SumUp Payments Limited. All rights reserved.
//

import SumUpSDK
import UIKit

class ViewController: UIViewController {
    private var appearCompleted = false

    // MARK: - Storyboard Outlets

    @IBOutlet fileprivate weak var buttonLogin: UIButton?
    @IBOutlet fileprivate weak var buttonLogout: UIButton?
    @IBOutlet fileprivate weak var buttonPreferences: UIButton?
    @IBOutlet fileprivate weak var buttonRegisterDemo: UIButton?
    @IBOutlet fileprivate weak var buttonCharge: UIButton?

    @IBOutlet fileprivate weak var textFieldTotal: UITextField?
    @IBOutlet fileprivate weak var textFieldTitle: UITextField?

    @IBOutlet fileprivate weak var segmentedControlTipping: UISegmentedControl?
    @IBOutlet fileprivate weak var switchSkipReceiptScreen: UISwitch?

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

    // MARK: - SumUpSDK interactions

    private func presentCheckoutPreferences() {
        SumUpSDK.presentCheckoutPreferences(from: self, animated: true) { [weak self] (success: Bool, presentationError: Error?) in
            print("Did present checkout preferences with success: \(success). Error: \(String(describing: presentationError))")

            guard let safeError = presentationError as NSError? else {
                // no error, nothing else to do
                return
            }

            print("error presenting checkout preferences: \(safeError)")

            let errorMessage: String
            switch (safeError.domain, safeError.code) {
            case (SumUpSDKErrorDomain, SumUpSDKError.accountNotLoggedIn.rawValue):
                errorMessage = "not logged in"

            case (SumUpSDKErrorDomain, SumUpSDKError.checkoutInProgress.rawValue):
                errorMessage = "checkout is in progress"

            default:
                errorMessage = "general error"
            }

            self?.showResult(string: errorMessage)
        }
    }

    private func presentLogin() {
        // present login UI and wait for completion block to update button states
        SumUpSDK.presentLogin(from: self, animated: true) { [weak self] (success: Bool, error: Error?) in
            print("Did present login with success: \(success). Error: \(String(describing: error))")

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
        guard let merchantCurrencyCode = SumUpSDK.currentMerchant?.currencyCode else {
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
        let request = CheckoutRequest(total: total,
                                      title: textFieldTitle?.text,
                                      currencyCode: merchantCurrencyCode)

        // add tip if selected
        if let selectedTip = segmentedControlTipping?.selectedSegmentIndex,
            selectedTip > 0,
            tipAmounts.indices ~= selectedTip {
            let tipAmount = tipAmounts[selectedTip]
            request.tipAmount = tipAmount
        }

        // set screenOptions to skip if switch is set to on 
        if let skip = switchSkipReceiptScreen?.isOn, skip {
            request.skipScreenOptions = .success
        }

        // the foreignTransactionID is an **optional** parameter and can be used
        // to retrieve a transaction from SumUp's API. See -[SMPCheckoutRequest foreignTransactionID]
        request.foreignTransactionID = "your-unique-identifier-\(ProcessInfo.processInfo.globallyUniqueString)"

        SumUpSDK.checkout(with: request, from: self) { [weak self] (result: CheckoutResult?, error: Error?) in
            if let safeError = error as NSError? {
                print("error during checkout: \(safeError)")

                if (safeError.domain == SumUpSDKErrorDomain) && (safeError.code == SumUpSDKError.accountNotLoggedIn.rawValue) {
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

            print("result_transaction==\(String(describing: safeResult.transactionCode))")

            if safeResult.success {
                print("success")
                var message = "Thank you - \(String(describing: safeResult.transactionCode))"

                if let info = safeResult.additionalInfo,
                    let tipAmount = info["tip_amount"] as? Double, tipAmount > 0,
                    let currencyCode = info["currency"] as? String {
                    message = message.appending("\ntip: \(tipAmount) \(currencyCode)")
                }

                self?.showResult(string: message)
            } else {
                print("cancelled: no error, no success")
                self?.showResult(string: "No charge (cancelled)")
            }
        }

        // after the checkout is initiated we expect a checkout to be in progress
        if !SumUpSDK.checkoutInProgress {
            // something went wrong: checkout was not started
            showResult(string: "failed to start checkout")
        }
    }

    fileprivate func requestLogout() {
        SumUpSDK.logout { [weak self] (success: Bool, error: Error?) in
            print("Did log out with success: \(success). Error: \(String(describing: error))")
            self?.updateButtonStates()
        }
    }

    // MARK: - Tipping
    fileprivate func updateTipControl() {
        guard let control = segmentedControlTipping else {
            return
        }

        let isLoggedIn = SumUpSDK.isLoggedIn

        control.isHidden = !isLoggedIn
        control.removeAllSegments()

        guard let currencyCode = SumUpSDK.currentMerchant?.currencyCode else {
            return
        }

        for tip in tipAmounts {
            let isZero = tip.isEqual(NSDecimalNumber.zero)
            let title = isZero ? "No tip" : String(format: "%@ %@", tip, currencyCode)
            control.insertSegment(withTitle: title, at: control.numberOfSegments, animated: true)
        }
    }

    fileprivate var tipAmounts: [NSDecimalNumber] {
        guard let currencyCode = SumUpSDK.currentMerchant?.currencyCode, !currencyCode.isEmpty else {
            return []
        }

        switch currencyCode {
        case CurrencyCodeSEK:
            return [NSDecimalNumber.zero,
                    NSDecimalNumber(mantissa: 20, exponent: 0, isNegative: false),
                    NSDecimalNumber(mantissa: 40, exponent: 0, isNegative: false)]

        case CurrencyCodeBRL:
            return [NSDecimalNumber.zero,
                    NSDecimalNumber(mantissa: 5, exponent: 0, isNegative: false),
                    NSDecimalNumber(mantissa: 10, exponent: 0, isNegative: false)]

        default:
            return [NSDecimalNumber.zero,
                    NSDecimalNumber(mantissa: 2, exponent: 0, isNegative: false),
                    NSDecimalNumber(mantissa: 5, exponent: 0, isNegative: false)]
        }
    }
}

// MARK: -
// MARK: - Beautify UI

extension ViewController {

    fileprivate func updateButtonStates() {
        let isLoggedIn = SumUpSDK.isLoggedIn
        buttonLogin?.isEnabled = !isLoggedIn
        buttonLogout?.isEnabled = isLoggedIn

        // real apps should usually disable these actions when the user
        // is not logged in - we keep them enabled to demonstrate the
        // error handling

        // buttonCharge?.isEnabled = isLoggedIn
        // buttonPreferences?.isEnabled = isLoggedIn

        // Hidden by default: Please refer to AirRegister/README.md for
        // further details.
        buttonRegisterDemo?.isHidden = !SumUpRegisterSDK.registerIsSupported

        switchSkipReceiptScreen?.isEnabled = isLoggedIn
        updateTipControl()
    }

    fileprivate func applyStyle() {
        // hide alpha and only show for a moment when results appear
        label?.alpha = 0.0
    }

    fileprivate func updateCurrency() {
        // ensure that we have a valid merchant
        guard let merchantCurrencyCode = SumUpSDK.currentMerchant?.currencyCode else {
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
            // we assume a checkout is imminent
            // let the SDK know to e.g. wake a connected terminal
            SumUpSDK.prepareForCheckout()

            textFieldTitle?.becomeFirstResponder()
        } else if SumUpSDK.isLoggedIn {
            requestCheckout()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
