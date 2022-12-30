//
//  HttpConnection.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation
#if os(Linux) || os(Windows)
import FoundationNetworking
#endif

public class HttpConnection: SingleShotConnection {
    private let url: URL
    private let queue: DispatchQueue
    private let headers: [(key: String, value: String)]
    private let session: URLSession
    private let timeout: TimeInterval
    
    public init(
        url: URL, queue: DispatchQueue, headers: [(key: String, value: String)],
        timeout: TimeInterval, session: URLSession
    ) {
        self.url = url
        self.queue = queue
        self.headers = headers
        self.session = session
        self.timeout = timeout
    }
    
    public func request(data: Data?, response: @escaping ConnectionCallback) -> Void {
        var req = URLRequest(url: url)
        
        req.httpMethod = "POST"
        req.httpBody = data
        req.timeoutInterval = timeout
        
        for (k, v) in headers {
            req.addValue(v, forHTTPHeaderField: k)
        }
        
        session.dataTask(with: req) { data, urlResponse, error in
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                self.queue.async { response(.failure(.unknown(cause: nil))) }
                return
            }
            
            if let error = error {
                self.queue.async { response(.failure(.network(cause: error))) }
            } else {
                let status = UInt(urlResponse.statusCode)
                self.queue.async {
                    if status >= 300 || status < 200 {
                        response(.failure(.http(code: status, message: data)))
                    } else {
                        response(.success(data))
                    }
                }
            }
        }.resume()
    }
}

///Factory

public struct HttpConnectionFactory : SingleShotConnectionFactory {
    public typealias Connection = HttpConnection
    
    public let url: URL
    public let session: URLSession
    public let headers: [(key: String, value: String)]
    public let timeout: TimeInterval
    
    public func connection(queue: DispatchQueue, headers: Dictionary<String, String>) -> Connection {
        var mergedHeaders = self.headers
        for (key, val) in headers {
            if !mergedHeaders.contains(where: { $0.key == key }) {
                mergedHeaders.append((key, val))
            }
        }
        return HttpConnection(
            url: url, queue: queue,
            headers: mergedHeaders,
            timeout: timeout,
            session: session
        )
    }
}

extension ConnectionFactoryProvider where Factory == HttpConnectionFactory {
    public static func http(
        url: URL, session: URLSession = .shared,
        headers: [(key: String, value: String)] = [],
        timeout: TimeInterval = 60.0
    ) -> Self {
        Self(factory: HttpConnectionFactory(url: url,
                                            session: session,
                                            headers: headers,
                                            timeout: timeout))
    }
}

