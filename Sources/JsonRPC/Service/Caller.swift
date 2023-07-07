//
//  Caller.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation
import ConfigurationCodable

struct SingleShotCaller<Connection: SingleShotConnection, Delegate: AnyObject> {
    let core: ServiceCore<Connection, Delegate>
}

extension SingleShotCaller: Callable {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params, res, err, response: callback)
    }
    
    func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration {
        core.call(method: method, params: params,
                  configuration: configuration,
                  res, err, response: response)
    }
    
    func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Res: ConfigurationCodable.DecodableWithConfiguration {
        core.call(method: method, params: params,
                  configuration: configuration,
                  res, err, response: response)
    }
    
    func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration,
            Res: ConfigurationCodable.DecodableWithConfiguration
    {
        core.call(method: method, params: params,
                  encoding: econfiguration,
                  decoding: dconfiguration,
                  res, err, response: response)
    }
}

struct PersistentCaller<Connection: PersistentConnection, Delegate: AnyObject> {
    let core: ServiceCore<Connection, Delegate>
}

extension PersistentCaller: Callable {
    func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params, res, err, response: callback)
    }
    
    func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration {
        core.call(method: method, params: params,
                  configuration: configuration,
                  res, err, response: response)
    }
    
    func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Res: ConfigurationCodable.DecodableWithConfiguration {
        core.call(method: method, params: params,
                  configuration: configuration,
                  res, err, response: response)
    }
    
    func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration,
            Res: ConfigurationCodable.DecodableWithConfiguration
    {
        core.call(method: method, params: params,
                  encoding: econfiguration,
                  decoding: dconfiguration,
                  res, err, response: response)
    }
}
