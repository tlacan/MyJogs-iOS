//
//  WeakServiceOrderedSet.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
struct WeakObserverOrderedSet<T> {
    
    struct Weak {
        weak var value: AnyObject?
        init(_ value: AnyObject) {
            self.value = value
        }
    }
    
    var elements: [Weak] = []
    
    private func indexOf(value: AnyObject) -> Int? {
        for (idx, val) in elements.enumerated() where val.value === value {
            return idx
        }
        return nil
    }
    
    mutating func add(value: T) {
        let anyValue = value as AnyObject
        guard indexOf(value: anyValue) == nil else { return }
        elements.append(Weak(anyValue))
    }
    
    mutating func remove(value: T) {
        let anyValue = value as AnyObject
        guard let i = indexOf(value: anyValue) else { return }
        elements.remove(at: i)
    }
    
    mutating func removeReleasedObservers() {
        elements = elements.filter { $0.value != nil}
    }
    
    func invoke(_ function: ((T) -> Void)) {
        for elem in elements {
            if let eVal = elem.value as? T {
                function(eVal)
            }
        }
    }
}
