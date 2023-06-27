//
//  File.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation

public typealias RPCID = UInt32

public struct RequestEnvelope<P: Encodable>: Encodable {
    public let jsonrpc: String
    public let id: RPCID
    public let method: String
    public let params: P
}

public struct ResponseError<T>: Error {
    public let code: Int
    public let message: String
    public let data: T?
}

extension ResponseError: Decodable where T: Decodable {}
extension ResponseError: Encodable where T: Encodable {}

public struct ResponseEnvelope<R, E> {
    public let jsonrpc: String
    public let id: RPCID
    public let result: R?
    public let error: ResponseError<E>?
}

extension ResponseEnvelope: Decodable where R: Decodable, E: Decodable {}
extension ResponseEnvelope: Encodable where R: Encodable, E: Encodable {}

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
    case request(id: RPCID, method: String, jsonrpc: String)
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
                    return .request(id: id, method: method, jsonrpc: self.jsonrpc)
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
