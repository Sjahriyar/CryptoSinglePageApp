//
//  CurrencyDetailHeaderViewModel.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Combine
import Foundation

extension CurrencyDetailHeaderView {
    @MainActor
    final class ViewModel: ObservableObject {
        private let instrumentSymbol: String
        private let useCase: CurrencyDetailHeaderViewUseCase

        @Published var lastPrice: String = ""
        @Published var isPriceUp: Bool = true
        @Published var error: Error? = nil

        private var cancellables = Set<AnyCancellable>()

        init(
            instrumentSymbol: String,
            useCase: CurrencyDetailHeaderViewUseCase = DefaultCurrencyDetailHeaderViewUseCase()
        ) {
            self.instrumentSymbol = instrumentSymbol
            self.useCase = useCase
            self.useCase.start()

            startListetning()
        }

        deinit {
            useCase.unsubscribeFromInstrument(self.instrumentSymbol)
        }

        func connect() {
            useCase.start()
            useCase.connect()
        }

        func suspendTask() {
            useCase.suspendTask()
        }

        func stopListening() {
            useCase.unsubscribeFromInstrument(self.instrumentSymbol)
        }

        func startListetning() {
            do {
                try self.useCase.subscribeToInstrument(self.instrumentSymbol)

                self.useCase.messagePublisher
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            printIfDebug("Message publisher received")
                        case .failure(let error):
                            printIfDebug(error.localizedDescription, type: .error)
                        }
                    } receiveValue: { [weak self] instument in
                        guard let `self` else { return }

                        if let lastPrice = instument.data.first?.lastPrice?.toString() {
                            self.isPriceUp = self.lastPrice < lastPrice
                            self.lastPrice = lastPrice
                        }
                    }
                    .store(in: &cancellables)
            } catch {
                self.error = error
            }
        }
    }
}
