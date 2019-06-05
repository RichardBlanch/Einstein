//
//  Collection+Extension.swift
//  Einstein iOS
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }

        return self[index]
    }
}
