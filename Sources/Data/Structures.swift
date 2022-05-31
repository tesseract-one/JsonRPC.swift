//
//  File.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation

import NIOConcurrencyHelpers

public typealias RPCID = UInt32

private var _id_current = NIOAtomic.makeAtomic(value: UInt32(1))

extension RPCID {
    static func next() -> RPCID {
        _id_current.add(1)
    }
}

public struct RequestEnvelope<P: Encodable>: Encodable {
    public let jsonrpc: String
    public let id: RPCID
    public let method: String
    public let params: P
}

public struct ResponseError<T> {
    public let code: Int
    public let message: String
    
    public let data:T?
}

extension ResponseError: Decodable where T: Decodable {
}

extension ResponseError: Encodable where T: Encodable {
}

public struct ResponseEnvelope<R: Decodable, E: Decodable>: Decodable {
    public let jsonrpc: String
    public let id: RPCID
    public let result: R?
    public let error: ResponseError<E>?
}

public struct NotificationEnvelope<P: Decodable>: Decodable {
    public let jsonrpc: String
    public let method: String
    public let params: P?
}

public struct EnvelopeHeader: Decodable {
    public let jsonrpc: String
    public let id: RPCID?
    public let method: String?
}

public enum EnvelopeMetadata {
    case request(id: RPCID, method: String)
    case response(id: RPCID)
    case notification(method: String)
    case unknown(version: String)
    case malformed //no id and method at the same time
}

public extension EnvelopeHeader {
    var metadata: EnvelopeMetadata {
        get {
            guard self.jsonrpc == "1.0" || self.jsonrpc == "1.1" || self.jsonrpc == "2.0" else {
                return .unknown(version: self.jsonrpc)
            }
            
            if let id = self.id {
                if let method = self.method {
                    return .request(id: id, method: method)
                } else {
                    return .response(id: id)
                }
            } else {
                if let method = self.method {
                    return .notification(method: method)
                } else {
                    return .malformed
                }
            }
        }
    }
}

public enum Nil : Decodable, Encodable {
    case `nil`
}

extension Nil {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .nil
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Must be nil"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encodeNil()
    }
}

extension Nil: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

/*public struct EventEnvelope<M: Decodable>: Decodable {
    public let jsonrpc: String
    public let method: String
    public let params: M
}*/
