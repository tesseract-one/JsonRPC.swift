//
//  Connection.swift
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
    var sink: ConnectionSink { get set }
    
    func send(data: Data)
}

#if swift(>=5.5)
@available(macOS 10.15, iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension SingleShotConnection {
    public func request(data: Data?) async throws -> Data? {
        try await withUnsafeThrowingContinuation { cont in
            self.request(data: data) { cont.resume(with: $0) }
        }
    }
}
#endif
