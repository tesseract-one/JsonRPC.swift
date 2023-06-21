//
//  File.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation

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
}
