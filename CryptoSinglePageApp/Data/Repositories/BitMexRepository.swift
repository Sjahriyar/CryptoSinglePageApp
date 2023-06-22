//
//  BitMexRepository.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Combine
import Foundation

enum BitmexSubscriptionTopic: String {
    case orderBookL2, instrument, trade
}

fileprivate enum MessageOption: String {
    case subscribe, unsubscribe
}

protocol BitmexRepository {
    /// Establish webSocket connection
    func connect()

    func disconnect()

    func suspend()

    /**
     Subscribe to topics
     - Parameter topics: Topic keys with instruments. ex: `[.trade: XBTUSD]`
     */
    func subscribe(to topics: [BitmexSubscriptionTopic: String]) throws

    /**
     Unsubscribe from topics
     - Parameter topics: Topic keys with instruments. ex: `[.trade: XBTUSD]`
     */
    func unsubscribe(from topics: [BitmexSubscriptionTopic: String]) throws

    func unsubscribeFromAllTopics() throws

    var messagePublisher: PassthroughSubject<String, Error> { get }
}

final class DefaultBitmexRepository {
    private var webSocketStream: WebSocketStream?

    private var topics = [BitmexSubscriptionTopic: String]()

    private lazy var decoder = JSONDecoder()

    var messagePublisher = PassthroughSubject<String, Error>()

    init(
        url: String,
        session: URLSession = .shared
    ) {
        if let url = URL(string: url) {
            self.webSocketStream = WebSocketStream(url: url, session: session)
        }
    }

    private func listenToMessage() async throws {
        guard let webSocketStream else { return }

        for try await message in webSocketStream {
            if case let .string(message) = message {
                self.messagePublisher.send(message)
            } else {
                self.messagePublisher.send(completion: .failure(WebSocketStreamError.expectedStringMessage))
            }
        }
    }
}

// MARK: - CurrencyDetailRepository

extension DefaultBitmexRepository: BitmexRepository {
    public func connect() {
        webSocketStream?.connect()
    }

    public func disconnect() {
        printIfDebug("Disconnecting from: \(self.topics))")
        webSocketStream?.cancel()
    }

    public func subscribe(to topics: [BitmexSubscriptionTopic: String]) throws {
        self.topics = topics
        let message = try generateTopicMessage(.subscribe, topics: topics)

        Task {
            try await webSocketStream?.sendMessage(message)

            printIfDebug("Subscribed to: \(topics)")

            try await self.listenToMessage()
        }
    }

    public func unsubscribe(from topics: [BitmexSubscriptionTopic: String]) throws {
        let message = try generateTopicMessage(.unsubscribe, topics: topics)

        printIfDebug("Unsubscribed from: \(topics)")

        Task {
            try await webSocketStream?.sendMessage(message)
        }
    }

    public func unsubscribeFromAllTopics() throws {
        let message = try generateTopicMessage(.unsubscribe, topics: self.topics)

        Task {
            try await webSocketStream?.sendMessage(message)
            printIfDebug("Unsubscribed from all topics: \(self.topics)")
        }
    }

    /// Temporary suspend tasks
    public func suspend() {
        webSocketStream?.suspend()
    }
}

private extension BitmexRepository {
    func generateTopicMessage(
        _ messageOption: MessageOption,
        topics: [BitmexSubscriptionTopic: String]
    ) throws -> String {
        let args = topics.map { key, value in
            "\(key):\(value)"
        }

        let dto = BitMexRequestDTO(op: messageOption.rawValue, args: args)

        return try dto.generateMessage()
    }
}
