//
//  InlineHeaderView.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 20/06/2023.
//

import SwiftUI

struct InlineHeaderView: View {
    let leadingTitle: String
    let centerTitle: String
    let trailingTitle: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(leadingTitle)

                Spacer()

                Text(centerTitle)

                Spacer()

                Text(trailingTitle)
            }
            .font(.system(size: 12))
            .foregroundColor(.secondary)
        }
    }
}

struct InlineHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        InlineHeaderView(leadingTitle: "Price (USD)", centerTitle: "Qty", trailingTitle: "Time")
    }
}
