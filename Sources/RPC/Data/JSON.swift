//
//  File.swift
//  
//
//  Created by Daniel Leping on 14/12/2020.
//

import Foundation

extension Formatter {
    public static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    public static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601withFractionalSeconds.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container,
                  debugDescription: "Invalid date: " + string)
        }
        return date
    }
}

extension JSONEncoder.DateEncodingStrategy {
    public static let iso8601withFractionalSeconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
    }
}

extension JSONDecoder.DataDecodingStrategy {
    public static let hex = custom { decoder in
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        guard let data = Hex.decode(hex: hex) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Bad Hex value")
        }
        return data
    }
}

extension JSONEncoder.DataEncodingStrategy {
    public static let prefixedHex = custom { data, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(Hex.encode(data: data, prefix: true))
    }
    
    public static let nonPrefixedHex = custom { data, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(Hex.encode(data: data, prefix: false))
    }
}

extension JSONEncoder: ContentEncoder {    
    public var contentType: ContentType {
        .json
    }
    
    public var context: [CodingUserInfoKey : Any] {
        get { userInfo }
        set { userInfo = newValue }
    }
    
    public static var rpc: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
        encoder.nonConformingFloatEncodingStrategy = .throw
        return encoder
    }()
}

extension JSONDecoder: ContentDecoder {
    public var contentType: ContentType {
        .json
    }
    
    public var context: [CodingUserInfoKey : Any] {
        get { userInfo }
        set { userInfo = newValue }
    }
    
    public static var rpc: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
        decoder.nonConformingFloatDecodingStrategy = .throw
        return decoder
    }()
}
