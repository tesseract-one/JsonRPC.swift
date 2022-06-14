//
//  Nil.swift
//  
//
//  Created by Yehor Popovych on 14.06.2022.
//

import Foundation

public struct Nil: Codable, Equatable, Hashable {
    public static let `nil` = Nil()
}

extension Nil {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Must be nil. Found some value"
            )
        }
        self.init()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

extension Nil: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init()
    }
}
