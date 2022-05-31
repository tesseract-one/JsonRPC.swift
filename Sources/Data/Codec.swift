//
//  File.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation

public enum ContentType : String {
    public typealias RawValue = String
    
    init(_ raw: String) {
        self.init(rawValue: raw)!
    }
    
    case json = "application/json"
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
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public protocol ContentDecoder: ContentTypeAware {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
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
}

extension ContentDecoder {
    public func tryDecode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, CodecError> {
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
}
