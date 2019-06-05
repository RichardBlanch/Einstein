//
//  MockURLSession.swift
//
//

import Foundation

extension URLSession {
    public static func mockURLSession(mockingWithData data: Data) -> URLSession {
        let config = URLSessionConfiguration.ephemeral

        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), data)
        }

        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}
