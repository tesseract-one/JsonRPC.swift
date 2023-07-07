//
//  Codec.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation
import ContextCodable

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
    func encode<T: ContextEncodable>(
        _ value: T, context: T.EncodingContext
    ) throws -> Data
    // TODO: Add Foundation based encode call for Xcode 15+ and Swift 5.9+
}

public protocol ContentDecoder: ContentTypeAware {
    var context: [CodingUserInfoKey: Any] { get set }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func decode<T: ContextDecodable>(
        _ type: T.Type, from data: Data, context: T.DecodingContext
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
    
    public func tryEncode<T: ContextEncodable>(
        _ value: T, context: T.EncodingContext
    ) -> Result<Data, CodecError> {
        Result {
            try self.encode(value, context: context)
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
    
    func tryDecode<T: ContextDecodable>(
        _ type: T.Type, from data: Data, context: T.DecodingContext
    ) -> Result<T, CodecError> {
        Result {
            try self.decode(type, from: data, context: context)
        }.mapError { e in
            if let e = e as? DecodingError {
                return .decoding(cause: e)
            } else {
                return .unknown(cause: e)
            }
        }
    }
}
