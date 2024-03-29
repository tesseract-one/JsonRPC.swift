# JsonRPC.swift

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](https://raw.githubusercontent.com/tesseract-one/JsonRPC.swift/main/LICENSE)
[![Build Status](https://github.com/tesseract-one/JsonRPC.swift/workflows/Build%20%26%20Tests/badge.svg?branch=main)](https://github.com/tesseract-one/JsonRPC.swift/actions?query=workflow%3ABuild%20%26%20Tests+branch%3Amain)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/JsonRPC.swift.svg)](https://github.com/tesseract-one/JsonRPC.swift/releases)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods version](https://img.shields.io/cocoapods/v/JsonRPC.swift.svg)](https://cocoapods.org/pods/JsonRPC.swift)
![Platform OS X | iOS | tvOS | watchOS | Linux](https://img.shields.io/badge/platform-Linux%20%7C%20OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

### Cross-platform JsonRPC client implementation with HTTP and WebSocket support

## Linux WebSocket support
WebSocket should work on Linux when this bug will be fixed: [Issue #4730](https://github.com/apple/swift-corelibs-foundation/issues/4730)
You can use `0.1.1` version for now, which uses SwiftNIO for WebSocket.

## Getting started

### Installation

#### [Package Manager](https://swift.org/package-manager/)

Add the following dependency to your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#define-dependencies):

```swift
.package(url: "https://github.com/tesseract-one/JsonRPC.swift.git", from: "0.2.0")
```

Run `swift build` and build your app.

#### [CocoaPods](http://cocoapods.org/)

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'JsonRPC.swift', '~> 0.2.0'
```

Then run `pod install`

### Examples

#### HTTP connection

```swift
import Foundation
import JsonRPC

let rpc = JsonRpc(.http(url: URL(string: "https://api.avax-test.network/ext/bc/C/rpc")!), queue: .main)

rpc.call(method: "web3_clientVersion", params: Params(), String.self, String.self) { res in
  print(try! res.get())
}

// Or with async/await (Swift 5.5+)
let res = await rpc.call(method: "web3_clientVersion", params: Params(), String.self, String.self)
print(res)
```

#### WebSocket connection

```swift
import Foundation
import JsonRPC

let rpc = JsonRpc(.ws(url: URL(string: "wss://api.avax-test.network/ext/bc/C/ws")!), queue: .main)

rpc.call(method: "web3_clientVersion", params: Params(), String.self, String.self) { res in
  print(try! res.get())
}

// Or with async/await (Swift 5.5+)
let res = await rpc.call(method: "web3_clientVersion", params: Params(), String.self, String.self)
print(res)
```

#### Notifications

```swift
import Foundation
import JsonRPC
// This will allow dynamic JSON parsing 
// https://github.com/tesseract-one/Serializable.swift
import Serializable

// Notification body structure
struct NewHeadsNotification: Decodable {
    let subscription: String
    let result: SerializableValue
}

class Delegate: ConnectableDelegate, NotificationDelegate, ErrorDelegate {
  // Connectable Delegate. Will send connection updates
  public func state(_ state: ConnectableState) {
    print("Connection state: \(state)")
  }

  // Error delegate. Will send global errors (uknown response id, etc.)
  public func error(_ error: ServiceError) {
    print("Error: \(error)")
  }

  public func notification(method: String, params: Parsable) {
    let notification = try! params.parse(to: NewHeadsNotification.self).get()!
    print("\(method): \(notification)")
  }
}

// Create RPC
let rpc = JsonRpc(.ws(url: URL(string: "wss://main-rpc.linkpool.io/ws")!, autoconnect: false), queue: .main)

// Set delegate. Notification and statuses will be forwarded to it
rpc.delegate = Delegate()

// Connect to the server
rpc.connect()

// Call subsribe method.
// You can use Params() for array of Encodable parameters or provide own custom Encodable value.
rpc.call(method: "eth_subscribe", params: Params("newHeads"), String.self, SerializableValue.self) { res in
    print(try! res.get())
}

// Or with async/await (Swift 5.5+)
let res = await rpc.call(method: "eth_subscribe", params: Params("newHeads"), String.self, SerializableValue.self)
// or let res: String = await rpc.call(method: "eth_subscribe", params: Params("newHeads"), SerializableValue.self)
print(res)
```

## Author

 - [Tesseract Systems, Inc.](mailto:info@tesseract.one)
   ([@tesseract_one](https://twitter.com/tesseract_one))

## License

JsonRPC.swift is available under the Apache 2.0 license. See [the LICENSE file](./LICENSE) for more information.
