//
//  ServiceCore+Coding.swift
//  
//
//  Created by Yehor Popovych on 07/07/2023.
//

import Foundation
import ConfigurationCodable

extension ServiceCore {
    private static func mapEnvelope<Res, Params, Err>(
        method: String, params: Params, response: Result<ResponseEnvelope<Res, Err>, CodecError>
    ) ->  Result<Res, RequestError<Params, Err>> {
        response
            .mapError { .service(error: .codec(cause: $0)) }
            .flatMap { envelope in
                 guard let data = envelope.result else {
                     guard let error = envelope.error else {
                         return .failure(.empty)
                     }
                     return .failure(.reply(method: method, params: params, error: error))
                 }
                 return .success(data)
             }
    }
    
    static func deserialize<Res, Params, Err>(
        data: Data, decoder: ContentDecoder,
        configuration: Res.DecodingConfiguration,
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type
    ) -> Result<Res, RequestError<Params, Err>> where
        Res: ConfigurationCodable.DecodableWithConfiguration, Err: Decodable
    {
        let envelope = decoder.tryDecode(
            ResponseEnvelope<Res, Err>.self, from: data, configuration: configuration
        )
        return mapEnvelope(method: method, params: params, response: envelope)
    }
    
    static func deserialize<Res: Decodable, Params, Err: Decodable>(
        data: Data, decoder: ContentDecoder,
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type
    ) -> Result<Res, RequestError<Params, Err>> {
        let envelope = decoder.tryDecode(ResponseEnvelope<Res, Err>.self, from: data)
        return mapEnvelope(method: method, params: params, response: envelope)
    }
    
    func serialize<Params: Encodable, Err>(
        id: RPCID, method: String, params: Params, _ err: Err.Type
    ) -> Result<Data, RequestError<Params, Err>> {
        let request = RequestEnvelope(jsonrpc: "2.0", id: id, method: method, params: params)
        return encoder.tryEncode(request).mapError { .service(error: .codec(cause: $0)) }
    }
    
    func serialize<Params, Err>(
        id: RPCID, method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ err: Err.Type
    ) -> Result<Data, RequestError<Params, Err>> where
        Params: ConfigurationCodable.EncodableWithConfiguration
    {
        let request = RequestEnvelope(jsonrpc: "2.0", id: id, method: method, params: params)
        return encoder.tryEncode(request, configuration: configuration)
            .mapError { .service(error: .codec(cause: $0)) }
    }
}
