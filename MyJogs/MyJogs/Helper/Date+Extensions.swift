//
//  Date+Extensions.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
extension Date {
    @nonobjc static let dmyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    @nonobjc static let dmyhmsFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return df
    }()
    
    @nonobjc static let timeOnlyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
        
    }()
    
    @nonobjc static let mediumDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale(identifier: "fr_FR")
        return df
    }()
    
    @nonobjc static var fullDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "d MMMM yyyy"
        return df
    }()
    
    @nonobjc static let fullDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "d MMMM yyyy 'à' hh:mm:ss"
        return df
    }()
    
    static func hoursMinutesDateTimeFormatter(separator: String = ":") -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "HH'\(separator)'mm"
        return df
    }
    
    @nonobjc static let hoursMinutesDateAltTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "H'h'mm"
        return df
    }()
    
    @nonobjc static let weekDayIndexFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "e"
        return df
    }()
    
    @nonobjc static let weekDayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "EEEE"
        return df
    }()
    
    @nonobjc static let DayFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "d"
        return df
    }()
    
    @nonobjc static let MonthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "MMMM"
        return df
    }()
    
    @nonobjc static let MonthYearFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr")
        df.dateFormat = "MMMM YYYY"
        return df
    }()
    
    static let defaultDate = "01/01/1980"
    static let minimimDefaultDate = "01/01/1980"
    
    static func fromDMY(_ dmy: String) -> Date? {
        return Date.dmyFormatter.date(from: dmy)
    }
    
    static func fromDMYHMS(_ dmyhms: String) -> Date? {
        return Date.dmyhmsFormatter.date(from: dmyhms)
    }
    
    static func dmyDateForNow() -> Date? {
        let dc = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        return Date.fromDMY(String(format: "%02d/%02d/%04d", dc.day!, dc.month!, dc.year!))
    }
    
    static func fromFullString(_ ddMMMMyyyy: String) -> Date? {
        return Date.fullDateFormatter.date(from: ddMMMMyyyy)
    }
    
    func stringMediumDate() -> String {
        return Date.mediumDateFormatter.string(from: self)
    }
    
    func stringFullDate() -> String {
        return Date.fullDateFormatter.string(from: self)
    }
    
    func stringDate() -> String {
        return Date.dmyFormatter.string(from: self)
    }
    
    func stringDayDate() -> String {
        return Date.DayFormatter.string(from: self)
    }
    
    func stringMonthDate() -> String {
        return Date.MonthFormatter.string(from: self)
    }
    
    func stringMonthYearDate() -> String {
        return Date.MonthYearFormatter.string(from: self)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    func daysUntilNow() -> Int? {
        let calendar = NSCalendar.current
        
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: self)
            ).day
    }
}
