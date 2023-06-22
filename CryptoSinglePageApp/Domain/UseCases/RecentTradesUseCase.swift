//
//  RecentTradesUseCase.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Combine
import Foundation

protocol RecentTradesUseCase {
    func start()
    func stop()
    func connect()
    func suspendTask()
    func subscribeToTradeUpdates(forInstrument instrumentSymbol: String) throws
    func unsubscribeFromTradeUpdates(forInstrument instrumentSymbol: String)

    var messagePublisher: PassthroughSubject<RecentTrade, Error> { get }
}

final class DefaultRecentTradesUseCase: RecentTradesUseCase {
    private let repository: RecentTradesRepository
    private var cancellables = Set<AnyCancellable>()

    var messagePublisher = PassthroughSubject<RecentTrade, Error>()

    init(
        repository: RecentTradesRepository = DefaultRecentTradesRepository()
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

    func suspendTask() {
        repository.suspend()
    }

    func subscribeToTradeUpdates(forInstrument instrumentSymbol: String) throws {
        try repository.subscribeToTradeUpdates(forInstrument: instrumentSymbol)
    }

    func unsubscribeFromTradeUpdates(forInstrument instrumentSymbol: String) {
        do {
            try repository.unsubscribeFromTradeUpdates(forInstrument: instrumentSymbol)
        } catch {
            printIfDebug("Failed unsubscribing: \(error)")
        }
    }
}
