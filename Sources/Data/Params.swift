//
//  Params.swift
//  
//
//  Created by Yehor Popovych on 14.06.2022.
//

import Foundation

public struct CallParam: Encodable {
    public let value: Encodable
    
    public init(_ value: Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension Encodable {
    public var rpcParam: CallParam { CallParam(self) }
}

public func Params() -> [CallParam] { [] }

public func Params(_ p1: Encodable) -> [CallParam] {
    [p1.rpcParam]
}

public func Params(_ p1: Encodable, _ p2: Encodable) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam]
}

public func Params(_ p1: Encodable, _ p2: Encodable, _ p3: Encodable) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam]
}

public func Params(_ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam]
}

public func Params(
    _ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable, _ p5: Encodable
) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam, p5.rpcParam]
}

public func Params(
    _ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable, _ p5: Encodable,
    _ p6: Encodable
) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam, p5.rpcParam,
     p6.rpcParam]
}

public func Params(
    _ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable, _ p5: Encodable,
    _ p6: Encodable, _ p7: Encodable
) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam, p5.rpcParam,
     p6.rpcParam, p7.rpcParam]
}

public func Params(
    _ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable, _ p5: Encodable,
    _ p6: Encodable, _ p7: Encodable, _ p8: Encodable
) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam, p5.rpcParam,
     p6.rpcParam, p7.rpcParam, p8.rpcParam]
}

public func Params(
    _ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable, _ p5: Encodable,
    _ p6: Encodable, _ p7: Encodable, _ p8: Encodable, _ p9: Encodable
) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam, p5.rpcParam,
     p6.rpcParam, p7.rpcParam, p8.rpcParam, p9.rpcParam]
}

public func Params(
    _ p1: Encodable, _ p2: Encodable, _ p3: Encodable, _ p4: Encodable, _ p5: Encodable,
    _ p6: Encodable, _ p7: Encodable, _ p8: Encodable, _ p9: Encodable, _ p10: Encodable
) -> [CallParam] {
    [p1.rpcParam, p2.rpcParam, p3.rpcParam, p4.rpcParam, p5.rpcParam,
     p6.rpcParam, p7.rpcParam, p8.rpcParam, p9.rpcParam, p10.rpcParam]
}
