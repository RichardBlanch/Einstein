//
//  APIRequest.swift
//
//

import Combine
import Foundation

public enum RequestType: Equatable {
    case continuous(TimeInterval = 30.0)
    case once
}

public enum APIError: Error {
    case generic(Error)
}
/// A protocol for making an API Request. Please see FetchStoriesAPIRequest which is used as an example
/// Based off of: https://developer.apple.com/videos/play/wwdc2018/417/
///
/// 
public protocol APIRequest {
    associatedtype Input
    associatedtype Output: Decodable
    
    /// This will be used to set our base url when building our `URLRequest`.
    var api: API { get }
    
    /// Relevant information for our request. Information that can be substitued into our url, body, path, or headers. This should be passed into the `APIRequest` during initialization
    var requestPayload: Input { get }
    
    /// The path for our `APIRequest`. This will be used to build our `URL`
    var path: String { get }
    
    /// The query items we want to use to build our url. This will default to nil
    var queryItems: [URLQueryItem]? { get }
    
    /// The `HTTPMethod` for our request. This will default to .get
    var method: HTTPMethod { get }

    /// Used to build the headers within our `URLRequest`. Will default to nil
    var headers: [HTTPHeader]? { get }
    
    /// Used to build the body of our `URLRequest`. Will default to nil
    var body: Data? { get }
    
    // TODO: Give this a better name
    var type: RequestType { get }
    
    /// If you want to explicitally build your `URLRequest`, implement this method. Otherwise, the conforming protocol will have a default implementation that derives the URLRequest from the other properties on the protocol
    ///
    /// - Returns: A `URLRequest` which will be sent to the server.
    /// - Throws: A `EinsteinError` - Such as `EinsteinError.couldNotCreateRequest`
    func makeRequest() throws -> URLRequest
    /// An oppurtunity to parse your response. If you want to use a custom decoder, you can implement this method yourself. Otherwise your `APIRequest` will use the default implementation used in this extension
    
    var jsonDecoder: JSONDecoder { get }
}

public extension APIRequest {
    
    var baseURL: URL {
        let baseURL = api.baseURL
        
        return baseURL
    }

    func makeRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url?.appendingPathComponent(path) else {
            throw EinsteinError.couldNotCreateRequest
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        
        headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        return urlRequest
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }

    var headers: [HTTPHeader]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }

    var jsonDecoder: JSONDecoder {
        return JSONDecoder.timeIntervalSince1970Decoder
    }
    
    var pollingTime: TimeInterval {
        switch type {
        case .once: return TimeInterval.nan
        case .continuous(let timeInterval): return timeInterval
        }
    }
}

/// MARK: - Example

/*
 // https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty
 struct FetchStoriesAPIRequest: APIRequest {
 
    // MARK: - Types
 
    enum StoryType: String {
        case top
        case best
        case new
    }
 
    struct Payload {
        let storyTypes: StoryType
    }
 
 
    typealias RequestDataType = Payload
    typealias ResponseDataType = [Int]
 
    var api: API {
        return HackerNewsAPI.shared
    }
 
    let requestPayload: FetchStoriesAPIRequest.Payload
 
    var method: HTTPMethod {
        return .get
    }
 
    var path: String {
        return "/v0/\(requestPayload.storyTypes.rawValue)stories.json"
    }
 
    var queryItems: [URLQueryItem]? {
        return [URLQueryItem(name: "print", value: "pretty")]
    }
 
    var headers: [HTTPHeader]? {
        return nil
    }
 
    var body: Data? {
        return nil
    }
 }
 */

