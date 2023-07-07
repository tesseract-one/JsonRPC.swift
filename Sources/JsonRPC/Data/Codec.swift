//
//  Codec.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation
import ConfigurationCodable

public struct ContentType: RawRepresentable {
    public typealias RawValue = String
    public let rawValue: String
    
    public init(_ name: String) {
        rawValue = name
    }
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static let json = ContentType("application/json")
}

public enum CodecError: Error {
    case encoding(cause: EncodingError)
    case decoding(cause: DecodingError)
    case unknown(cause: Error?)
}

public protocol ContentTypeAware {
    var contentType: ContentType {get}
}

public protocol ContentEncoder: ContentTypeAware {
    var context: [CodingUserInfoKey: Any] { get set }
    
    func encode<T: Encodable>(_ value: T) throws -> Data
    func encode<T: ConfigurationCodable.EncodableWithConfiguration>(
        _ value: T, configuration: T.EncodingConfiguration
    ) throws -> Data
    // TODO: Add Foundation based encode call for Xcode 15+ and Swift 5.9+
}

public protocol ContentDecoder: ContentTypeAware {
    var context: [CodingUserInfoKey: Any] { get set }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func decode<T: ConfigurationCodable.DecodableWithConfiguration>(
        _ type: T.Type, from data: Data, configuration: T.DecodingConfiguration
    ) throws -> T
    // TODO: Add Foundation based decode call for Xcode 15+ and Swift 5.9+
}

extension ContentEncoder {
    public func tryEncode<T: Encodable>(_ value: T) -> Result<Data, CodecError> {
        Result {
            try self.encode(value)
        }.mapError { e in
            if let e = e as? EncodingError {
                return .encoding(cause: e)
            } else {
                return .unknown(cause: e)
            }
        }
    }
    
    public func tryEncode<T: ConfigurationCodable.EncodableWithConfiguration>(
        _ value: T, configuration: T.EncodingConfiguration
    ) -> Result<Data, CodecError> {
        Result {
            try self.encode(value, configuration: configuration)
        }.mapError { e in
            if let e = e as? EncodingError {
                return .encoding(cause: e)
            } else {
                return .unknown(cause: e)
            }
        }
    }
}

public extension ContentDecoder {
    func tryDecode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, CodecError> {
        Result {
            try self.decode(type, from: data)
        }.mapError { e in
            if let e = e as? DecodingError {
                return .decoding(cause: e)
            } else {
                return .unknown(cause: e)
            }
        }
    }
    
    func tryDecode<T: ConfigurationCodable.DecodableWithConfiguration>(
        _ type: T.Type, from data: Data, configuration: T.DecodingConfiguration
    ) -> Result<T, CodecError> {
        Result {
            try self.decode(type, from: data, configuration: configuration)
        }.mapError { e in
            if let e = e as? DecodingError {
                return .decoding(cause: e)
            } else {
                return .unknown(cause: e)
            }
        }
    }
}
