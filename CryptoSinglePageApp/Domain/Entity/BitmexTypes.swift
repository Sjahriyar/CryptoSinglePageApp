//
//  BitmexTypes.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 19/06/2023.
//

import Foundation

enum BitmexAction: String, Decodable {
    case partial
    case delete
    case update
    case insert
}

enum BitmexTable: String, Decodable {
    case instrument, orderBookL2, trade
}
