//
//  JogModel.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

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
}
