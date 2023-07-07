//
//  Client.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation
import ConfigurationCodable

public enum RequestError<Params, Error>: Swift.Error {
    case service(error: ServiceError)
    case empty //empty body has been returned in reply
    case reply(method: String, params: Params, error: ResponseError<Error>)
    case custom(description: String, cause: Swift.Error?)
}

public typealias RequestCallback<Params, Response, Error> = Callback<Response, RequestError<Params, Error>>

public protocol Callable {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    )
    
    func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration
    
    func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Res: ConfigurationCodable.DecodableWithConfiguration
    
    func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration,
            Res: ConfigurationCodable.DecodableWithConfiguration
    
    // TODO: Add Foundation based calls for Xcode 15+ and Swift 5.9+
}

public protocol Client: Callable {
    var debug: Bool { get set }
}

#if swift(>=5.5)
public extension Client {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, res, err) { cont.resume(with: $0) }
        }
    }
    
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, Res.self, err) { cont.resume(with: $0) }
        }
    }
    
    func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ res: Res.Type, _ err: Err.Type
    ) async throws -> Res where Params: ConfigurationCodable.EncodableWithConfiguration {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, configuration: configuration, res, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration, _ err: Err.Type
    ) async throws -> Res where Params: ConfigurationCodable.EncodableWithConfiguration {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, configuration: configuration, Res.self, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type
    ) async throws -> Res where Res: ConfigurationCodable.DecodableWithConfiguration {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, configuration: configuration, res, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration, _ err: Err.Type
    ) async throws -> Res where Res: ConfigurationCodable.DecodableWithConfiguration {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, configuration: configuration, Res.self, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type
    ) async throws ->  Res where
        Params: ConfigurationCodable.EncodableWithConfiguration,
        Res: ConfigurationCodable.DecodableWithConfiguration
    {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params,
                      encoding: econfiguration,
                      decoding: dconfiguration, res, err) { cont.resume(with: $0) }
        }
    }
    
    func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration, _ err: Err.Type
    ) async throws ->  Res where
        Params: ConfigurationCodable.EncodableWithConfiguration,
        Res: ConfigurationCodable.DecodableWithConfiguration
    {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params,
                      encoding: econfiguration,
                      decoding: dconfiguration, Res.self, err) { cont.resume(with: $0) }
        }
    }
}
#endif
