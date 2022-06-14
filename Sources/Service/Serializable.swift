//
//  Serializable.swift
//  
//
//  Created by Yehor Popovych on 14.06.2022.
//

#if canImport(Serializable)
import Foundation
import Serializable

extension Client {
    public func call<Params: Encodable, Res: Decodable>(
        method: String, params: Params, _ res: Res.Type,
        response callback: @escaping RequestCallback<Params, Res, SerializableValue>
    ) {
        self.call(method: method, params: params, res, SerializableValue.self, response: callback)
    }
}
#endif
