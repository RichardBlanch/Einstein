//
//  File.swift
//  
//
//  Created by Richard Blanchard on 6/19/19.
//

import Combine
import Foundation

@available(iOS 13.0, *)
struct APIRequestPublisher<Request: APIRequest>: Publisher {
    
    
    typealias Output = Request.Output
    typealias Failure = Request.Error
    
    private let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, APIRequestPublisher.Failure == S.Failure, APIRequestPublisher.Output == S.Input {
        APIRequestLoader.loadAPIRequest(request) { (result) in
            do {
                let result = try result.get()
                subscriber.receive(result)
            } catch {
                self.print("")
            }
        }
        
    }
    
    
}

extension APIRequest {
    @available(iOS 13.0, *)
    func publisher() -> APIRequestPublisher<Self> {
        return APIRequestPublisher(request: self)
    }
}
