//
//  CurrencyDetailView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 16/06/2023.
//

import SwiftUI

struct CurrencyDetailView: View {
    private enum SegmentItems: String, CaseIterable {
        case orderBook = "Oder book"
        case recentTrades = "Recent trades"
    }

    @State private var selectedSegmentItem: SegmentItems = .orderBook
    @State private var selectedIndex: Int = 0

    @StateObject var viewModel: ViewModel

    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        NavigationView {
            VStack {
                CurrencyDetailHeaderView(viewModel: viewModel.headerViewModel)
                    .padding()

                SegmentedControlView(
                    selectedIndex: $selectedIndex,
                    titles: ["Order Book", "Recent Trades"]
                )
                .padding(.horizontal)

                if selectedIndex == 0 {
                    OrderBookListView(viewModel: viewModel.orderBookViewModel)
                } else {
                    RecentTradesView(viewModel: viewModel.recentOrderViewModel)
                }
            } // VSTACK
            .navigationTitle("XBT.USDT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "star")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .active:
                    viewModel.startTasks()
                case .inactive:
                    break
                case .background:
                    viewModel.suspendTasks()
                @unknown default:
                    assertionFailure("Unhandled case")
                }
            }
        } // NAVIGATION VIEW
    }
}

// MARK: - PreviewProvider

struct CurrencyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyDetailView(
            viewModel: .init(
                orderBookViewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue),
                recentOrderViewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue),
                headerViewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue)
            )
        )
    }
}
