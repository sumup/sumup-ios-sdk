import Foundation

/// A quick and dirty provider to back the number pad entry.
final class NumpadMathProvider {
    /// Internal string representation uses fixed Locale separator
    private static let decimalString = "."
    
    private(set) var paymentAmountString = ""
    
    var amount: Decimal {
        Decimal(string: paymentAmountString) ?? 0
    }
    
    func addDigitToEnd(_ number: UInt8) {
        guard (number / 10) < 1 else { return }
        
        guard amount != 0 || number != 0 else { return }
        
        let hasDecimal = paymentAmountString.contains(Self.decimalString)
        let parts = paymentAmountString.split(separator: Self.decimalString, omittingEmptySubsequences: false)
        
        if hasDecimal && (parts.last?.count ?? 0) >= 2 {
            return
        }
        
        if !hasDecimal, let wholeNumber = parts.first, wholeNumber.count >= 6 {
            return
        }
        
        paymentAmountString.append(String(number))
    }
    
    func addDecimal() {
        guard !paymentAmountString.contains(Self.decimalString) else { return }
        
        paymentAmountString.append(Self.decimalString)
    }
    
    func removeLastDigit() {
        if paymentAmountString.hasSuffix(Self.decimalString) {
            _ = paymentAmountString.popLast()
        }
        _ = paymentAmountString.popLast()
    }
    
    func clear() {
        paymentAmountString = ""
    }
}
