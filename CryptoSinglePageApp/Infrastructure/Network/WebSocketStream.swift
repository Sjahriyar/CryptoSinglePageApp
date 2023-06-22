//
//  WebSocketStream.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 17/06/2023.
//

import Foundation

typealias AsyncWebSocketStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>
typealias AsyncIterator = AsyncWebSocketStream.Iterator

protocol WebSocketStreamable {
    func connect()
    /// A task, while suspended, produces no network traffic and isn’t subject to timeouts. Call resume() to resume data transfer.
    func suspend()
    func makeAsyncIterator() -> AsyncIterator
    func sendMessage(_ message: String) async throws
    func cancel()
}

enum WebSocketStreamError: Error {
    case expectedStringMessage
    case expectedDataMessage
    case unknownMessageReceived
    case connectionFailed
    case corruptData
}

class WebSocketStream: AsyncSequence, WebSocketStreamable {
    typealias Element = URLSessionWebSocketTask.Message

    private var continuation: AsyncWebSocketStream.Continuation?
    private let socket: URLSessionWebSocketTask

    init(url: URL, session: URLSession = URLSession.shared) {
        self.socket = session.webSocketTask(with: url)
    }

    private lazy var stream: AsyncWebSocketStream = {
        return AsyncWebSocketStream { continuation in
            self.continuation = continuation
            self.continuation?.onTermination = { @Sendable [socket] _ in
                socket.cancel()
            }

            listenForMessages()
        }
    }()

    private func listenForMessages() {
        guard socket.closeCode == .invalid else {
            continuation?.finish()
            return
        }

        socket.receive { [weak self] result in
            guard let continuation = self?.continuation else {
                printIfDebug("Continuation is nil", type: .error)
                return
            }

            switch result {
            case .success(let message):
                continuation.yield(message)
                self?.listenForMessages()
            case .failure(let error):
                continuation.finish(throwing: error)
            }
        }
    }

    deinit {
        continuation?.finish()
    }

    func connect() {
        socket.resume()
        printIfDebug("Socket connecting to \(socket.currentRequest?.url?.absoluteString ?? "")")
    }

    func suspend() {
        socket.suspend()
        printIfDebug("Connection suspended \(socket.originalRequest?.url?.absoluteString ?? "")")
    }

    func makeAsyncIterator() -> AsyncIterator {
        socket.resume()
        listenForMessages()

        return stream.makeAsyncIterator()
    }

    func sendMessage(_ message: String) async throws {
        let socketMessage = Element.string(message)

        try await socket.send(socketMessage)
    }

    func cancel() {
        socket.cancel(with: .goingAway, reason: nil)
        continuation?.finish()
        printIfDebug("Socket canceled")
    }
}
