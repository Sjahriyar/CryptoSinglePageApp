//
//  OrderBookListRowViewModel.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Foundation

extension OrderBookListRowView {
    @MainActor
    final class ViewModel: ObservableObject {
        let totalSize: Double
        let isBuy: Bool
        let size: Int
        let price: String

        init(
            orderBookItem: OrderBookItem,
            totalSize: Double
        ) {
            self.totalSize = totalSize
            self.isBuy = orderBookItem.side == .buy
            self.size = orderBookItem.size
            self.price = orderBookItem.price.toString() ?? orderBookItem.price.formatted()
        }

        func calculateRelativeVolumeWidth(maxWidth: CGFloat) -> CGFloat {
            let relativeVolume = Double(size) / totalSize
            return maxWidth * CGFloat(relativeVolume)
        }
    }
}
