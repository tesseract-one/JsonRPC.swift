//
//  ServiceCore.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation

public protocol ServiceCoreProtocol {
    associatedtype Connection
    associatedtype Delegate: AnyObject
    
    var debug: Bool {get set}
    var delegate: Delegate? {get set}
}

public protocol ContentCodersProvider {
    var contentDecoder: ContentDecoder { get set }
    var contentEncoder: ContentEncoder { get set }
}

public final class ServiceCore<Connection, Delegate: AnyObject>: ServiceCoreProtocol {
    var queue: DispatchQueue
    var connection: Connection
    
    var encoder: ContentEncoder
    var decoder: ContentDecoder
    
    let rpcId: Synced<UInt32>
    
    public var debug: Bool
    public weak var delegate: Delegate?
    
    var responseClosures = Dictionary<RPCID, ResponseClosure>()
    
    init(connection: Connection, queue:DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) {
        self.connection = connection
        
        self.queue = queue
        
        self.rpcId = Synced(value: 0)
        
        self.encoder = encoder
        self.decoder = decoder
        
        self.delegate = nil
        self.debug = false
    }
    
    public func nextId() -> UInt32 {
        rpcId.sync { value in
            value = value == RPCID.max ? 1 : value + 1
            return value
        }
    }
}

extension ServiceCore: Connectable where Connection: Connectable {
    public var connected: ConnectableState { connection.connected }
    public func connect() { connection.connect() }
    public func disconnect() { connection.disconnect() }
}

extension ServiceCore: ContentCodersProvider {
    public var contentDecoder: ContentDecoder {
        get { decoder }
        set { decoder = newValue }
    }
    public var contentEncoder: ContentEncoder {
        get { encoder }
        set { encoder = newValue }
    }
}
