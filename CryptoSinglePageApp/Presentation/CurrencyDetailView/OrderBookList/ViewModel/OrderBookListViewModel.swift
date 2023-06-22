//
//  OrderBookListViewModel.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Foundation
import Combine

extension OrderBookListView {
    @MainActor
    final class ViewModel: ObservableObject {
        private let instrumentSymbol: String
        private let orderBookUseCase: OrderBookUseCase
        @Published var orderBookBuyItems = [OrderBookItem]()
        @Published var orderBookSellItems = [OrderBookItem]()

        @Published var error: Error? = nil
        @Published var hasError = false
        
        var totalSellSize: Double {
            Double(orderBookSellItems.reduce(0) { $0 + $1.size })
        }
        
        var totalBuySize: Double {
            Double(orderBookBuyItems.reduce(0) { $0 + $1.size })
        }
        
        private var cancellables = Set<AnyCancellable>()
        
        init(
            instrumentSymbol: String,
            orderBookUseCase: OrderBookUseCase = DefaultOrderBookUseCase()
        ) {
            self.instrumentSymbol = instrumentSymbol
            self.orderBookUseCase = orderBookUseCase
            self.orderBookUseCase.start()

            startListening()
        }

        deinit {
            orderBookUseCase.unsubscribeFromOrderBookL2(for: self.instrumentSymbol)
        }

        func connect() {
            orderBookUseCase.connect()
        }

        func suspendTask() {
            orderBookUseCase.suspend()
        }

        func stopListening() {
            orderBookUseCase.unsubscribeFromOrderBookL2(for: self.instrumentSymbol)
        }
        
        func startListening() {
            do {
                try self.orderBookUseCase.subscribeToOrderBookL2(for: self.instrumentSymbol)

                self.orderBookUseCase.messagePublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished:
                            printIfDebug("Message publisher received")
                        case .failure(let error):
                            printIfDebug(error.localizedDescription, type: .error)
                            self?.error = error
                            self?.hasError = true
                        }
                    } receiveValue: { [weak self] orderBook in
                        guard let `self`, orderBook.table == .orderBookL2 else { return }

                        self.handleOrderBookMessages(orderBook)
                    }
                    .store(in: &cancellables)
            } catch {
                self.orderBookUseCase.unsubscribeFromOrderBookL2(for: self.instrumentSymbol)
                self.error = error
                self.hasError = true
            }
        }

        func reconnect() {
            error = nil
            hasError = false

            startListening()
        }

        private func handleOrderBookMessages(_ orderBook: OrderBook) {
            switch orderBook.action {
            case .update:
                hanldeUpdate(orderBook)
            case .delete:
                handleDelete(orderBook)
            case .insert:
                handleInsert(orderBook)
            case .partial:
                handlePartialData(orderBook)
            }
        }

        private func hanldeUpdate(_ orderBook: OrderBook) {
            for item in orderBook.data {
                if item.side == .buy {
                    updateItem(item, in: &orderBookBuyItems)
                } else {
                    updateItem(item, in: &orderBookSellItems)
                }
            }
        }

        private func handleInsert(_ orderBook: OrderBook) {
            for item in orderBook.data {
                if item.side == .buy {
                    insertItem(item, into: &orderBookBuyItems)
                } else {
                    insertItem(item, into: &orderBookSellItems)
                }
            }

            limitAndSortItems()
        }

        private func handleDelete(_ orderBook: OrderBook) {
            for item in orderBook.data {
                if item.side == .buy {
                    deleteItem(item, from: &orderBookBuyItems)
                } else {
                    deleteItem(item, from: &orderBookSellItems)
                }
            }
        }

        private func handlePartialData(_ orderBook: OrderBook) {
            orderBookBuyItems = orderBook.data.filter { $0.side == .buy }
            orderBookSellItems = orderBook.data.filter { $0.side == .sell }

            limitAndSortItems()
        }

        private func insertItem(_ item: OrderBookItem, into array: inout [OrderBookItem]) {
            let index: Array<OrderBookItem>.Index
            if item.side == .buy {
                index = array.firstIndex { $0.price < item.price } ?? array.endIndex
            } else {
                index = array.firstIndex { $0.price > item.price } ?? array.startIndex
            }

            array.insert(item, at: index)
        }

        private func updateItem(_ item: OrderBookItem, in array: inout [OrderBookItem]) {
            if let index = array.firstIndex(where: { $0.id == item.id }) {
                array[index] = item
            }
        }

        private func deleteItem(_ item: OrderBookItem, from array: inout [OrderBookItem]) {
            guard let index = array.firstIndex(of: item) else { return }
            array.remove(at: index)
        }

        private func limitAndSortItems() {
            orderBookBuyItems = Array(orderBookBuyItems.prefix(30)).sorted { $0.price > $1.price }
            orderBookSellItems = Array(orderBookSellItems.prefix(30)).sorted { $0.price < $1.price }
        }
    }
}
