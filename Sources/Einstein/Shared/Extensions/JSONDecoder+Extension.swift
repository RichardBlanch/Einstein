//
//  JSONDecoder+Extension.swift
//  
//
//  Created by Richard Blanchard on 6/19/19.
//

import Foundation

public extension JSONDecoder {
    static let timeIntervalSince1970Decoder: JSONDecoder = {
        var jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
        
        return jsonDecoder
    }()
}

