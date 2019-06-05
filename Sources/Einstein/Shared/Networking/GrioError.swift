//
//  GrioError.swift
//
//

import Foundation

/// An error that can be fed into a UIAlertController. See UIAlertController+Extension.swift
public protocol AlertControllerError: Error {
    var title: String? { get }
    var message: String? { get }
    var showsError: Bool { get }
}

extension AlertControllerError {
    public var showsError: Bool {
        return title != nil && message != nil
    }
}

public enum GrioError: Error, Equatable, AlertControllerError {
    case couldNotCreateRequest
    case genericError(Error?)
    case noData
    case responseAlreadyInProgress
    case httpURLResponseError(HTTPURLResponse)
    
    public var title: String? {
        if self == GrioError.responseAlreadyInProgress {
            return nil
        } else {
            return "Error!"
        }
    }
    
    public var message: String? {
        switch self {
        case .couldNotCreateRequest: return "Could not create request"
        case .genericError(let error): return error?.localizedDescription
        case .noData: return "No data"
        case .responseAlreadyInProgress: return nil
        case .httpURLResponseError(let response): return "Response failed with: \(response.statusCode)"
        }
    }
    
    public static func == (lhs: GrioError, rhs: GrioError) -> Bool {
        switch (lhs, rhs) {
        case (.couldNotCreateRequest, couldNotCreateRequest): return true
        case (.genericError, .genericError): return true
        case (.noData, .noData): return true
        case (.responseAlreadyInProgress, .responseAlreadyInProgress): return true
        case (.httpURLResponseError, .httpURLResponseError): return true
        default: return false
        }
    }
}
