//
//  APIRequestPublisher.swift
//  
//
//  Created by Richard Blanchard on 6/19/19.
//

import Combine
import Foundation

public struct APIRequestPublisher<Request: APIRequest>: Publisher {
    
    public typealias Output = Request.Output
    public typealias Failure = Error
    
    private let request: Request
    private unowned let urlSession: URLSession
    
    init(request: Request, urlSession: URLSession = URLSession.shared) {
        self.request = request
        self.urlSession = urlSession
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, APIRequestPublisher.Failure == S.Failure, APIRequestPublisher.Output == S.Input {
        let subscription = try! APIRequestSubscription<S, Request>(subscriber: subscriber, request: request, urlSession: urlSession)
        subscriber.receive(subscription: subscription)
    }
}

/// A custom subscription to capture APIRequestSubscription target events.
final class APIRequestSubscription<SubscriberType: Subscriber, Request: APIRequest> where SubscriberType.Input == Request.Output, SubscriberType.Failure == Error {
    private var subscriber: SubscriberType?
    private let request: Request
    private unowned let urlSession: URLSession
    
    private var subscriptions: Set<AnyCancellable> = []

    init(subscriber: SubscriberType, request: Request, urlSession: URLSession) throws {
        self.subscriber = subscriber
        self.request = request
        self.urlSession = urlSession
        
        switch request.type {
        case .continuous:
            pollRequest(request)
        case .once:
            makeOneTimeRequest(request)
        }
    }
    
    private func pollRequest(_ request: Request) {
        Timer.scheduledTimer(withTimeInterval: request.pollingTime, repeats: true, block: { [weak self] _ in
            self?.makeOneTimeRequest(request)
        })
        
         makeOneTimeRequest(request)
    }
    
    private func makeOneTimeRequest(_ request: Request)  {
        do {
            try makeRequest(request)
            .sink(receiveCompletion: { completion in
                self.subscriber?.receive(completion: completion)
            }, receiveValue: { [weak self] value in
                _ = self?.subscriber?.receive(value)
                if request.type == .once {
                    _ = self?.subscriber?.receive(completion: .finished)
                }
            })
            .store(in: &self.subscriptions)
        } catch {
            subscriber?.receive(completion: .failure(error))
        }
    }
    
    private func makeRequest(_ request: Request) throws -> AnyPublisher<Request.Output, Error> {
        do {
            let urlRequest = try request.makeRequest()
            
            return urlSession.dataTaskPublisher(for: urlRequest)
            .map { return $0.data }
            .decode(type: Request.Output.self, decoder: request.jsonDecoder)
            .eraseToAnyPublisher()
        } catch {
            throw error
        }
    }
    
    

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
    }
    
    private func finish(with input: Request.Input) {
        guard let input = input as? SubscriberType.Input else {
            fatalError()
        }

        _ = subscriber?.receive(input)
    }
}

extension APIRequestSubscription: Subscription, Cancellable {
    
}

public extension APIRequest {
    func publisher(for urlSession: URLSession = URLSession.shared) -> APIRequestPublisher<Self> {
        return APIRequestPublisher(request: self)
    }
}

public extension URLSession {
    func publisher<Request: APIRequest>(for request: Request) -> APIRequestPublisher<Request> {
        return request.publisher(for: self)
    }
}


