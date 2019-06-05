//
//  HTTPHeader.swift
//
//

import Foundation

/// A HTTPHeader that will be included as the `header` in our `URLRequest` and sent to the server.
public struct HTTPHeader: Hashable {
    public let field: String
    public let value: String
    
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}

public extension HTTPHeader {
    static let JSONApplicationContentType = HTTPHeader(field: "content-type", value: "application/json")
}
