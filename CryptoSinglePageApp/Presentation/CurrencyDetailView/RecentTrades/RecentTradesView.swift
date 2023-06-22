//
//  RecentTradesView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 17/06/2023.
//

import SwiftUI

struct RecentTradesView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Constants.spacingMedium) {
                Text("Recent Trades")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary.opacity(0.6))
                    .font(.system(.headline, design: nil, weight: .semibold))

                Divider()

                InlineHeaderView(
                    leadingTitle: "Price (USD)",
                    centerTitle: "Qty",
                    trailingTitle: "Time"
                )

                Divider()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Constants.spacingMedium) {
                        ForEach(viewModel.recentTadesData, id: \.self) { item in
                            withAnimation {
                                RecentTradesRowView(viewModel: .init(recentTradeData: item))
                            }
                        }
                    }
                }
            } // VSTACK
            .padding()
            .alert(
                viewModel.error?.localizedDescription ?? "Unexpected error",
                isPresented: $viewModel.hasError) {
                    HStack {
                        Button("Retry") {
                            viewModel.reconnect()
                        }

                        Button("OK") { }
                    }

                }
        }
    }
}

// MARK: - PreviewProvider

struct RecentTradesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentTradesView(viewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue))
    }
}
