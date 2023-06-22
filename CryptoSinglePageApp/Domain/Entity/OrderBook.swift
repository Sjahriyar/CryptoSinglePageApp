//
//  OrderBook.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 18/06/2023.
//

import Foundation

// Not using Data Transfer Object aka(DTO) here, because it requires
// a lot of expensive mapping.
struct OrderBook: Decodable, Equatable {
    let table: BitmexTable
    let action: BitmexAction
    let data: [OrderBookItem]
}

struct OrderBookItem: Decodable {
    let symbol: String
    let id: Int
    let side: SideType
    let size: Int
    let price: Double
    let timestamp: Date

    enum SideType: String, Decodable {
        case buy = "Buy"
        case sell = "Sell"
    }

    enum CodingKeys: String, CodingKey {
        case symbol, id, side, size, price, timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        id = try container.decode(Int.self, forKey: .id)
        side = try container.decode(SideType.self, forKey: .side)
        size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 0
        price = try container.decode(Double.self, forKey: .price)

        let dateString = try container.decode(String.self, forKey: .timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: dateString) {
            timestamp = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .timestamp,
                in: container,
                debugDescription: "Expected date string to be ISO8601-formatted."
            )
        }
    }
}

extension OrderBookItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
        hasher.combine(id)
        hasher.combine(side)
        hasher.combine(size)
        hasher.combine(price)
        hasher.combine(timestamp)
    }

    static func == (lhs: OrderBookItem, rhs: OrderBookItem) -> Bool {
        return lhs.symbol == rhs.symbol &&
        lhs.id == rhs.id &&
        lhs.side == rhs.side &&
        lhs.size == rhs.size &&
        lhs.price == rhs.price &&
        lhs.timestamp == rhs.timestamp
    }
}
