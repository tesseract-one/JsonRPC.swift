//
//  Lock.swift
//  
//
//  Created by Yehor Popovych on 30.12.2022.
//

import Foundation
#if os(Linux) || os(Windows)
import Glibc

class Synced<T> {
    private var value: T
    private var mutex: pthread_mutex_t
    
    init(value: T) {
        self.mutex = pthread_mutex_t()
        self.value = value
        if pthread_mutex_init(&mutex, nil) != 0 {
            fatalError("Mutex creation failed!")
        }
    }
    
    func sync<U>(_ op: (inout T) throws -> U) rethrows -> U {
        if pthread_mutex_lock(&mutex) != 0 {
            fatalError("Mutex lock failed!")
        }
        defer {
            if pthread_mutex_unlock(&mutex) != 0 {
                fatalError("Mutex unlock failed!")
            }
        }
        return try op(&self.value)
    }
    
    deinit {
        if pthread_mutex_destroy(&mutex) != 0 {
            fatalError("Mutex desctruction failed!")
        }
    }
}
#else
class Synced<T> {
    private var value: T
    private var mutex: os_unfair_lock

    init(value: T) {
        self.value = value
        self.mutex = .init()
    }

    func sync<U>(_ op: (inout T) throws -> U) rethrows -> U {
        os_unfair_lock_lock(&mutex)
        defer { os_unfair_lock_unlock(&mutex) }
        return try op(&self.value)
    }
}
#endif
