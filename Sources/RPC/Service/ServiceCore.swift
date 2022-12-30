//
//  ServiceCore.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation

public protocol ServiceCoreProtocol {
    associatedtype Connection
    associatedtype Delegate
    
    var delegate: Delegate? {get set}
}

public protocol ContentCodersProvider {
    var contentDecoder: ContentDecoder { get }
    var contentEncoder: ContentEncoder { get }
}

public class ServiceCore<Connection, Delegate>: ServiceCoreProtocol {
    var queue: DispatchQueue
    var connection: Connection
    
    var encoder: ContentEncoder
    var decoder: ContentDecoder
    
    let rpcId: Synced<UInt32>
    
    public var delegate: Delegate?
    
    var responseClosures = Dictionary<RPCID, ResponseClosure>()
    
    init(connection: Connection, queue:DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) {
        self.connection = connection
        
        self.queue = queue
        
        self.rpcId = Synced(value: 0)
        
        self.encoder = encoder
        self.decoder = decoder
        
        self.delegate = nil
    }
    
    public func nextId() -> UInt32 {
        rpcId.sync { value in
            value = value == RPCID.max ? 1 : value + 1
            return value
        }
    }
}

extension ServiceCore: Connectable where Connection: Connectable {
    public var connected: ConnectableState {
        connection.connected
    }
    
    public func connect() {
        connection.connect()
    }
    
    public func disconnect() {
        connection.disconnect()
    }
}

extension ServiceCore: ContentCodersProvider {
    public var contentDecoder: ContentDecoder { decoder }
    public var contentEncoder: ContentEncoder { encoder }
}
