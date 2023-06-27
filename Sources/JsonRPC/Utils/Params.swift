//
//  Params.swift
//  
//
//  Created by Yehor Popovych on 14.06.2022.
//

import Foundation

@inlinable
public func Params() -> [AnyEncodable] { [] }

@inlinable
public func Params<T1: Encodable>(_ p1: T1) -> [AnyEncodable] { [p1.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable>(
    _ p1: T1, _ p2: T2
) -> [AnyEncodable] { [p1.any, p2.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable>(
    _ p1: T1, _ p2: T2, _ p3: T3
) -> [AnyEncodable] { [p1.any, p2.any, p3.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable>(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4
) -> [AnyEncodable] { [p1.any, p2.any, p3.any, p4.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5
) -> [AnyEncodable] { [p1.any, p2.any, p3.any, p4.any, p5.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable,
                   T4: Encodable, T5: Encodable, T6: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5, _ p6: T6
) -> [AnyEncodable] { [p1.any, p2.any, p3.any, p4.any, p5.any, p6.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable,
                   T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5, _ p6: T6, _ p7: T7
) -> [AnyEncodable] { [p1.any, p2.any, p3.any, p4.any, p5.any, p6.any, p7.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5, _ p6: T6, _ p7: T7, _ p8: T8
) -> [AnyEncodable] { [p1.any, p2.any, p3.any, p4.any, p5.any, p6.any, p7.any, p8.any] }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9
) -> [AnyEncodable] {
    [p1.any, p2.any, p3.any, p4.any, p5.any, p6.any, p7.any, p8.any, p9.any]
}

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable, T10: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9, _ p10: T10
) -> [AnyEncodable] {
    [p1.any, p2.any, p3.any, p4.any, p5.any, p6.any, p7.any, p8.any, p9.any, p10.any]
}
