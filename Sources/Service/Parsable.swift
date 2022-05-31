//
//  File.swift
//  
//
//  Created by Daniel Leping on 22/12/2020.
//

import Foundation

public protocol Parsable {
    func parse<T: Decodable>(to: T.Type) -> Result<T?, CodecError>
}

class EnvelopedParsable: Parsable {
    private let decoder: ContentDecoder
    private let data: Data
    
    init(data: Data, decoder: ContentDecoder) {
        self.data = data
        self.decoder = decoder
    }
    
    func parse<T: Decodable>(to: T.Type) -> Result<T?, CodecError> {
        decoder.tryDecode(NotificationEnvelope<T>.self, from: data).map {$0.params}
    }
}
