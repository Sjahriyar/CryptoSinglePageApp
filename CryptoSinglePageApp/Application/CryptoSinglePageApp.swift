//
//  CryptoSinglePageApp.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 14/06/2023.
//

import SwiftUI

@main
struct CryptoSinglePageApp: App {
    var body: some Scene {
        WindowGroup {
            // in real world example, the instrument should be passed from parent view
            CurrencyDetailView(
                viewModel: .init(
                    orderBookViewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue),
                    recentOrderViewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue),
                    headerViewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue)
                )
            )
        }
    }
}
