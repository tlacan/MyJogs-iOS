//
//  JogModel.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import CoreLocation

struct PositionModel: Codable {
    let lat: Double
    let lon: Double
}

struct JogModel: Codable {
    var id: Int?
    var userId: Int
    var position: [PositionModel]
    var beginDate: Date
    var endDate: Date?
    var totalDistance: Double?
    
    func computedDistance() -> Double {
        if let totalDistance = totalDistance {
            return totalDistance
        }
        var result: Double = 0
        for index in 1...position.count {
            if let posA = position[safe: index - 1], let posB = position[safe: index] {
                let posALoc = CLLocation(latitude: posA.lat, longitude: posA.lon)
                let posBLoc = CLLocation(latitude: posB.lat, longitude: posB.lon)
                result += posBLoc.distance(from: posALoc)
            }
        }
        return result
    }
    
    func durationFormatted() -> String {
        guard let endDate = endDate else { return "" }
        let duration = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970)
        let timeFormatter = Date.timeOnlyFormatter
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return timeFormatter.string(from: duration)
    }
    
    func dateFormatted() -> String {
        let dateFormatter = Date.dmyFormatter
        return dateFormatter.string(from: beginDate)
    }
    
    func averageSpeed() -> String {
        guard let endDate = endDate else { return "" }
        let distanceInKm = computedDistance() / 1000.0
        let duration = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970)
        let seconds = Double(Int(duration.timeIntervalSince1970) % 60)
        let speed = Double(round(10 * ((distanceInKm * 3600.0) / seconds)) / 10)
        return "\(speed) km/h"
    }
}
