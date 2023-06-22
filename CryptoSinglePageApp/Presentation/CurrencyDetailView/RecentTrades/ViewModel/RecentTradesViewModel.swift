//
//  RecentTradesViewModel.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Combine
import Foundation

extension RecentTradesView {
    @MainActor
    final class ViewModel: ObservableObject {
        private let instrumentSymbol: String
        private let useCase: RecentTradesUseCase

        @Published var error: Error? = nil
        @Published var hasError = false
        @Published var recentTadesData = [RecentTradeData]()

        private var cancellables = Set<AnyCancellable>()

        init(
            instrumentSymbol: String,
            useCase: RecentTradesUseCase = DefaultRecentTradesUseCase()
        ) {
            self.instrumentSymbol = instrumentSymbol
            self.useCase = useCase
            self.useCase.start()

            startListening()
        }

        deinit {
            useCase.unsubscribeFromTradeUpdates(forInstrument: self.instrumentSymbol)
        }

        func connect() {
            useCase.start()
            useCase.connect()
        }

        func stopListening() {
            useCase.unsubscribeFromTradeUpdates(forInstrument: instrumentSymbol)
        }

        func suspendTask() {
            useCase.suspendTask()
        }

        func startListening() {
            do {
                try self.useCase.subscribeToTradeUpdates(forInstrument: self.instrumentSymbol)

                self.useCase.messagePublisher
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            printIfDebug("Message publisher received")
                        case .failure(let error):
                            printIfDebug(error.localizedDescription, type: .error)
                        }
                    } receiveValue: { [weak self] recentTade in
                        guard let `self` else { return }

                        // I think this approach is faster than insertion sort or Queue
                        self.recentTadesData.append(contentsOf: recentTade.data)
                        self.recentTadesData.sort(by: { $0.timestamp > $1.timestamp })

                        self.recentTadesData = Array(self.recentTadesData.prefix(30))
                    }
                    .store(in: &cancellables)
            } catch {
                self.useCase.unsubscribeFromTradeUpdates(forInstrument: self.instrumentSymbol)
                self.error = error
                self.hasError = true
            }
        }

        func reconnect() {
            error = nil
            hasError = false

            startListening()
        }
    }
}
