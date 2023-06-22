//
//  BitMexRequestDTO.swift
//  CryptoSinglePageApp
//
//  Created by Sh on 17/06/2023.
//

import Foundation

struct BitMexRequestDTO: Encodable {
    let op: String
    let args: [String]
}

extension BitMexRequestDTO {
    enum BitMexRequestDTOError: Error {
        case failedCreatingJSONString
    }

    func generateMessage() throws -> String {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(self)

        guard let message = String(data: encoded, encoding: .utf8) else {
            throw BitMexRequestDTOError.failedCreatingJSONString
        }

        return message
    }
}
