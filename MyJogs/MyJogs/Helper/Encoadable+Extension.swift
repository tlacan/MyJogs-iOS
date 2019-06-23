//
//  Encoadable+Extension.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

extension Encodable {
    
    func toData(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.keyEncodingStrategy = .useDefaultKeys
        let data = try? encoder.encode(self)
        return data
    }
    
    func toJSONDict(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(.dateTimeIso8601)) -> [String: Any]? {
        guard let data = toData(dateEncodingStrategy: dateEncodingStrategy) else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch let error {
            LOG("[Encodable+Extension] Unable to dump to dict \(error)")
            return nil
        }
    }
}
