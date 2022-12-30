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

public class ServiceCore<Connection, Delegate>: ServiceCoreProtocol {
    var queue: DispatchQueue
    var connection: Connection
    
    var encoder: ContentEncoder
    var decoder: ContentDecoder
    
    public var delegate: Delegate?
    
    var responseClosures = Dictionary<RPCID, ResponseClosure>()
    
    init(connection: Connection, queue:DispatchQueue, encoder: ContentEncoder, decoder:ContentDecoder) {
        self.connection = connection
        
        self.queue = queue
        
        self.encoder = encoder
        self.decoder = decoder
        
        self.delegate = nil
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
