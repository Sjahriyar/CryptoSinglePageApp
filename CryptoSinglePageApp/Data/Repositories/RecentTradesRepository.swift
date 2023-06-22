//
//  RecentTradesRepository.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Combine
import Foundation

protocol RecentTradesRepository {
    func subscribeToTradeUpdates(forInstrument instrumentSymbol: String) throws
    func unsubscribeFromTradeUpdates(forInstrument instrumentSymbol: String) throws
    func terminateConnection()
    func connect()
    func suspend()

    var messagePublisher: PassthroughSubject<RecentTrade, Error> { get }
}

final class DefaultRecentTradesRepository: RecentTradesRepository {
    private let bitMexRepository: BitmexRepository
    private var cancellables = Set<AnyCancellable>()

    private lazy var decoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601

        return jsonDecoder
    }()

    var messagePublisher = PassthroughSubject<RecentTrade, Error>()

    init(
        bitMexRepository: BitmexRepository = DefaultBitmexRepository(
        url: APIEndpoints.bitmaxRealTime)
    ) {
        self.bitMexRepository = bitMexRepository
    }

    func subscribeToTradeUpdates(forInstrument instrumentSymbol: String) throws {
        try bitMexRepository.subscribe(to: [.trade: instrumentSymbol.uppercased()])
        publishMessage()
    }

    func unsubscribeFromTradeUpdates(forInstrument instrumentSymbol: String) throws {
        try bitMexRepository.unsubscribe(from: [.trade: instrumentSymbol.uppercased()])
    }

    func terminateConnection() {
        bitMexRepository.disconnect()
    }

    func suspend() {
        bitMexRepository.suspend()
    }

    func connect() {
        bitMexRepository.connect()
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
                      action == BitmexAction.insert.rawValue else {
                    return
                }

                do {
                    let recentTrade = try self.decoder.decode(RecentTrade.self, from: data)
                    self.messagePublisher.send(recentTrade)
                } catch {
                    self.messagePublisher.send(completion: .failure(WebSocketStreamError.corruptData))
                    self.bitMexRepository.disconnect()
                }
            }
            .store(in: &cancellables)
    }
}
