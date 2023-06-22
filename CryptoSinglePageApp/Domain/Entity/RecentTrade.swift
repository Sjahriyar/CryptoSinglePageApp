//
//  RecentTrade.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Foundation

// Not using Data Transfer Object aka(DTO) here, because it requires
// a lot of expensive mapping.
struct RecentTrade: Decodable, Equatable {
    let table: BitmexTable
    let action: BitmexAction
    let data: [RecentTradeData]
}

struct RecentTradeData: Decodable {
    let timestamp: Date
    let symbol: String
    let side: SideType
    let size: Int
    let price: Double
    let tickDirection: String
    let trdMatchID: String
    let grossValue: Int
    let homeNotional: Double
    let foreignNotional: Double
    let trdType: String

    enum SideType: String, Decodable {
        case buy = "Buy"
        case sell = "Sell"
    }

    enum CodingKeys: String, CodingKey {
        case timestamp, symbol, side, size, price, tickDirection, trdMatchID, grossValue, homeNotional, foreignNotional, trdType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let formattedTimestamp = formatter.date(from: timestampString) {
            timestamp = formattedTimestamp
        } else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Invalid timestamp format")
        }

        symbol = try container.decode(String.self, forKey: .symbol)
        side = try container.decode(SideType.self, forKey: .side)
        size = try container.decode(Int.self, forKey: .size)
        price = try container.decode(Double.self, forKey: .price)
        tickDirection = try container.decode(String.self, forKey: .tickDirection)
        trdMatchID = try container.decode(String.self, forKey: .trdMatchID)
        grossValue = try container.decode(Int.self, forKey: .grossValue)
        homeNotional = try container.decode(Double.self, forKey: .homeNotional)
        foreignNotional = try container.decode(Double.self, forKey: .foreignNotional)
        trdType = try container.decode(String.self, forKey: .trdType)
    }
}

extension RecentTradeData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(trdMatchID)
    }
}
