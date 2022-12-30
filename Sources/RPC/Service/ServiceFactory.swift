//
//  File 2.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation

public protocol ServiceFactory: FactoryBase {
    associatedtype Delegate
    
    func core(queue: DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) -> ServiceCore<Connection, Delegate>
    func caller(service: ServiceCore<Connection, Delegate>) -> Client
}

public struct ServiceFactoryProvider<Factory: ServiceFactory>: ConnectionFactoryProvider {
    public let factory: Factory
    
    public init(factory: Factory) {
        self.factory = factory
    }
}

extension ServiceFactoryProvider: ServiceFactory {
    public typealias Connection = Factory.Connection
    public typealias Delegate = Factory.Delegate
    
    public func core(queue: DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) -> ServiceCore<Factory.Connection, Factory.Delegate> {
        factory.core(queue: queue, encoder: encoder, decoder: decoder)
    }
    
    public func caller(service: ServiceCore<Connection, Delegate>) -> Client {
        factory.caller(service: service)
    }
}

///Single Shot Service

public protocol SingleShotServiceFactory: ServiceFactory where Connection: SingleShotConnection, Delegate == Void {
}

extension SingleShotServiceFactory where Self: SingleShotConnectionFactory {
    public func core(queue: DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) -> ServiceCore<Connection, Delegate> {
        var headers = Dictionary<String, String>()
        
        headers["Content-Type"] = encoder.contentType.rawValue
        headers["Accept"] = decoder.contentType.rawValue
        
        return ServiceCore(connection: self.connection(queue: queue, headers: headers), queue: queue, encoder: encoder, decoder: decoder)
    }
    
    public func caller(service: ServiceCore<Connection, Delegate>) -> Client {
        SingleShotCaller(core: service)
    }
}

///Persistent Service Factory

public protocol PersistentServiceFactory: ServiceFactory where Connection: PersistentConnection, Delegate == AnyObject {
}

extension PersistentServiceFactory where Self: PersistentConnectionFactory {
    public func core(queue: DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) -> ServiceCore<Connection, Delegate> {
        var this:WeakRef<ServiceCore<Connection, Delegate>> = WeakRef(ref: nil)
            
            let conn = self.connection(queue: queue) { message in
                guard let this = this.ref else {
                    //we're dead here
                    return
                }
                
                this.process(message: message)
            }
        
            
        let service: ServiceCore<Connection, Delegate> = ServiceCore(connection: conn, queue: queue, encoder: encoder, decoder: decoder)
            //for our sink closure
            this.ref = service
        
        return service
    }
    
    public func caller(service: ServiceCore<Connection, Delegate>) -> Client {
        PersistentCaller(core: service)
    }
}

/// Registrations with particular connection factories

extension HttpConnectionFactory: SingleShotServiceFactory {
}

extension WsConnectionFactory: PersistentServiceFactory {
}

public func JsonRpc<Factory: ServiceFactory>(factory: Factory, queue: DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) -> Service<ServiceCore<Factory.Connection, Factory.Delegate>> {
    let core = factory.core(queue: queue, encoder: encoder, decoder: decoder)
    let caller = factory.caller(service: core)
    return Service(core: core, caller: caller)
}

public func JsonRpc<Factory: ServiceFactory>(_ cfp: ServiceFactoryProvider<Factory>, queue: DispatchQueue, encoder: ContentEncoder = JSONEncoder.rpc, decoder:ContentDecoder = JSONDecoder.rpc) -> Service<ServiceCore<Factory.Connection, Factory.Delegate>> {
    JsonRpc(factory: cfp.factory, queue: queue, encoder: encoder, decoder: decoder)
}
