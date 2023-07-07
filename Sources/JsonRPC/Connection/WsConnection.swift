//
//  WsConnection.swift
//  
//
//  Created by Yehor Popovych on 29.12.2022.
//

import Foundation
#if os(Linux) || os(Windows)
import FoundationNetworking
#endif

protocol URLSessionWebSocketProxyDelegate: AnyObject {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?)

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}

class URLSessionWebSocketDelegateProxyWrapper: NSObject, URLSessionWebSocketDelegate {
    public weak var delegate: URLSessionWebSocketProxyDelegate?
    public var wrapped: URLSessionDelegate?
    public let delegateQueue: OperationQueue
    
    public init(wrapped: URLSessionDelegate?, delegateQueue: OperationQueue) {
        self.wrapped = wrapped
        self.delegateQueue = delegateQueue
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.delegate?.urlSession(session, webSocketTask: webSocketTask, didOpenWithProtocol: `protocol`)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.delegate?.urlSession(session, webSocketTask: webSocketTask, didCloseWith: closeCode, reason: reason)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.delegate?.urlSession(session, task: task, didCompleteWithError: error)
    }
    
    // TODO: Pass task delegate to the wrapped delegate
}

public class WsConnection: PersistentConnection, Connectable, URLSessionWebSocketProxyDelegate {
    private struct State {
        var connected: ConnectableState = .disconnected
        var task: Optional<URLSessionWebSocketTask> = nil
        var requests: [Data] = []
        var sending: Bool = false
    }
    
    private let url: URL
    private var urlSession: URLSession
    private let headers: [(key: String, value: String)]
    private let queue: DispatchQueue
    private let connectTimeout: TimeInterval
    private let pingInterval: TimeInterval?
    private let maximumMessageSize: Int?
    private var state: Compartment<State>
    private let syncQueue: DispatchQueue
    // Can be not protected because used only in syncQueue
    private var pingTimer: DispatchSourceTimer?
    
    public var sink: ConnectionSink
    public var connected: ConnectableState {
        state.value.connected
    }
    
    public init(url: URL, autoconnect: Bool,
                session: URLSession,
                queue: DispatchQueue,
                headers: [(key: String, value: String)],
                connectTimeout: TimeInterval,
                pingInterval: TimeInterval?,
                pool: DispatchQueue,
                maximumMessageSize: Int?,
                sink: @escaping ConnectionSink
    ) {
        self.url = url
        self.headers = headers
        self.sink = sink
        self.queue = queue
        self.connectTimeout = connectTimeout
        self.pingInterval = pingInterval
        self.maximumMessageSize = maximumMessageSize
        self.pingTimer = nil
        let delegate = URLSessionWebSocketDelegateProxyWrapper(wrapped: session.delegate,
                                                               delegateQueue: session.delegateQueue)
        self.syncQueue = DispatchQueue(
            label: "one.tesseract.jsonrpc.ws.sync",
            autoreleaseFrequency: .workItem,
            target: pool)
        self.state = Compartment(State(), queue: self.syncQueue)
        
        let opQueue = OperationQueue()
        opQueue.underlyingQueue = self.syncQueue
        self.urlSession = URLSession(configuration: session.configuration, delegate: delegate, delegateQueue: opQueue)
        delegate.delegate = self
        
        if autoconnect {
            self.connect()
        }
    }
    
    public func send(data: Data) {
        state.async { state in
            state.requests.append(data)
            self.sendNext(state: &state)
        }
    }
    
    public func connect() {
        state.async { state in
            guard state.connected == .disconnected || state.connected == .disconnecting else {
                return
            }
            var req = URLRequest(url: self.url)
            req.timeoutInterval = self.connectTimeout
            for (k, v) in self.headers {
                req.addValue(v, forHTTPHeaderField: k)
            }
            state.task = self.urlSession.webSocketTask(with: req)
            state.task!.maximumMessageSize = self.maximumMessageSize ?? state.task!.maximumMessageSize
            state.connected = .connecting
            self.flush(state: .connecting)
            state.task!.resume()
        }
    }
    
