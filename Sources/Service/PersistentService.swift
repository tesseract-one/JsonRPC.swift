//
//  File.swift
//  
//
//  Created by Daniel Leping on 17/12/2020.
//

import Foundation

typealias ResponseClosure = (Data)->Void

protocol ResponseClosuresRegistry {
    func register(id: RPCID, closure: @escaping ResponseClosure)
    func remove(id: RPCID, result: @escaping (ResponseClosure?)->Void)
}

extension ServiceCore: ResponseClosuresRegistry where Connection: PersistentConnection {
    func register(id: RPCID, closure: @escaping ResponseClosure) {
        queue.async {
            self.responseClosures[id] = closure
        }
    }
    
    func remove(id: RPCID, result: @escaping (ResponseClosure?)->Void) {
        queue.async {
            result(self.responseClosures.removeValue(forKey: id))
        }
    }
}

extension ServiceCore where Connection: PersistentConnection, Delegate: AnyObject {
    func process(state: ConnectableState) {
        guard let delegate = self.delegate as? ConnectableDelegate else {
            return
        }
        
        delegate.state(state)
    }
    
    func process(error: ServiceError) {
        guard let delegate = self.delegate as? ErrorDelegate else {
            return
        }
        
        delegate.error(error)
    }
    
    func process(notification: String, data: Data) {
        guard let delegate = self.delegate as? ServerDelegate else {
            return
        }
        
        delegate.notification(method: notification, params: EnvelopedParsable(data: data, decoder: decoder))
    }
    
    func process(request: String, id: RPCID, data: Data) {
        //TODO: create "parsable", flush to delegate, and send back the result
    }
    
    func process(header: EnvelopeHeader, data: Data) {
        switch header.metadata {
        case .malformed:
            process(error: .envelope(header: header, description: "RPC message has to have at least either: 'id' or 'method'"))
            break
        case .unknown(version: let version):
            process(error: .envelope(header: header, description: "Unknown RPC version: " + version))
            break
        case .request(id: let id, method: let method):
            process(request: method, id: id, data: data)
            break
        case .response(id: let id):
            self.process(response: data, id: id) { [weak self] in
                self?.process(error: .unregisteredResponse(id: id, body: data))
            }
            break
        case .notification(method: let method):
            process(notification: method, data: data)
            break
        }
    }
    
    func process(data: Data) {
        let metadata = decoder.tryDecode(EnvelopeHeader.self, from: data)
        switch metadata {
        case .success(let header):
            process(header: header, data: data)
            break
        case .failure(let codecError):
            process(error: .codec(cause: codecError))
            break
        }
    }
    
    func process(message: ConnectionMessage) {
        switch message {
        case .data(let data):
            process(data: data)
            break
        case .error(let error):
            process(error: .connection(cause: error))
            break
        case .state(let state):
            process(state: state)
            break
        }
    }
}
