//
//  APIRequest.swift
//
//

import Foundation

/// A protocol for making an API Request. Please see FetchStoriesAPIRequest which is used as an example
/// Based off of: https://developer.apple.com/videos/play/wwdc2018/417/
public protocol APIRequest {
    associatedtype RequestDataType
    associatedtype ResponseDataType: Decodable
    
    /// This will be used to set our base url when building our `URLRequest`.
    var api: API { get }
    
    /// Relevant information for our request. Information that can be substitued into our url, body, path, or headers. This should be passed into the `APIRequest` during initialization
    var requestPayload: RequestDataType { get }
    
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
    
    
    /// If you want to throttle your network request every X seconds. Return X. If you don't want to throttle, return nil. Will default to nil
    var throttle: TimeInterval? { get }
    
    /// If you want to explicitally build your `URLRequest`, implement this method. Otherwise, the conforming protocol will have a default implementation that derives the URLRequest from the other properties on the protocol
    ///
    /// - Returns: A `URLRequest` which will be sent to the server.
    /// - Throws: A `GrioError` - Such as `GrioError.couldNotCreateRequest`
    func makeRequest() throws -> URLRequest
    /// An oppurtunity to parse your response. If you want to use a custom decoder, you can implement this method yourself. Otherwise your `APIRequest` will use the default implementation used in this extension
    ///
    /// - Parameter data: Data returned from your service
    /// - Returns: The type which your protocol declares as its ResponseDataType
    /// - Throws: A DecodingError if we could not create our ResponseDataType from the data returned
    func parseResponse(from data: Data) throws -> ResponseDataType
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
            throw GrioError.couldNotCreateRequest
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        
        headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        return urlRequest
    }
    
    func parseResponse(from data: Data) throws -> ResponseDataType {
        return try JSONDecoder().decode(ResponseDataType.self, from: data)
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
    
    var throttle: TimeInterval? {
        return nil
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


