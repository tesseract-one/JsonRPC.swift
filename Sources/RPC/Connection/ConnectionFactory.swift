//
//  File.swift
//  
//
//  Created by Daniel Leping on 16/12/2020.
//

import Foundation

public protocol ConnectionFactory: FactoryBase {
}

public protocol SingleShotConnectionFactory: ConnectionFactory where Connection: SingleShotConnection {
    func connection(queue: DispatchQueue, headers: Dictionary<String, String>) -> Connection
}

public protocol PersistentConnectionFactory: ConnectionFactory where Connection: PersistentConnection {
    func connection(queue: DispatchQueue, sink: @escaping ConnectionSink) -> Connection
}

public protocol ConnectionFactoryProvider {
    associatedtype Factory: FactoryBase
    
    init(factory: Factory)
}
