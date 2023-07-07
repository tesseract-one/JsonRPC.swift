//
//  PersistentClient.swift
//  
//
//  Created by Yehor Popovych on 07/07/2023.
//

import Foundation
import ContextCodable

public extension ServiceCore where Connection: PersistentConnection {
    private func call<Params, Res, Err>(
        id: RPCID, encoded: Result<Data, RequestError<Params, Err>>,
        response callback: @escaping RequestCallback<Params, Res, Err>,
        deserializer: @escaping (Data) -> Result<Res, RequestError<Params, Err>>
    ) {
        //return error if encode failed
        guard case let .success(data) = encoded else {
            self.queue.async { callback(encoded.map { $0 as! Res }) }
            return
        }
        
        let debug = self.debug
        if debug { print("Request[\(id)]: \(String(data: data, encoding: .utf8) ?? "<error>")") }
        
        register(id: id) { data in
            let response = deserializer(data)
            self.queue.async { callback(response) }
        }
        
        self.connection.send(data: data)
    }
    
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, method: method, params: params, Res.self, Err.self)
        }
    }
    
    func call<Params: ContextEncodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        context: Params.EncodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, context: context, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, method: method, params: params, res, err)
        }
    }
    
    func call<Params: Encodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        context: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, context: context,
                             method: method, params: params, res, err)
        }
    }
    
    func call<Params: ContextEncodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        encoding econtext: Params.EncodingContext,
        decoding dcontext: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, context: econtext, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, context: dcontext,
                             method: method, params: params, res, err)
        }
    }
}
