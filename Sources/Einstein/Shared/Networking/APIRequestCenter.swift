//
//  File.swift
//  
//
//  Created by Richard Blanchard on 6/19/19.
//

import Combine
import Foundation

public struct APIRequestPublisher<Request: APIRequest>: Publisher {
    
    
    public typealias Output = Request.Output
    public typealias Failure = Request.Error
    
    private let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, APIRequestPublisher.Failure == S.Failure, APIRequestPublisher.Output == S.Input {
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
