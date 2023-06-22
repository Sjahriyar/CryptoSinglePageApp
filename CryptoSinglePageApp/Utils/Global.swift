//
//  Global.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 17/06/2023.
//

import Foundation

enum PrintType: String {
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "‼️"
}

func printIfDebug(_ items: Any..., type: PrintType = .info) {
    #if DEBUG
    print("\(type.rawValue) \(items)")
    #endif
}
