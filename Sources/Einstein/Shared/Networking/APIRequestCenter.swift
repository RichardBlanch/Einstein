//
//  File.swift
//  
//
//  Created by Richard Blanchard on 6/19/19.
//

import Combine
import Foundation



public class APIRequestPublisher<Request: APIRequest>: Publisher {
    public typealias Output = Request.Output
    public typealias Failure = Request.Failure
    
    public func receive<S>(subscriber: S) where S : Subscriber, APIRequestPublisher.Failure == S.Failure, APIRequestPublisher.Output == S.Input {
        APIRequestLoader.loadAPIRequest(request, using: urlSession) { (result) in
            do {
                let subscriptionType = try result.get()
                let demand = subscriber.receive(subscriptionType)

                if demand != .unlimited {
                    subscriber.receive(completion: .finished)
                }

            } catch {
                guard let error = error as? Failure else { fatalError() }
                subscriber.receive(completion: Subscribers.Completion.failure(error))
            }
        }
    }
    
    
    
    private let request: Request
    private unowned let urlSession: URLSession
    
    init(request: Request, urlSession: URLSession) {
        self.request = request
        self.urlSession = urlSession
    }
    
}