    public func disconnect() {
        state.async { state in
            guard state.connected == .connected || state.connected == .connecting else {
                return
            }
            state.connected = .disconnecting
            self.flush(state: .disconnecting)
            state.task?.cancel(with: .goingAway, reason: nil)
            state.task = nil
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        state.unprotectedValue.connected = .connected
        flush(state: .connected)
        readNext(state: &state.unprotectedValue)
        sendNext(state: &state.unprotectedValue)
        startPing(state: &state.unprotectedValue)
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        state.unprotectedValue.connected = .disconnected
        stopPing()
        flush(state: .disconnected)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        state.unprotectedValue.connected = .disconnected
        stopPing()
        if let error = error {
            flush(error: .network(cause: error))
        }
    }
    
    deinit {
        sink = { _ in }
        urlSession.invalidateAndCancel()
    }
    
    // Method should be called into State queue
    private func sendNext(state: inout State) {
        guard state.connected == .connected,
              !state.sending,
              state.requests.count > 0 else { return }
        state.sending = true
        let message = state.requests.removeFirst()
        state.task!.send(.data(message)) { [weak self] error in
            if let error = error {
                self?.flush(error: .network(cause: error))
            }
            self?.state.async { state in
                state.sending = false
                self?.sendNext(state: &state)
            }
        }
    }
    
    // Method should be called into State queue
    private func readNext(state: inout State) {
        guard state.connected == .connected else { return }
        state.task!.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data): self?.flush(data: data)
                case .string(let str): self?.flush(string: str)
                #if !os(Linux) && !os(Windows)
                @unknown default: fatalError()
                #endif
                }
            case .failure(let err): self?.flush(error: .network(cause: err))
            }
            self?.state.async { state in
                self?.readNext(state: &state)
            }
        }
    }
    
    // Method should be called into State queue
    private func startPing(state: inout State) {
        guard state.connected == .connected, let pingInterval = pingInterval else { return }
        let timer = DispatchSource.makeTimerSource(queue: self.syncQueue)
        timer.schedule(deadline: .now() + .milliseconds(Int(pingInterval * 1000)),
                       repeating: .milliseconds(Int(pingInterval * 1000)),
                       leeway: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            self?.state.async { state in
                guard state.connected == .connected else { return }
                state.task!.sendPing { error in
                    if let error = error {
                        self?.flush(error: .network(cause: error))
                    }
                }
            }
        }
        timer.activate()
    }
    
    // Method should be called into State queue
    private func stopPing() {
        guard let timer = self.pingTimer else { return }
        self.pingTimer = nil
        timer.cancel()
    }
    
    private func flush(message: ConnectionMessage) {
        let sink = self.sink
        queue.async {
            sink(message)
        }
    }
    
    private func flush(state: ConnectableState) {
        flush(message: .state(state))
    }
    
    private func flush(data: Data) {
        flush(message: .data(data))
    }
    
    private func flush(string: String) {
        flush(data: Data(string.utf8))
    }
    
    private func flush(error: ConnectionError) {
        flush(message: .error(error))
    }
}

///Factory
public struct WsConnectionFactory : PersistentConnectionFactory {
    public typealias Connection = WsConnection
    
    public let url: URL
    public let autoconnect: Bool
    public let session: URLSession
    public let headers: [(key: String, value: String)]
    public let connectTimeout: TimeInterval
    public let pingInterval: TimeInterval?
    public let pool: DispatchQueue
    public let maximumMessageSize: Int?
    
    public func connection(queue: DispatchQueue, sink: @escaping ConnectionSink) -> Connection {
        WsConnection(
            url: url, autoconnect: autoconnect,
            session: session,
            queue: queue,
            headers: headers,
            connectTimeout: connectTimeout,
            pingInterval: pingInterval,
            pool: pool,
            maximumMessageSize: maximumMessageSize,
            sink: sink
        )
    }
}

extension ConnectionFactoryProvider where Factory == WsConnectionFactory {
    public static func ws(
        url: URL, autoconnect: Bool = true,
        session: URLSession = .shared,
        headers: [(key: String, value: String)] = [],
        connectTimeout: TimeInterval = 20,
        pingInterval: TimeInterval? = nil,
        pool: DispatchQueue = .global(qos: .userInteractive),
        maximumMessageSize: Int? = nil
    ) -> Self {
        return Self(factory: WsConnectionFactory(
            url: url, autoconnect: autoconnect,
            session: session, headers: headers,
            connectTimeout: connectTimeout,
            pingInterval: pingInterval,
            pool: pool,
            maximumMessageSize: maximumMessageSize
        ))
    }
}

#if os(Linux) || os(Windows)
extension URLSessionWebSocketTask {
    func send(
        _ message: URLSessionWebSocketTask.Message,
        completionHandler: @escaping (Error?) -> Void
    ) {
        Task.detached {
            do {
                try await self.send(message)
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }
    func receive(
        completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void
    ) {
        Task.detached {
            do {
                completionHandler(.success(try await self.receive()))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}
#endif
