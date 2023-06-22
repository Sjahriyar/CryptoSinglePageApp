//
//  Double+Extension.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Foundation

extension Double {
    func toString(
        _ style: NumberFormatter.Style = .decimal,
        groupingSeparator: String = ",",
        decimalSeparator: String = "."
    ) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = groupingSeparator
        numberFormatter.decimalSeparator = decimalSeparator

        return numberFormatter.string(from: NSNumber(value: self))
    }
}
