//
//  StartupSequence.swift
//  
//
//  Created by Richard Blanchard on 6/24/19.
//

import Combine
import Foundation

/// The sequences you want to run before your app launches
public protocol StartupSequenceType {
    associatedtype Failure: Error
    associatedtype Success
    static func start() -> Publishers.Future<Success, Failure>
}

// MARK: - Example
/*

class StartupSequence: StartupSequenceType {
    typealias Failure = EinsteinError
    typealias Success = ([String], [String])
    
    static func start() -> Publishers.Future<Success, Failure> {
        return Publishers.Future { (completion) in
            GetAllAirportsRequest().future()
                .zip(GetAllAirlinesRequest().future())
                .sink { (allAirportsAndAllAirlines) in
                    completion(.success(allAirportsAndAllAirlines))
            }
        }
    }
}
 */
