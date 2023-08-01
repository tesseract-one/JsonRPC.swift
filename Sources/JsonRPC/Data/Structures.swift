//
//  File.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation
import ContextCodable

public typealias RPCID = UInt32

public struct RequestEnvelope<P> {
    public let jsonrpc: String
    public let id: RPCID
    public let method: String
    public let params: P
}

extension RequestEnvelope: Encodable where P: Encodable {}
extension RequestEnvelope: ContextEncodable where P: ContextEncodable {
    public typealias EncodingContext = P.EncodingContext
    
    public func encode(to encoder: Encoder, context: EncodingContext) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(params, forKey: .params, context: context)
    }
}

#if swift(>=5.5)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension RequestEnvelope: Foundation.EncodableWithConfiguration
    where P: Foundation.EncodableWithConfiguration
{
    public typealias EncodingConfiguration = P.EncodingConfiguration
    
    public func encode(to encoder: Encoder, configuration: P.EncodingConfiguration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(params, forKey: .params, configuration: configuration)
    }
}
#endif

public protocol AsAnyResponseError {
    var anyResponseError: ResponseError<Any> { get }
}

public struct ResponseError<T>: Error, AsAnyResponseError {
    public let code: Int
    public let message: String
    public let data: T?
    
    public var anyResponseError: ResponseError<Any> {
        ResponseError<_>(code: code, message: message, data: data)
    }
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

extension ResponseEnvelope: ContextDecodable where R: ContextDecodable, E: Decodable {
    public typealias DecodingContext = R.DecodingContext
    public init(from decoder: Decoder, context: DecodingContext) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        id = try container.decode(RPCID.self, forKey: .id)
        result = try container.decodeIfPresent(R.self, forKey: .result, context: context)
        error = try container.decodeIfPresent(ResponseError<E>.self, forKey: .error)
    }
}
extension ResponseEnvelope: ContextEncodable where R: ContextEncodable, E: Encodable {
    public typealias EncodingContext = R.EncodingContext
    public func encode(to encoder: Encoder, context: EncodingContext) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(result, forKey: .result, context: context)
        try container.encodeIfPresent(error, forKey: .error)
    }
}

#if swift(>=5.5)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension ResponseEnvelope: Foundation.DecodableWithConfiguration
    where R: Foundation.DecodableWithConfiguration, E: Decodable
{
    public typealias DecodingConfiguration = R.DecodingConfiguration
    public init(from decoder: Decoder, configuration: R.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        id = try container.decode(RPCID.self, forKey: .id)
        result = try container.decodeIfPresent(R.self, forKey: .result, configuration: configuration)
        error = try container.decodeIfPresent(ResponseError<E>.self, forKey: .error)
    }
}
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension ResponseEnvelope: Foundation.EncodableWithConfiguration
    where R: Foundation.EncodableWithConfiguration, E: Encodable
{
    public typealias EncodingConfiguration = R.EncodingConfiguration
    public func encode(to encoder: Encoder, configuration: R.EncodingConfiguration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(result, forKey: .result, configuration: configuration)
        try container.encodeIfPresent(error, forKey: .error)
    }
}
#endif

public struct NotificationEnvelope<P> {
    public let jsonrpc: String
    public let method: String
    public let params: P?
}

extension NotificationEnvelope: Decodable where P: Decodable {}

extension NotificationEnvelope: ContextDecodable where P: ContextDecodable {
    public typealias DecodingContext = P.DecodingContext
    public init(from decoder: Decoder, context: DecodingContext) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        method = try container.decode(String.self, forKey: .method)
        params = try container.decodeIfPresent(P.self, forKey: .params, context: context)
    }
}

#if swift(>=5.5)
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension NotificationEnvelope: Foundation.DecodableWithConfiguration
    where P: Foundation.DecodableWithConfiguration
{
    public typealias DecodingConfiguration = P.DecodingConfiguration
    public init(from decoder: Decoder, configuration: P.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        method = try container.decode(String.self, forKey: .method)
        params = try container.decodeIfPresent(P.self, forKey: .params, configuration: configuration)
    }
}
#endif

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
