//
//  Parsable.swift
//  
//
//  Created by Daniel Leping on 22/12/2020.
//

import Foundation
import ContextCodable

public protocol Parsable {
    func parse<T: Decodable>(to: T.Type) -> Result<T?, CodecError>
    func parse<T: ContextDecodable>(
        to: T.Type, context: T.DecodingContext
    ) -> Result<T?, CodecError>
    // TODO: Add Foundation based parse call for Xcode 15+ and Swift 5.9+
}

struct EnvelopedParsable: Parsable {
    private let decoder: ContentDecoder
    private let data: Data
    
    init(data: Data, decoder: ContentDecoder) {
        self.data = data
        self.decoder = decoder
    }
    
    func parse<T: Decodable>(to: T.Type) -> Result<T?, CodecError> {
        decoder.tryDecode(NotificationEnvelope<T>.self, from: data).map {$0.params}
    }
    
    func parse<T: ContextDecodable>(
        to: T.Type, context: T.DecodingContext
    ) -> Result<T?, CodecError> {
        decoder.tryDecode(NotificationEnvelope<T>.self, from: data, context: context)
            .map { $0.params }
    }
}
