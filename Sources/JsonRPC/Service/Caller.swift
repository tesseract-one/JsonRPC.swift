//
//  Caller.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation
import ContextCodable

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
    
    func call<Params: ContextEncodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        context: Params.EncodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params,
                  context: context,
                  res, err, response: response)
    }
    
    func call<Params: Encodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        context: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params,
                  context: context,
                  res, err, response: response)
    }
    
    func call<Params: ContextEncodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        encoding econtext: Params.EncodingContext,
        decoding dcontext: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params,
                  encoding: econtext,
                  decoding: dcontext,
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
    
    func call<Params: ContextEncodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        context: Params.EncodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params,
                  context: context,
                  res, err, response: response)
    }
    
    func call<Params: Encodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        context: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params,
                  context: context,
                  res, err, response: response)
    }
    
    func call<Params: ContextEncodable, Res: ContextDecodable, Err: Decodable>(
        method: String, params: Params,
        encoding econtext: Params.EncodingContext,
        decoding dcontext: Res.DecodingContext,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) {
        core.call(method: method, params: params,
                  encoding: econtext,
                  decoding: dcontext,
                  res, err, response: response)
    }
}
