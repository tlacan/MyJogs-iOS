//
//  Data+Extensions.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

extension Data {
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        } catch {
            if count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw NSError(domain: "Data.mapJSON", code: 1, userInfo: nil)
        }
    }
}
