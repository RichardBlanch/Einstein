//
//  APIRequestLoader.swift
//
//

import Foundation

/// A class to load our APIRequests
/// Based off of: https://developer.apple.com/videos/play/wwdc2018/417/
public class APIRequestLoader {
    
    private static let requestMonitor: APIRequestMonitor = APIRequestMonitor.shared
    
    /// A helper to load our APIRequest
    ///
    /// - Parameters:
    ///   - apiRequest: The kind of APIRequest we want to load. See FetchStoriesAPIRequest as an example.
    ///   - urlSession: This will default to URLSession.shared. If you are using this within a test suite, please override with URLSession.mockSession (see documentation there)
    ///   - completionHandler: A closure to call when we fetch our request. We will have a Typed result of the APIRequest's associateType for ResponseDataType OR a EinsteinError.
    public static func loadAPIRequest<Request: APIRequest>(_ apiRequest: Request, using urlSession: URLSession = URLSession.shared, completionHandler: @escaping ( Result<Request.Output, EinsteinError>) -> Void) {
        do {
            let urlRequest = try apiRequest.makeRequest()
            let task = try self.task(apiRequest, urlRequest: urlRequest, using: urlSession, completionHandler: completionHandler)
            
            if apiRequest.throttle != nil {
                if !requestMonitor.hasURL(urlRequest.url) {
                    requestMonitor.add(url: urlRequest.url)
                } else {
                    // response throttled
                    task.cancel()
                    completionHandler(.failure(.couldNotCreateRequest))
                    return
                }
            }
            
            task.resume()
            
        } catch {
            completionHandler(.failure(.genericError(error)))
        }
        
    }
    
    private static func task<Request: APIRequest>(_ apiRequest: Request, urlRequest: URLRequest, using urlSession: URLSession = URLSession.shared, completionHandler: @escaping ( Result<Request.Output, EinsteinError>) -> Void) throws -> URLSessionDataTask {
        
        let throttleTime = apiRequest.throttle ?? 0.0
        
        let dataTask = urlSession.dataTask(with: urlRequest) {  [unowned requestMonitor, throttleTime, urlRequest]  data, response, error in
            requestMonitor.remove(url: urlRequest.url, with: throttleTime)
            
            if let einsteinError = self.einsteinError(from: data, error: error, response: response) {
                completionHandler(.failure(einsteinError))
                return
            }
            
            do {
                let parsedResponse = try apiRequest.parseResponse(from: data!)
                completionHandler(.success(parsedResponse))
            } catch {
                completionHandler(.failure(.genericError(error)))
            }
        }
        
        return dataTask
    }
    
    private static func einsteinError(from data: Data?, error: Error?, response: URLResponse?) -> EinsteinError? {
        let einsteinError: EinsteinError?
        
        if error != nil {
            einsteinError = .genericError(error)
        } else if let httpURLResponse = response as? HTTPURLResponse, (400...499) ~= httpURLResponse.statusCode {
            einsteinError = .httpURLResponseError(httpURLResponse)
        } else if data == nil {
            einsteinError = .noData
        } else {
            einsteinError = nil
        }
        
        return einsteinError
    }
}
