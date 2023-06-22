//
//  RecentTradesRowView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 20/06/2023.
//

import SwiftUI

struct RecentTradesRowView: View {
    @StateObject var viewModel: ViewModel
    @State private var willHighlight = true

    var body: some View {
        let color: Color = viewModel.side == .buy ? .green : .red

        HStack(spacing: Constants.spacingMedium) {
            Text(viewModel.price)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.quantity)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.leading, Constants.spacingLarge)
                .multilineTextAlignment(.leading)

            Text(viewModel.time)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(.footnote))
        .fontWeight(.semibold)
        .foregroundColor(color)
        .background(willHighlight ? color.opacity(0.2) : Color.clear)
        .animation(.easeOut(duration: 0.2), value: willHighlight)
        .onAppear {
            withAnimation {
                willHighlight.toggle()
            }
        }
    }
}

struct RecentTradesRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecentTradesRowView(
            viewModel: .init(recentTradeData: RecentTrade.Mock.generateRecentTrades()!.data.first!)
        )
    }
}
