//
//  OrderBookListRowView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import SwiftUI

struct OrderBookListRowView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        HStack(spacing: 0) {
            if !viewModel.isBuy {
                priceView()
                    .padding(.trailing, Constants.spacingMedium)

                Spacer()
            }

            Text(viewModel.size.toString() ?? viewModel.size.formatted())

            if viewModel.isBuy {
                Spacer()

                priceView()
                    .padding(.leading, Constants.spacingMedium)
            }
        }
        .clipped()
        .font(.system(.footnote))
    }
}

private extension OrderBookListRowView {
    @ViewBuilder
    func priceView() -> some View {
        let relativeVolumeWidth = viewModel.calculateRelativeVolumeWidth(maxWidth: 150)
        let isBuy = viewModel.isBuy
        let color: Color = isBuy ? .green : .red

        Text(viewModel.price)
            .padding(Constants.spacingMedium)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .overlay(alignment: isBuy ? .trailing : .leading) {
                Rectangle()
                    .fill(color.opacity(0.12))
                    .frame(width: relativeVolumeWidth)
            }
    }
}

struct OrderBookListRowView_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookListRowView(
            viewModel: .init(
                orderBookItem: OrderBook.Mock.generateOrderBook()!.data[2],
                totalSize: 1.9570944674444861
            )
        )
    }
}
