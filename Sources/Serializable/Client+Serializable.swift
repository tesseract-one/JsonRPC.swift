//
//  Client+Serializable.swift
//  
//
//  Created by Yehor Popovych on 30.12.2022.
//

import Foundation
import Serializable
#if !COCOAPODS
import JsonRPC
#endif

extension Client {
    public func call<Params: Encodable, Res: Decodable>(
        method: String, params: Params, _ res: Res.Type,
        response callback: @escaping RequestCallback<Params, Res, SerializableValue>
    ) {
        self.call(method: method, params: params, res, SerializableValue.self, response: callback)
    }
}

#if swift(>=5.5)
extension Client {
    public func call<Params: Encodable, Res: Decodable>(
        method: String, params: Params, _ res: Res.Type
    ) async throws -> Res {
        try await call(method: method, params: params, res, SerializableValue.self)
    }
    
    public func call<Params: Encodable, Res: Decodable>(
        method: String, params: Params
    ) async throws -> Res {
        try await call(method: method, params: params, Res.self, SerializableValue.self)
    }
}
#endif
