//
//  RecentTradesMock.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 20/06/2023.
//

import Foundation

extension RecentTrade {
    struct Mock {
        static func generateRecentTrades() -> RecentTrade? {
            guard let url = Bundle.main.url(forResource: "RecentTradesTestData", withExtension: "json") else {
                printIfDebug("Could not find RecentTradesTestData.json \(#function)", type: .error)
                return nil
            }

            guard let data = try? Data(contentsOf: url) else {
                printIfDebug("Failed converting url to Data \(#function)", type: .error)
                return nil
            }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(RecentTrade.self, from: data)
            } catch {
                printIfDebug("Failed converting url to Data \(#function)", type: .error)
            }

            return nil
        }
    }
}
