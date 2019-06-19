//
//  APIRequestPublisher.swift
//  
//
//  Created by Richard Blanchard on 6/19/19.
//

import Combine
import Foundation



public class APIRequestPublisher<Request: APIRequest>: Publisher {
    public typealias Output = Request.Output
    public typealias Failure = Request.Failure
    
    private let request: Request
    private unowned let urlSession: URLSession
    
    init(request: Request, urlSession: URLSession) {
        self.request = request
        self.urlSession = urlSession
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, APIRequestPublisher.Failure == S.Failure, APIRequestPublisher.Output == S.Input {
            _ = APIRequestLoader
                .load(request: request)
                .sink { _ = subscriber.receive($0)  }
    }
}
