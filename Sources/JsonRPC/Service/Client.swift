//
//  Client.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation
import ContextCodable

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
    
    func call<Params: ContextEncodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        context: Params.EncodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    )
    
    func call<Params: Encodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        context: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    )
    
    func call<Params: ContextEncodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        encoding econtext: Params.EncodingContext,
        decoding dcontext: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    )
    
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
    
    func call<Params: ContextEncodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        context: Params.EncodingContext,
        _ res: Res.Type, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, context: context, res, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params: ContextEncodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        context: Params.EncodingContext, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, context: context, Res.self, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params: Encodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        context: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, context: context, res, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params: Encodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        context: Res.DecodingContext, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, context: context, Res.self, err) {
                cont.resume(with: $0)
            }
        }
    }
    
    func call<Params: ContextEncodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        encoding econtext: Params.EncodingContext,
        decoding dcontext: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type
    ) async throws ->  Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params,
                      encoding: econtext,
                      decoding: dcontext, res, err) { cont.resume(with: $0) }
        }
    }
    
    func call<Params: ContextEncodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        encoding econtext: Params.EncodingContext,
        decoding dcontext: Res.DecodingContext, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params,
                      encoding: econtext,
                      decoding: dcontext, Res.self, err) { cont.resume(with: $0) }
        }
    }
}
#endif
