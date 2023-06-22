//
//  OrderBookRepository.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Combine
import Foundation

protocol OrderBookRepository {
    func subscribeToOrderBookL2(for instrument: String) throws
    func unsubsribeFromOrderBookL2(for instrument: String) throws
    func terminateConnection()
    func connect()
    func suspend()

    var messagePublisher: PassthroughSubject<OrderBook, Error> { get }
}

final class DefaultOrderBookRepository: OrderBookRepository {
    private let bitMexRepository: BitmexRepository
    private var cancellables = Set<AnyCancellable>()

    private lazy var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601

        return jsonDecoder
    }()

    var messagePublisher = PassthroughSubject<OrderBook, Error>()

    init(
        bitMexRepository: BitmexRepository = DefaultBitmexRepository(
            url: APIEndpoints.bitmaxRealTime
        )
    ) {
        self.bitMexRepository = bitMexRepository
    }

    func subscribeToOrderBookL2(for instrument: String) throws {
        try bitMexRepository.subscribe(to: [.orderBookL2: instrument.uppercased()])
        publishMessage()
    }

    func unsubsribeFromOrderBookL2(for instrument: String) throws {
        try bitMexRepository.unsubscribe(from: [.orderBookL2: instrument.uppercased()])
    }

    func terminateConnection() {
        bitMexRepository.disconnect()
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
                      jsonDict["action"] as? String != nil else {
                    return
                }

                do {
                    let orderBook = try self.decoder.decode(OrderBook.self, from: data)
                    self.messagePublisher.send(orderBook)
                } catch {
                    self.messagePublisher.send(completion: .failure(WebSocketStreamError.corruptData))
                    self.bitMexRepository.disconnect()
                }
            }
            .store(in: &cancellables)
    }
}
