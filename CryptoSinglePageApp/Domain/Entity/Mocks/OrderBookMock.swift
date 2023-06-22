//
//  OrderBookMock.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Foundation

extension OrderBook {
    struct Mock {
        static func generateOrderBook() -> OrderBook? {
            guard let url = Bundle.main.url(forResource: "OrderBookTestData", withExtension: "json") else {
                printIfDebug("Could not find OrderBookTestData.json \(#function)", type: .error)
                return nil
            }

            guard let data = try? Data(contentsOf: url) else {
                printIfDebug("Failed converting url to Data \(#function)", type: .error)
                return nil
            }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(OrderBook.self, from: data)
            } catch {
                printIfDebug("Failed converting url to Data \(#function)", type: .error)
            }

            return nil
        }
    }
}
