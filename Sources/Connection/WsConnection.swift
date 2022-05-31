//
//  File.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation

import WebSocket
import NIOConcurrencyHelpers

extension WebSocketError {
    var connection: ConnectionError {
        switch self {
        case .invalidResponseStatus(head: let head):
            return ConnectionError.http(code: head.status.code, message: head.description.data(using: .utf8))
        default:
            return ConnectionError.network(cause: self)
        }
    }
}

public class WsConnection: PersistentConnection, Connectable {
    private let queue: DispatchQueue
    private let sendq: DispatchQueue
    
    private let url: URL
    private let ws: WebSocket
    
    private var dead: NIOAtomic<Bool>
    private var _connected: Compartment<ConnectableState>
    
    public var sink: ConnectionSink
    
    init(url: URL, autoconnect: Bool, queue: DispatchQueue, pool: DispatchQueue, sink: @escaping ConnectionSink) {
        self.dead = .makeAtomic(value: false)
        self._connected = Compartment(.disconnected, queue: DispatchQueue(label: "one.tesseract.rpc.ws.state", qos: .userInteractive, target: pool))
        
        self.url = url
        self.queue = queue
        self.sink = sink
        
        self.sendq = DispatchQueue(label: "one.tesseract.rpc.ws.send", qos: .userInitiated, target: pool)
        self.sendq.suspend() //don't change to .initiallyInactive. This is different
        
        self.ws = WebSocket(callbackQueue: queue)
        
        ws.onConnected = { [weak self] _ in
            guard let this = self else {
                return
            }
            
            this._connected.assign(value: .connected)
            this.flush(state: .connected)
            
            this.sendq.resume()
        }
        
        ws.onDisconnected = { [weak self] (_, _) in
            guard let this = self else {
                return
            }
            
            this.sendq.suspend()
            this._connected.assign(value: .disconnected)
            this.flush(state: .disconnected)
        }
        
        ws.onError = { [weak self] (error, _) in
            self?.flush(error: error.connection)
        }
        
        ws.onData = { [weak self] (data, _) in //make Either<Data, String>
            switch data {
            case .binary(let data):
                self?.flush(data: data)
            case .text(let text):
                self?.flush(string: text)
            }
            
        }
        
        if autoconnect {
            self.connect()
        }
    }
    
    deinit {
        dead.store(true)
        if _connected != .disconnected {
            //this is a correct behaviour and should not be modified as we need to keep the socket alive till we're sure it's disconnected. Let it gracefully finalize the communication with server. Even sservers like polite clients.
            var keepWsAlive:WebSocket? = ws
            ws.onDisconnected = { (_, _) in
                if let _ = keepWsAlive {
                    keepWsAlive = nil
                }
            }
            switch _connected.value {
            case .disconnected:
                ws.onDisconnected = nil
            case .connecting, .connected:
                ws.disconnect()
            default:
                break
            }
        }
        if _connected == .disconnected || _connected == .connecting {
            sendq.resume()
        }
    }
    
    public var connected: ConnectableState {
        _connected.value
    }
    
    public func connect() {
        _connected.async { [weak self] connected in
            guard let this = self else {
                return
            }
            
            if connected == .disconnected || connected == .disconnecting {
                connected = .connecting
                this.flush(state: .connecting)
                this.ws.connect(url: this.url)
            }
        }
    }
    
    public func disconnect() {
        _connected.async { [weak self] connected in
            guard let this = self else {
                return
            }
            
            if connected == .connected || connected == .connecting {
                connected = .disconnecting
                this.flush(state: .disconnecting)
                this.ws.disconnect()
            }
        }
    }
    
    private func flush(message: ConnectionMessage) {
        let sink = self.sink
        queue.async {
            sink(message)
        }
    }
    
    private func flush(state: ConnectableState) {
        flush(message: .state(state))
    }
    
    private func flush(data: Data) {
        flush(message: .data(data))
    }
    
    private func flush(string: String) {
        flush(data: string.data(using: .utf8)!) //TODO: check error on conversion
    }
    
    private func flush(error: ConnectionError) {
        flush(message: .error(error))
    }
    
    public func send(data: Data) {
        sendq.async { [weak self] in
            guard let this = self else {
                return
            }
            // dead is better than just weak ws, because we can get it earlier and avoid scheduled calls execution when already dead
            if this.dead.load() {
                return
            }
            
            this.ws.send(data) { [weak self] error in
                guard let error = error else {
                    return
                }
                
                switch error {
                case .disconnected:
                    self?.send(data: data)
                default:
                    return
                }
            }
        }
    }
}

///Factory

public struct WsConnectionFactory : PersistentConnectionFactory {
    public typealias Connection = WsConnection
    
    public let url: URL
    public let autoconnect: Bool
    public let pool: DispatchQueue
    
    public func connection(queue: DispatchQueue, sink: @escaping ConnectionSink) -> Connection {
        WsConnection(url: url, autoconnect: autoconnect, queue: queue, pool: pool, sink: sink)
    }
}

extension ConnectionFactoryProvider where Factory == WsConnectionFactory {
    public static func ws(url: URL, autoconnect:Bool = true, pool: DispatchQueue = .global(qos: .utility)) -> Self {
        return Self(factory: WsConnectionFactory(url: url, autoconnect: autoconnect, pool: pool))
    }
}
