//
//  CurrencyDetailHeaderView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import SwiftUI

struct CurrencyDetailHeaderView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        HStack(spacing: Constants.spacingDefault) {
            lastPriceView(viewModel.lastPrice, isUp: viewModel.isPriceUp)

            VStack(spacing: Constants.spacingSmall) {
                Text("1,429.8")

                Text("+2.86%")
            }
            .foregroundColor(.green)

            Spacer()

            VStack(spacing: Constants.spacingMedium) {
                HStack {
                    Text("Index")
                        .foregroundColor(.gray)

                    Text("51,661.0")
                }


                HStack {
                    Text("Mark")
                        .foregroundColor(.gray)

                    Text("51,661.0")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .font(.system(size: 12))
    }
}

private extension CurrencyDetailHeaderView {
    @ViewBuilder
    func lastPriceView(_ lastPrice: String, isUp: Bool) -> some View{
        let color: Color = isUp ? .green : .red
        let icon = isUp ? "arrow.up" : "arrow.down"

        HStack {
            Text(lastPrice)
                .font(.system(.title, weight: .medium))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 24)
                .foregroundColor(color)
        }
        .frame(width: 160)
    }
}

struct CurrencyDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyDetailHeaderView(viewModel: .init(instrumentSymbol: InstrumentSymbol.XBTUSD.rawValue))
    }
}
