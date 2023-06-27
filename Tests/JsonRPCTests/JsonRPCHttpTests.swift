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
    let queue = DispatchQueue.main
    
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
        
        let before = self.expectation(description: "before")
        queue.async {
            before.fulfill()
        }
        
        var responses:Array<XCTestExpectation> = []
        
        for n in 0...times {
            service.call(method: "web3_clientVersion", params: Params(), String.self, SerializableValue.self) { res in
                responses[n].fulfill()
            }
        }
        
        let after = self.expectation(description: "after")
        queue.async {
            after.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        for n in 0...times {
            responses.append(self.expectation(description: "response#" + String(n)))
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
}
