//
//  Constants.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 16/06/2023.
//

import Foundation

struct Constants {
    /// 4
    static let spacingSmall: CGFloat = 4
    /// 8
    static let spacingMedium: CGFloat = 8
    /// 16
    static let spacingDefault: CGFloat = 16
    /// 32
    static let spacingLarge: CGFloat = 32
}

// Although this may not be applicable in a real-world app, using this approach reduces the likelihood of errors for me.
enum InstrumentSymbol: String {
    case XBTUSD
}
