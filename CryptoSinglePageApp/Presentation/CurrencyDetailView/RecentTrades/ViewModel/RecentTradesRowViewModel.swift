//
//  RecentTradesRowViewModel.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 20/06/2023.
//

import Foundation

extension RecentTradesRowView {
    @MainActor
    final class ViewModel: ObservableObject {
        let price: String
        let quantity: String
        let time: String
        let side: RecentTradeData.SideType

        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            return formatter
        }()

        init(
            recentTradeData: RecentTradeData
        ) {
            self.price = recentTradeData.price.toString() ?? recentTradeData.price.formatted()
            self.quantity = recentTradeData.size.toString() ?? recentTradeData.size.formatted()
            self.time = dateFormatter.string(from: recentTradeData.timestamp)
            self.side = recentTradeData.side
        }
    }
}
