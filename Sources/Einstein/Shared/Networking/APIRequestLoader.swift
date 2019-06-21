//
//  APIRequestLoader.swift
//
//

import Combine
import Foundation

/// A class to load our APIRequests
/// Based off of: https://developer.apple.com/videos/play/wwdc2018/417/
public class APIRequestLoader {
    
    public typealias Future = Publishers.Future
    /// A helper to load our APIRequest
    ///
    /// - Parameters:
    ///   - apiRequest: The kind of APIRequest we want to load. See FetchStoriesAPIRequest as an example.
    ///   - urlSession: This will default to URLSession.shared. If you are using this within a test suite, please override with URLSession.mockSession (see documentation there)
    ///   - completionHandler: A closure to call when we fetch our request. We will have a Typed result of the APIRequest's associateType for ResponseDataType OR a EinsteinError.
    public static func load<Request: APIRequest>(request: Request, using urlSession: URLSession = URLSession.shared) -> Future<Request.Output, Request.Failure>  {
        return Publishers.Future { completion in
            do {
                let urlRequest = try request.makeRequest()
                
                    _ = urlSession
                        .dataTaskPublisher(for: urlRequest)
                        .map { return $0.data }
                        .decode(type: Request.Output.self, decoder: request.jsonDecoder)
                        .sink { completion(.success($0)) }
                
            } catch {
                completion(.failure(error as! Request.Failure))
            }
        }
    }
}
