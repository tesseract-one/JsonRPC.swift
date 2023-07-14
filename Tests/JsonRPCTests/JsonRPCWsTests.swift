//
//  JsonRPCWsTests.swift
//  
//
//  Created by Yehor Popovych on 27/06/2023.
//

import XCTest
import Serializable
@testable import JsonRPC

struct NewHeadsNotification: Decodable {
    let subscription: String
    let result: SerializableValue
}

public class TestDelegate: ConnectableDelegate, NotificationDelegate, ErrorDelegate {
    private let connected: XCTestExpectation
    private var notified: XCTestExpectation?
    private var _state: ConnectableState
    
    var id: String?
    
    init(connected: XCTestExpectation, notified: XCTestExpectation) {
        self.connected = connected
        self.notified = notified
        self._state = .disconnected
        
        self.id = nil
    }
    
    public func state(_ state: ConnectableState) {
        if state == .connected && _state == .connecting {
            connected.fulfill()
        }
        _state = state
    }
    
    public func notification(method: String, params: Parsable) {
        XCTAssertEqual(method, "eth_subscription")
        
        let notification = try! params.parse(to: NewHeadsNotification.self).get()!
        XCTAssertEqual(notification.subscription, id)
    
        notified?.fulfill()
        notified = nil
    }
    
    public func error(_ error: ServiceError) {
        print(error)
    }
}

public class TestErrorDelegate: ConnectableDelegate, ErrorDelegate {
    private let error: XCTestExpectation
    private var _state: ConnectableState
    
    init(error: XCTestExpectation) {
        self.error = error
        self._state = .disconnected
    }
    
    public func state(_ state: ConnectableState) {
        _state = state
    }
    
    public func error(_ error: ServiceError) {
        if _state == .connecting {
            self.error.fulfill()
        }
        print(error)
    }
}

extension URL {
    static var avaWs:URL {URL(string: "wss://api.avax-test.network/ext/bc/C/ws")!}
    //currently, there is not much happening on Ava Test C-chain, thus have to test notifications on MainNet
    static var avaMainWs:URL {URL(string: "wss://api.avax.network/ext/bc/C/ws")!}
}

#if !os(Linux) && !os(Windows)
final class JsonRPCWsTests: XCTestCase {
    let queue = DispatchQueue.main
    let pool = DispatchQueue.global(qos: .userInitiated)
    
    func testCall() {
        let ws = JsonRpc(.ws(url: .avaWs), queue: queue)
        
        let wsExp = self.expectation(description: "ws")
        
        var resWs: String = "ws"
        
        ws.call(method: "web3_clientVersion", params: Params(), String.self, SerializableValue.self) { res in
            resWs = try! res.get()
            
            wsExp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertNotEqual(resWs, "ws")
    }
    
    func testErrorDelegate() {
        //wrong URL
        let service: Persistent = JsonRpc(.ws(url: URL(string: "wss://api.avax-test.network/ext/bc/C/ws1")!, pool: pool), queue: queue)
        
        let delegate = TestErrorDelegate(error: self.expectation(description: "Error"))
        
        service.delegate = delegate
        
        self.waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testWsLong() {
        let service: Client & Persistent & Connectable = JsonRpc(.ws(url: .avaMainWs, autoconnect: false, pool: pool), queue: queue)
        
        let delegate = TestDelegate(connected: self.expectation(description: "Connected"), notified: self.expectation(description: "Notified"))
        service.delegate = delegate
        
        XCTAssertEqual(service.connected, .disconnected)
        service.connect()
        XCTAssertEqual(service.connected, .connecting)

        service.call(method: "eth_subscribe", params: ["newHeads"], String.self, SerializableValue.self) { res in
            switch res {
            case .success(let id):
                delegate.id = id
                break
            case .failure(let err):
                XCTFail(err.localizedDescription)
            }
        }
        
        self.waitForExpectations(timeout: 600, handler: nil)
        
        service.disconnect()
        XCTAssertEqual(service.connected, .disconnecting)
        
        let disconnect = self.expectation(description: "disconnect")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            disconnect.fulfill()
        }
        
        self.waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(service.connected, .disconnected)
    }
    
    func testStress() {
        let times = 100
        
        let service = JsonRpc(.ws(url: .avaWs, autoconnect: false, pool: pool), queue: queue)
        
        let before = self.expectation(description: "before")
        pool.async {
            before.fulfill()
        }
        
        var responses:Array<XCTestExpectation> = []
        
        for n in 0...times {
            service.call(method: "web3_clientVersion", params: Params(), String.self, SerializableValue.self) { res in
                responses[n].fulfill()
            }
        }
        
        let after = self.expectation(description: "after")
        pool.async {
            after.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        for n in 0...times {
            responses.append(self.expectation(description: "response#" + String(n)))
        }
        service.connect()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
#endif
