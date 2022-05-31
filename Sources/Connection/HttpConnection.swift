//
//  HttpConnection.swift
//  
//
//  Created by Daniel Leping on 15/12/2020.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public class HttpConnection: SingleShotConnection {
    private let url: URL
    private let queue: DispatchQueue
    private let headers: Dictionary<String, String>
    private let session: URLSession
    
    public init(url: URL, queue: DispatchQueue, headers: Dictionary<String, String>, session: URLSession) {
        self.url = url
        self.queue = queue
        self.headers = headers
        self.session = session
    }
    
    public func request(data: Data?, response: @escaping ConnectionCallback) -> Void {
        var req = URLRequest(url: url)
        
        req.httpMethod = "POST"
        req.httpBody = data
        
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
    public let headers: Dictionary<String, String>
    
    public func connection(queue: DispatchQueue, headers: Dictionary<String, String>) -> Connection {
        HttpConnection(url: url, queue: queue, headers: headers.merging(self.headers) {$1}, session: session)
    }
}

extension ConnectionFactoryProvider where Factory == HttpConnectionFactory {
    public static func http(url: URL, session: URLSession = URLSession.shared, headers: Dictionary<String, String> = [:]) -> Self {
        Self(factory: HttpConnectionFactory(url: url, session: session, headers: headers))
    }
}
