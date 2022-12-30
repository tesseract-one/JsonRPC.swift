//
//  File.swift
//  
//
//  Created by Daniel Leping on 21/12/2020.
//

import Foundation

class Compartment<T> {
    private var tenant: T
    private let queue: DispatchQueue
    
    init(_ tenant: T, queue: DispatchQueue) {
        self.tenant = tenant
        self.queue = queue
    }
}

extension Compartment {
    func sync<U>(_ op: (inout T) throws -> U) rethrows -> U {
        try queue.sync {
            try op(&self.tenant)
        }
    }
    
    func async(_ op: @escaping (inout T) -> Void) -> Void {
        queue.async {
            op(&self.tenant)
        }
    }
    
    // Call only if inside compartment queue
    var unprotectedValue: T {
        get { tenant }
        set { tenant = newValue }
    }
}

extension Compartment {
    func assign(value: T) {
        sync {$0 = value}
    }
    
    func assignAsync(value: T) {
        async {$0 = value}
    }
    
    var value: T {
        queue.sync { self.tenant }
    }
}

extension Compartment: Equatable where T: Equatable {
    static func == (lhs: Compartment<T>, rhs: Compartment<T>) -> Bool {
        lhs.value == rhs.value
    }
}

func ==<T>(lhs: Compartment<T>, rhs: T) -> Bool where T: Equatable {
    lhs.value == rhs
}

func !=<T>(lhs: Compartment<T>, rhs: T) -> Bool where T: Equatable {
    lhs.value != rhs
}
