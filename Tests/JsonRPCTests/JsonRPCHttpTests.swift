//
//  JsonRPCHttpTests.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import XCTest
import Serializable
@testable import JsonRPC

extension URL {
    static var avaHttp:URL {URL(string: "https://api.avax-test.network/ext/bc/C/rpc")!}
}

final class JsonRPCHttpTests: XCTestCase {
    let queue = DispatchQueue.global(qos: .userInteractive)
    
    func testCall() {
        let http = JsonRpc(.http(url: .avaHttp), queue: queue)
        let httpExp = self.expectation(description: "http")
        
        var resHttp: String = "http"
        
        http.call(method: "web3_clientVersion", params: Params(), String.self, SerializableValue.self) { res in
            resHttp = try! res.get()
            
            httpExp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertNotEqual(resHttp, "http")
    }
    
    func testStress() {
        let times = 100
        
        let service = JsonRpc(.http(url: .avaHttp), queue: queue)
        
        let responses = (0...times).map { n in
            self.expectation(description: "response#" + String(n))
        }
  
        for n in 0...times {
            service.call(method: "web3_clientVersion", params: Params(), String.self, SerializableValue.self) { res in
                responses[n].fulfill()
            }
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
}
