//
//  CurrencyDetailHeaderViewUseCase.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Combine
import Foundation

protocol CurrencyDetailHeaderViewUseCase {
    func start()
    func connect()
    func suspendTask()
    func subscribeToInstrument(_ instrumentSymbol: String) throws
    func unsubscribeFromInstrument(_ instrumentSymbol: String)

    var messagePublisher: PassthroughSubject<Instrument, Error> { get }
}

final class DefaultCurrencyDetailHeaderViewUseCase: CurrencyDetailHeaderViewUseCase {
    var messagePublisher = PassthroughSubject<Instrument, Error>()

    private let repository: CurrencyDetailHeaderViewRepository

    private var cancellables = Set<AnyCancellable>()

    init(repository: CurrencyDetailHeaderViewRepository = DefaultCurrencyDetailHeaderViewRepository()) {
        self.repository = repository
    }

    func start() {
        repository.messagePublisher.sink { [weak self] completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                self?.messagePublisher.send(completion: .failure(error))
            }
        } receiveValue: { [weak self] instrument in
            self?.messagePublisher.send(instrument)
        }
        .store(in: &cancellables)
    }

    func connect() {
        repository.connect()
    }

    func suspendTask() {
        repository.suspend()
    }

    func subscribeToInstrument(_ instrumentSymbol: String) throws {
        try repository.subscribeToInstrument(instrumentSymbol)
    }

    func unsubscribeFromInstrument(_ instrumentSymbol: String) {
        do {
            try repository.unsubscribeFromInstrument(instrumentSymbol)
        } catch {
            printIfDebug("Failed unsubscribing: \(error)")
        }
    }
}
