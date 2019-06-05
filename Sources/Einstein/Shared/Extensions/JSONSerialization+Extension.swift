//
//  JSONSerialization.swift
//  GrioCommon iOS
//
//  Created by Richard Blanchard on 5/16/19.
//

import Foundation

public typealias JSONObject = [String: AnyObject ]

public enum JSONError: Error {
    case couldNotCreateJSONObject
    case couldNotCreateJSONObjects
}

public extension JSONSerialization {
    static func jsonObject(from data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> JSONObject {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: opt)
        
        if !(jsonObject is JSONObject) {
            throw JSONError.couldNotCreateJSONObject
        }
        
        return jsonObject as! JSONObject
    }
    
    static func jsonObjects(from data: Data, options opt: JSONSerialization.ReadingOptions = []) throws -> [JSONObject] {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: opt)
        
        if !(jsonObject is [JSONObject]) {
            throw JSONError.couldNotCreateJSONObjects
        }
        
        return jsonObject as! [JSONObject]
    }
}
