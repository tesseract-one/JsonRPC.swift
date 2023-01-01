//
//  File.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation

public protocol Persistent: AnyObject {
    var delegate: AnyObject? {get set}
}

public protocol ConnectableDelegate: AnyObject {
    func state(_ state: ConnectableState)
}

public protocol ErrorDelegate: AnyObject {
    func error(_ error: ServiceError)
}

public protocol NotificationDelegate: AnyObject {
    func notification(method: String, params: Parsable)
}

public protocol ServerDelegate: AnyObject {
//    func request(id: Int, method: String, params: Parsable, response: Callback<Encodable, Error>)
}

public class VoidDelegate {
    private init() {}
}
