//
//  Instrument.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Foundation

// Not using Data Transfer Object aka(DTO) here, because it requires
// a lot of expensive mapping.
struct Instrument: Decodable, Equatable {
    let table: BitmexTable
    let action: BitmexAction
    let data: [InstrumentData]
}

struct InstrumentData: Decodable, Equatable {
    let symbol: String
    let volume: Int?
    let totalVolume: Int?
    let openValue: Int?
    let lastPrice: Double?
    let fairPrice: Double?
    let markPrice: Double?
    let bidPrice: Double?
    let midPrice: Double?
    let askPrice: Double?
    let impactBidPrice: Double?
    let impactMidPrice: Double?
    let impactAskPrice: Double?
}
