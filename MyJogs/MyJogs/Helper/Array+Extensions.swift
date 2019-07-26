//
//  Array+Extensions.swift
//  MyJogs
//
//  Created by thomas lacan on 26/07/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> Bool {
        if !contains(element) {
            append(element)
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func removeElement(_ element: Element) -> Bool {
        if let index = firstIndex(of: element) {
            remove(at: index)
            return true
        }
        return false
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
