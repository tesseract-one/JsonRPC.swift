//
//  Params.swift
//  
//
//  Created by Yehor Popovych on 14.06.2022.
//

import Foundation
import Tuples

@inlinable
public func Params() -> Tuple0<AnyEncodable> { Tuple0() }

@inlinable
public func Params<T1: Encodable>(_ p1: T1) -> Tuple1<T1> { Tuple1(p1) }

@inlinable
public func Params<T1: Encodable, T2: Encodable>(
    _ p1: T1, _ p2: T2
) -> Tuple2<T1, T2> { Tuple2(p1, p2) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable>(
    _ p1: T1, _ p2: T2, _ p3: T3
) -> Tuple3<T1, T2, T3> { Tuple3(p1, p2, p3) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable>(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4
) -> Tuple4<T1, T2, T3, T4> { Tuple4(p1, p2, p3, p4) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5
) -> Tuple5<T1, T2, T3, T4, T5> { Tuple5(p1, p2, p3, p4, p5) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable,
                   T4: Encodable, T5: Encodable, T6: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5, _ p6: T6
) -> Tuple6<T1, T2, T3, T4, T5, T6> { Tuple6(p1, p2, p3, p4, p5, p6) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable,
                   T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5, _ p6: T6, _ p7: T7
) -> Tuple7<T1, T2, T3, T4, T5, T6, T7> { Tuple7(p1, p2, p3, p4, p5, p6, p7) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5, _ p6: T6, _ p7: T7, _ p8: T8
) -> Tuple8<T1, T2, T3, T4, T5, T6, T7, T8>  { Tuple8(p1, p2, p3, p4, p5, p6, p7, p8) }

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9
) -> Tuple9<T1, T2, T3, T4, T5, T6, T7, T8, T9> {
    Tuple9(p1, p2, p3, p4, p5, p6, p7, p8, p9)
}

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable, T10: Encodable, T11: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9, _ p10: T10,
    _ p11: T11
) -> Tuple11<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11>  {
    Tuple11(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
}

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable, T10: Encodable, T11: Encodable, T12: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9, _ p10: T10,
    _ p11: T11, _ p12: T12
) -> Tuple12<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12>  {
    Tuple12(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12)
}

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable, T10: Encodable, T11: Encodable, T12: Encodable,
                   T13: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9, _ p10: T10,
    _ p11: T11, _ p12: T12, _ p13: T13
) -> Tuple13<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13>  {
    Tuple13(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13)
}

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable, T10: Encodable, T11: Encodable, T12: Encodable,
                   T13: Encodable, T14: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9, _ p10: T10,
    _ p11: T11, _ p12: T12, _ p13: T13, _ p14: T14
) -> Tuple14<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14>  {
    Tuple14(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14)
}

@inlinable
public func Params<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable,
                   T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable,
                   T9: Encodable, T10: Encodable, T11: Encodable, T12: Encodable,
                   T13: Encodable, T14: Encodable, T15: Encodable>
(
    _ p1: T1, _ p2: T2, _ p3: T3, _ p4: T4, _ p5: T5,
    _ p6: T6, _ p7: T7, _ p8: T8, _ p9: T9, _ p10: T10,
    _ p11: T11, _ p12: T12, _ p13: T13, _ p14: T14, _ p15: T15
) -> Tuple15<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15>  {
    Tuple15(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15)
}
