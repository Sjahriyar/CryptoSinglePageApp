//
//  CurrencyDetailHeaderViewRepository.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Combine
import Foundation

protocol CurrencyDetailHeaderViewRepository {
    func subscribeToInstrument(_ instrumentSymbol: String) throws
    func unsubscribeFromInstrument(_ instrumentSymbol: String) throws
    func connect()
    func suspend()

    var messagePublisher: PassthroughSubject<Instrument, Error> { get }
}

final class DefaultCurrencyDetailHeaderViewRepository: CurrencyDetailHeaderViewRepository {
    private let bitMexRepository: BitmexRepository
    private var cancellables = Set<AnyCancellable>()

    private lazy var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601

        return jsonDecoder
    }()

    let messagePublisher = PassthroughSubject<Instrument, Error>()

    init(
        bitMexRepository: BitmexRepository = DefaultBitmexRepository(
            url: APIEndpoints.bitmaxRealTime
        )
    ) {
        self.bitMexRepository = bitMexRepository
    }

    func subscribeToInstrument(_ instrumentSymbol: String) throws {
        try bitMexRepository.subscribe(to: [.instrument: instrumentSymbol.uppercased()])
        publishMessage()
    }

    func unsubscribeFromInstrument(_ instrumentSymbol: String) throws {
        try bitMexRepository.unsubscribe(from: [.instrument: instrumentSymbol.uppercased()])
    }

    func connect() {
        bitMexRepository.connect()
    }

    func suspend() {
        bitMexRepository.suspend()
    }

    private func publishMessage() {
        bitMexRepository.messagePublisher
            .dropFirst(2) // Connection message and subscribe message
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    printIfDebug("Received from bitMexRepository")
                case .failure(let error):
                    printIfDebug(error.localizedDescription)
                    self?.messagePublisher.send(completion: .failure(error))
                }
            } receiveValue: { [weak self] message in
                guard let `self` else { return }

                guard let data = message.data(using: .utf8) else {
                    printIfDebug("Failed converting String to Data", type: .error)
                    self.messagePublisher.send(completion: .failure(WebSocketStreamError.corruptData))
                    self.bitMexRepository.disconnect()
                    return
                }

                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                      let jsonDict = jsonObject as? [String: Any],
                      let action = jsonDict["action"] as? String,
                      action == BitmexAction.partial.rawValue || action == BitmexAction.update.rawValue else {
                    return
                }

                do {
                    let instrument = try self.decoder.decode(Instrument.self, from: data)
                    self.messagePublisher.send(instrument)
                } catch {
                    self.messagePublisher.send(completion: .failure(WebSocketStreamError.corruptData))
                    self.bitMexRepository.disconnect()
                }
            }
            .store(in: &cancellables)
    }
}
