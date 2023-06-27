//
//  AnyEncodable.swift
//  
//
//  Created by Yehor Popovych on 21/06/2023.
//

import Foundation

public struct AnyEncodable: Encodable {
    public let encoder: (Encoder) throws -> Void
    
    public init<T: Encodable>(_ value: T) {
        self.encoder = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.encoder(encoder)
    }
}

public extension Encodable {
    var any: AnyEncodable { AnyEncodable(self) }
}
