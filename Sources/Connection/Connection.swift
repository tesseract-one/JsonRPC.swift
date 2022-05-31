//
//  File.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation

public enum ConnectionError: Error {
    case network(cause: Error)
    case http(code: UInt, message: Data?)
    case unknown(cause: Error?)
}

/// Single shot

public typealias ConnectionCallback = Callback<Data?, ConnectionError>

public protocol SingleShotConnection {
    func request(data: Data?, response: @escaping ConnectionCallback)
}

/// Persistent

public enum ConnectionMessage {
    case data(_ data: Data)
    case state(_ state: ConnectableState)
    case error(_ error: ConnectionError)
}

public typealias ConnectionSink = (ConnectionMessage) -> Void

public protocol PersistentConnection {
    var sink: ConnectionSink {get set}
    
    func send(data: Data)
}
