import SumUpSDK

// MARK: - CheckoutFlowError

/// Errors raised by ``CheckoutFlow`` for validation failures and user cancellations.
///
/// SDK-originated errors are represented by ``SumUpSDKServiceCheckoutError``
/// and propagate through without wrapping.
enum CheckoutFlowError: LocalizedError {
    /// A precondition for starting the checkout was not met.
    case failedToStartCheckout(Error)
    /// The user cancelled the checkout (dismissed the process-as dialog or the SDK returned a non-success result).
    case cancelled
    /// The entered amount is zero.
    case amountIsZero

    var errorDescription: String? {
        switch self {
        case .failedToStartCheckout(let error):
            "Error starting the checkout process: \(error.localizedDescription)"
        case .cancelled:
            "Transaction cancelled by user."
        case .amountIsZero:
            "Amount is zero."
        }
    }
}

// MARK: - CheckoutFlow

/// Manages the checkout lifecycle: validation, optional process-as selection,
/// SDK checkout execution, and result handling.
///
/// All public API is `async throws` — callers drive error presentation.
@MainActor
final class CheckoutFlow {

    /// Bundles the user's process-as selection from the dialog.
    struct ProcessAsSelection {
        let processAs: SumUpSDKCheckoutProcessAs
        let installments: Int
    }

    /// Async closure that presents the process-as dialog and returns the
    /// user's selection, or `nil` if they cancel.
    typealias ProcessAsProvider = @MainActor () async -> ProcessAsSelection?

    private let sdkService: any SumUpSDKService
    private let processAsProvider: ProcessAsProvider?

    init(sdkService: any SumUpSDKService, processAsProvider: ProcessAsProvider? = nil) {
        self.sdkService = sdkService
        self.processAsProvider = processAsProvider
    }

    // MARK: Checkout

    /// Validates inputs, optionally presents the process-as dialog,
    /// executes the SDK checkout, and returns the result on success.
    ///
    /// - Throws: ``CheckoutFlowError`` for validation failures and cancellations.
    ///   SDK errors propagate as ``SumUpSDKServiceCheckoutError``.
    @discardableResult
    func startCheckout(amount: Decimal) async throws -> SumUpSDKServiceCheckoutResult {
        guard let currencyCode = sdkService.currentMerchantCurrencyCode else {
            throw CheckoutFlowError.failedToStartCheckout(SumUpSDKServiceCheckoutError.accountNotLoggedIn(nil))
        }

        guard !amount.isZero else {
            throw CheckoutFlowError.failedToStartCheckout(CheckoutFlowError.amountIsZero)
        }

        var processAs: SumUpSDKCheckoutProcessAs?
        var installments = 0

        if sdkService.isProcessAsRequired {
            guard let selection = await processAsProvider?() else {
                throw CheckoutFlowError.cancelled
            }
            processAs = selection.processAs
            installments = selection.installments
        }

        let request = CheckoutRequest(
            total: NSDecimalNumber(decimal: amount),
            title: nil,
            currencyCode: currencyCode
        )
        request.skipScreenOptions = sdkService.skipScreenOptions.sdkValue

        request.tipOnCardReaderIfAvailable = sdkService.tippingEnabled
        request.customTipRates = sdkService.customTipRates?.map(NSNumber.init)
        
        if let processAs {
            request.processAs = processAs.sdkValue
            if processAs == .credit {
                request.numberOfInstallments = installments
            }
        }

        let result = try await sdkService.checkout(with: request)

        guard result.success else {
            throw CheckoutFlowError.cancelled
        }

        return result
    }
}
