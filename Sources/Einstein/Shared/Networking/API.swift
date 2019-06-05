//
//  API.swift
//
//

import Foundation

/// An API. This will be used as our baseURL when building URLRequests.
public protocol API {
    var baseURL: URL { get }
}

/// MARK: - Example

/*
 class HackerNewsAPI: API {
    static let shared = HackerNewsAPI()
 
    var baseURL: URL {
        return URL(string: "https://hacker-news.firebaseio.com")!
    }
 
    https://github.com/HackerNews/API
 }
 */
