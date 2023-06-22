//
//  CurrencyDetailViewModel.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 17/06/2023.
//

import Combine
import Foundation

extension CurrencyDetailView {
    @MainActor
    final class ViewModel: ObservableObject {
        let orderBookViewModel: OrderBookListView.ViewModel
        let recentOrderViewModel: RecentTradesView.ViewModel
        let headerViewModel: CurrencyDetailHeaderView.ViewModel

        init(
            orderBookViewModel: OrderBookListView.ViewModel,
            recentOrderViewModel: RecentTradesView.ViewModel,
            headerViewModel: CurrencyDetailHeaderView.ViewModel
        ) {
            self.orderBookViewModel = orderBookViewModel
            self.recentOrderViewModel = recentOrderViewModel
            self.headerViewModel = headerViewModel
        }

        func suspendTasks() {
            orderBookViewModel.suspendTask()
            recentOrderViewModel.suspendTask()
            headerViewModel.suspendTask()
        }

        func startTasks() {
            orderBookViewModel.connect()
            recentOrderViewModel.connect()
            headerViewModel.connect()
        }
    }
}
