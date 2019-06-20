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
    private let timeInterval: TimeInterval
    private unowned let dispatchQueue = DispatchQueue(from: StringKey(rawValue: "com.APIRequestPublisher.queue"))
    
    init(request: Request, urlSession: URLSession, timeInterval: TimeInterval) {
        self.request = request
        self.urlSession = urlSession
        self.timeInterval = timeInterval
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, APIRequestPublisher.Failure == S.Failure, APIRequestPublisher.Output == S.Input {
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] (_) in
            guard let self = self else {
                subscriber.receive(completion: .finished)
                return
            }

            _ = APIRequestLoader
                .load(request: self.request)
                .sink { _ = subscriber.receive($0)  }
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}
