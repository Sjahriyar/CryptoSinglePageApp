//
//  OrderBookListView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 17/06/2023.
//

import SwiftUI

struct OrderBookListView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                InlineHeaderView(
                    leadingTitle: "Qty",
                    centerTitle: "Price (USD)",
                    trailingTitle: "Qty"
                )
                .padding(
                    EdgeInsets(
                        top: Constants.spacingSmall,
                        leading: Constants.spacingDefault,
                        bottom: Constants.spacingMedium,
                        trailing: Constants.spacingDefault
                    )
                )

                Divider()

                if viewModel.orderBookBuyItems.isEmpty && viewModel.orderBookSellItems.isEmpty {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else {
                    orderBookListView()
                        .frame(height: geometry.size.height)
                }
            } // VSTACK
            .alert(
                viewModel.error?.localizedDescription ?? "Unexpected error",
                isPresented: $viewModel.hasError) {
                    Button("Retry") {
                        viewModel.reconnect()
                    }

                    Button("OK") { }
                }
        } // GEOMETRY READER
    }
}

// MARK: - View Components

private extension OrderBookListView {
    @ViewBuilder
    func orderBookListView() -> some View {
        ScrollView(showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(viewModel.orderBookBuyItems, id: \.self) { item in
                        OrderBookListRowView(
                            viewModel: OrderBookListRowView.ViewModel(orderBookItem: item, totalSize: viewModel.totalBuySize)
                        )
                    }
                }

                VStack(spacing: 0) {
                    ForEach(viewModel.orderBookSellItems, id: \.self) { item in
                        OrderBookListRowView(
                            viewModel: OrderBookListRowView.ViewModel(orderBookItem: item, totalSize: viewModel.totalSellSize)
                        )
                    }
                }
            }
            .padding([.horizontal, .bottom])
        } // SCROLL VIEW
    }
}

// MARK: - PreviewProvider

struct OrderBookListView_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookListView(viewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue))
    }
}
