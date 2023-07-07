//
//  AnyEncodable.swift
//  
//
//  Created by Yehor Popovych on 21/06/2023.
//

import Foundation
import ConfigurationCodable

public struct AnyEncodable: Encodable {
    public let encoder: (Encoder) throws -> Void
    
    public init<T: Encodable>(_ value: T) {
        self.encoder = { encoder in
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }
    
    public init<T: ConfigurationCodable.EncodableWithConfiguration>(
        _ value: T, configuration: T.EncodingConfiguration
    ) {
        self.encoder = { try value.encode(to: $0, configuration: configuration) }
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.encoder(encoder)
    }
}

public extension Encodable {
    var any: AnyEncodable { AnyEncodable(self) }
}

public extension ConfigurationCodable.EncodableWithConfiguration {
    func any(configuration: EncodingConfiguration) -> AnyEncodable {
        AnyEncodable(self, configuration: configuration)
    }
}
