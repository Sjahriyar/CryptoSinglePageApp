//
//  Int+Extension.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Foundation

extension Int {
    func toString(
        _ style: NumberFormatter.Style = .decimal,
        groupingSeparator: String = "."
    ) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = groupingSeparator

        return numberFormatter.string(from: NSNumber(value: self))
    }
}
