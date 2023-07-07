//
//  Service.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation
import ConfigurationCodable

public enum ServiceError: Swift.Error {
    case connection(cause: ConnectionError)
    case codec(cause: CodecError)
    case envelope(header: EnvelopeHeader, description: String)
    case unregisteredResponse(id: RPCID, body: Data)
}

public final class Service<Core: ServiceCoreProtocol> {
    private var core: Core
    private let caller: Callable
    
    init(core: Core, caller: Callable) {
        self.core = core
        self.caller = caller
    }
}

extension Service: Client {
    public var debug: Bool {
        get { core.debug }
        set { core.debug = newValue }
    }
    
    public func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        caller.call(method: method, params: params, res, err, response: callback)
    }
    
    public func call<Params, Res: Decodable, Err: Decodable>(
        method: String, params: Params,
        configuration: Params.EncodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration {
        caller.call(method: method, params: params,
                    configuration: configuration,
                    res, err, response: response)
    }
    
    public func call<Params: Encodable, Res, Err: Decodable>(
        method: String, params: Params,
        configuration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Res: ConfigurationCodable.DecodableWithConfiguration {
        caller.call(method: method, params: params,
                    configuration: configuration,
                    res, err, response: response)
    }
    
    public func call<Params, Res, Err: Decodable>(
        method: String, params: Params,
        encoding econfiguration: Params.EncodingConfiguration,
        decoding dconfiguration: Res.DecodingConfiguration,
        _ res: Res.Type, _ err: Err.Type,
        response: @escaping RequestCallback<Params, Res, Err>
    ) where Params: ConfigurationCodable.EncodableWithConfiguration,
            Res: ConfigurationCodable.DecodableWithConfiguration
    {
        caller.call(method: method, params: params,
                    encoding: econfiguration,
                    decoding: dconfiguration,
                    res, err, response: response)
    }
}

extension Service: Persistent where Core.Delegate == AnyObject {
    public var delegate: AnyObject? {
        get { core.delegate }
        set { core.delegate = newValue }
    }
}

extension Service: Connectable where Core: Connectable {
    public var connected: ConnectableState { core.connected }
    public func connect() { core.connect() }
    public func disconnect() { core.disconnect() }
}

extension Service: ContentCodersProvider where Core: ContentCodersProvider {
    public var contentDecoder: ContentDecoder {
        get { core.contentDecoder }
        set { core.contentDecoder = newValue }
    }
    
    public var contentEncoder: ContentEncoder {
        get { core.contentEncoder }
        set { core.contentEncoder = newValue }
    }
}
