//
//  SingleShotClient.swift
//  
//
//  Created by Yehor Popovych on 07/07/2023.
//

import Foundation
import ConfigurationCodable

public extension ServiceCore where Connection: SingleShotConnection {
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
        
        connection.request(data: data) { response in
            let data: Result<Data, RequestError<Params, Err>> = response
                .mapError { .service(error: .connection(cause: $0)) }
                .flatMap { data in
                    if let data = data {
                        return .success(data)
                    } else {
                        return .failure(.empty)
                    }
                }
            
            if debug { print("Response[\(id)]: \(data.map { String(data: $0, encoding: .utf8) })") }
            
            let response = data.flatMap(deserializer)
            self.queue.async { callback(response) }
        }
    }
    
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, method: method, params: params, res, err)
        }
    }
    
    func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, configuration: configuration, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, method: method, params: params, res, err)
        }
    }
    
    func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) where Res: ConfigurationCodable.DecodableWithConfiguration {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, configuration: configuration,
                             method: method, params: params, res, err)
        }
    }
    
    func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration,
            Res: ConfigurationCodable.DecodableWithConfiguration
    {
        let id = nextId()
        let encoded = serialize(id: id, method: method, params: params, configuration: econfiguration, Err.self)
        
        let decoder = self.decoder
        call(id: id, encoded: encoded, response: callback) { data in
            Self.deserialize(data: data, decoder: decoder, configuration: dconfiguration,
                             method: method, params: params, res, err)
        }
    }
}
