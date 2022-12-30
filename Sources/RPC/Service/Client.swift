//
//  File.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation

public enum RequestError<Params: Encodable, Error: Decodable>: Swift.Error {
    case service(error: ServiceError)
    case empty //empty body has been returned in reply
    case reply(method: String, params: Params, error: ResponseError<Error>)
    case custom(description: String, cause: Swift.Error?)
}

public typealias RequestCallback<Params: Encodable, Response: Decodable, Error: Decodable> = Callback<Response, RequestError<Params, Error>>

public protocol Client {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    )
}

extension ServiceCore {
    static func deserialize<Res: Decodable, Params: Encodable, Err: Decodable>(data: Data, decoder: ContentDecoder, method: String, params: Params, _ res: Res.Type, _ err: Err.Type) -> Result<Res, RequestError<Params, Err>> {
        let envelope:Result<ResponseEnvelope<Res, Err>, ServiceError> = decoder.tryDecode(ResponseEnvelope<Res, Err>.self, from: data).mapError {
            .codec(cause: $0)
        }
        
        let response:Result<Res, RequestError<Params, Err>> = envelope.mapError { e in
            .service(error: e)
        }.flatMap { envelope in
             guard let data = envelope.result else {
                 guard let error = envelope.error else {
                     return .failure(.empty)
                 }
                 return .failure(.reply(method: method, params: params, error: error))
             }
             return .success(data)
         }
        
        return response
    }
    
    func serialize<Params: Encodable, Err: Decodable>(id: RPCID, method: String, params: Params, _ err: Err.Type) -> Result<Data, RequestError<Params, Err>> {
        let request = RequestEnvelope(jsonrpc: "2.0", id: id, method: method, params: params)
        return encoder.tryEncode(request).mapError(ServiceError.codec).mapError(RequestError<Params, Err>.service)
    }
}

public extension ServiceCore where Connection: SingleShotConnection {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let encoded = serialize(id: nextId(), method: method, params: params, Err.self)
        
        //return error if we can't encode
        guard case let .success(data) = encoded else {
            let dummy:Res? = nil
            //convert to callback result
            self.queue.async { callback(encoded.map { _ in dummy!}) }
            return
        }
        
        let decoder = self.decoder
        
        connection.request(data: data) { response in
            let data:Result<Data, RequestError<Params, Err>> = response
                .mapError(ServiceError.connection)
                .mapError {.service(error: $0)}
                .flatMap { data in
                    if let data = data {
                        return .success(data)
                    } else {
                        return .failure(.empty)
                    }
            }
            
            let response = data.flatMap {
                Self.deserialize(data: $0, decoder: decoder, method: method, params: params, res, err)
            }
            
            self.queue.async { callback(response) }
        }
    }
}

public extension ServiceCore where Connection: PersistentConnection {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, Err.self)
        
        //return error if we can't encode
        guard case let .success(data) = encoded else {
            let dummy:Res? = nil
            //convert to callback result
            self.queue.async { callback(encoded.map { _ in dummy!}) }
            return
        }
        
        let decoder = self.decoder
        
        register(id: id) { data in
            let response = Self.deserialize(data: data, decoder: decoder, method: method, params: params, res, err)
            
            self.queue.async { callback(response) }
        }
        
        self.connection.send(data: data)
    }
    
    func process(response: Data, id: RPCID, notFound:@escaping ()->Void) {
        queue.async {
            self.remove(id: id) { closure in
                guard let closure = closure else {
                    notFound()
                    return
                }
                closure(response)
            }
        }
    }
}

#if swift(>=5.5)
extension Client {
    public func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, res, err) { cont.resume(with: $0) }
        }
    }
    
    public func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ err: Err.Type
    ) async throws -> Res {
        try await withUnsafeThrowingContinuation { cont in
            self.call(method: method, params: params, Res.self, err) { cont.resume(with: $0) }
        }
    }
}
#endif
