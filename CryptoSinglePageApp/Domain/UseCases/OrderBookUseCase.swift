//
//  OrderBookUseCase.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Combine
import Foundation

protocol OrderBookUseCase {
    func start()
    func stop()
    func connect()
    func suspend()
    func subscribeToOrderBookL2(for instrumentSymbol: String) throws
    func unsubscribeFromOrderBookL2(for instrumentSymbol: String)

    var messagePublisher: PassthroughSubject<OrderBook, Error> { get }
}

final class DefaultOrderBookUseCase: OrderBookUseCase {
    var messagePublisher = PassthroughSubject<OrderBook, Error>()

    private let repository: OrderBookRepository

    private var cancellables = Set<AnyCancellable>()

    init(
        repository: OrderBookRepository = DefaultOrderBookRepository()
    ) {
        self.repository = repository
    }

    func start() {
        repository.messagePublisher.sink { [weak self] completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self?.messagePublisher.send(completion: .failure(error))
            }
        } receiveValue: { [weak self] orderBook in
            self?.messagePublisher.send(orderBook)
        }
        .store(in: &cancellables)
    }

    func stop() {
        repository.terminateConnection()
    }

    func connect() {
        repository.connect()
    }

    func suspend() {
        repository.suspend()
    }

    func subscribeToOrderBookL2(for instrumentSymbol: String) throws {
        try repository.subscribeToOrderBookL2(for: instrumentSymbol)
    }

    func unsubscribeFromOrderBookL2(for instrumentSymbol: String) {
        do {
            try repository.unsubsribeFromOrderBookL2(for: instrumentSymbol)
        } catch {
            printIfDebug("Failed unsubscribing: \(error)")
        }
    }
}
