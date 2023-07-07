//
//  File.swift
//  
//
//  Created by Daniel Leping on 17/12/2020.
//

import Foundation

typealias ResponseClosure = (Data) -> Void

protocol ResponseClosuresRegistry {
    func register(id: RPCID, closure: @escaping ResponseClosure)
    func remove(id: RPCID, result: @escaping (ResponseClosure?) -> Void)
}

extension ServiceCore: ResponseClosuresRegistry where Connection: PersistentConnection {
    func register(id: RPCID, closure: @escaping ResponseClosure) {
        queue.async {
            self.responseClosures[id] = closure
        }
    }
    
    func remove(id: RPCID, result: @escaping (ResponseClosure?) -> Void) {
        queue.async {
            result(self.responseClosures.removeValue(forKey: id))
        }
    }
}

extension ServiceCore where Connection: PersistentConnection, Delegate: AnyObject {
    func process(state: ConnectableState) {
        if debug { print("State: \(state)") }
        guard let delegate = self.delegate as? ConnectableDelegate else {
            return
        }
        delegate.state(state)
    }
    
    func process(error: ServiceError) {
        if debug { print("Error: \(error)") }
        guard let delegate = self.delegate as? ErrorDelegate else {
            return
        }
        delegate.error(error)
    }
    
    func process(notification: String, data: Data) {
        if debug { print("Notification: \(String(data: data, encoding: .utf8) ?? "<error>")") }
        guard let delegate = self.delegate as? NotificationDelegate else {
            return
        }
        delegate.notification(method: notification, params: EnvelopedParsable(data: data, decoder: decoder))
    }
    
    func process(request method: String, id: RPCID, jsonrpc: String, data: Data) {
        let debug = self.debug
        
        if debug { print("Server[\(id)]: \(String(data: data, encoding: .utf8) ?? "<error>")") }
        
        let sendError = { (error: String, encoder: ContentEncoder) in
            let jserr = ResponseError<Nil>(code: -32603, message: error, data: nil)
            let env = ResponseEnvelope<AnyEncodable, Nil>(jsonrpc: jsonrpc, id: id,
                                                          result: nil, error: jserr)
            self.connection.send(data: try! encoder.encode(env)) // Always should be encoded
            if debug { print("Server Error[\(id)]: \(error)") }
        }
        
        guard let delegate = self.delegate as? ServerDelegate else {
            sendError("Server calls is not supported", self.encoder)
            return
        }
        
        let parsable = EnvelopedParsable(data: data, decoder: decoder)
        let encoder = self.encoder
        
        delegate.request(id: Int(id), method: method, params: parsable) { response in
            let envelope: ResponseEnvelope<AnyEncodable, AnyEncodable>
            switch response {
            case .success(let value):
                envelope = ResponseEnvelope(jsonrpc: jsonrpc, id: id, result: value, error: nil)
            case .failure(let err):
                envelope = ResponseEnvelope(jsonrpc: jsonrpc, id: id, result: nil, error: err)
            }
            switch encoder.tryEncode(envelope) {
            case .success(let data):
                if debug { print("Server Response[\(id)]: \(String(data: data, encoding: .utf8) ?? "<error>")") }
                self.connection.send(data: data)
            case .failure(let error):
                sendError(error.localizedDescription, encoder)
                self.process(error: .codec(cause: error))
            }
        }
    }
    
    func process(header: EnvelopeHeader, data: Data) {
        switch header.metadata {
        case .malformed:
            process(error: .envelope(header: header,
                                     description: "RPC message has to have at least either: 'id' or 'method'"))
        case .unknown(version: let version):
            process(error: .envelope(header: header, description: "Unknown RPC version: " + version))
        case .request(id: let id, method: let method, jsonrpc: let rpc):
            process(request: method, id: id, jsonrpc: rpc, data: data)
        case .response(id: let id):
            self.process(response: data, id: id) { [weak self] in
                self?.process(error: .unregisteredResponse(id: id, body: data))
            }
        case .notification(method: let method):
            process(notification: method, data: data)
        }
    }
    
    func process(data: Data) {
        let metadata = decoder.tryDecode(EnvelopeHeader.self, from: data)
        switch metadata {
        case .success(let header): process(header: header, data: data)
        case .failure(let codecError): process(error: .codec(cause: codecError))
        }
    }
    
    func process(message: ConnectionMessage) {
        switch message {
        case .data(let data): process(data: data)
        case .error(let error): process(error: .connection(cause: error))
        case .state(let state): process(state: state)
        }
    }
    
    func process(response: Data, id: RPCID, notFound: @escaping () -> Void) {
        if debug { print("Response[\(id)]: \(String(data: response, encoding: .utf8) ?? "<error>")") }
        queue.async {
            self.remove(id: id) { closure in
                guard let closure = closure else {
                    notFound()
                    return
                }
                closure(response)
            }
        }
    }
}
