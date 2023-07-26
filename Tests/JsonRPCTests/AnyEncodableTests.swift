//
//  AnyEncodableTests.swift
//  
//
//  Created by Yehor Popovych on 16/06/2023.
//

import Foundation
import XCTest
@testable import JsonRPC

final class AnyEncodableTests: XCTestCase {
    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }()
    
    func testData() {
        let data = Data(repeating: 1, count: 32)
        let encoded = try? encoder.encode([AnyEncodable(data)])
        XCTAssertNotNil(encoded)
        let string = String(data: encoded!, encoding: .utf8)!
        XCTAssertEqual(string, "[\"AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE=\"]")
    }
}
