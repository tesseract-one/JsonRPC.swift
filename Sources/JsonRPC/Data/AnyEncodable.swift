//
//  AnyEncodable.swift
//  
//
//  Created by Yehor Popovych on 21/06/2023.
//

import Foundation
import ContextCodable

public struct AnyEncodable: Encodable, CustomStringConvertible {
    public let value: Any
    public let encoder: (Encoder, Any) throws -> Void
    
    public init<T: Encodable>(_ value: T) {
        self.value = value
        self.encoder = { encoder, value in
            var container = encoder.singleValueContainer()
            try container.encode(value as! T)
        }
    }
    
    public init<T: ContextEncodable>(
        _ value: T, context: T.EncodingContext
    ) {
        self.value = value
        self.encoder = { try ($1 as! T).encode(to: $0, context: context) }
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.encoder(encoder, value)
    }
    
    public var description: String { "\(value)" }
}

public extension Encodable {
    var any: AnyEncodable { AnyEncodable(self) }
}

public extension ContextEncodable {
    func any(context: EncodingContext) -> AnyEncodable {
        AnyEncodable(self, context: context)
    }
}
