//
//  App+Extensions.swift
//  Calendar
//
//Test Project

import UIKit

//MARK:- Navigation bar clear
extension UINavigationBar {
    
    func transparentNavigationBar() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
    
}

//MARK: Double Extension
extension Double {
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        
        return Darwin.round(self * multiplier) / multiplier
    }
}

//MARK: Date Extension
extension Date {
    
    //MARK: Converts a given string date to Date object.
    static func getDate(from string: String,
                        timeZone: TimeZone?,
                        dateFormat: DateFormat = .dateFormatFromAPI) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = timeZone
        
        return dateFormatter.date(from: string)
    }
    
    //MARK: Converts a given date to String object.
    static func getString(fromDate date: Date,
                          timeZone: TimeZone?,
                          dateFormat: DateFormat = .dateFormatFromAPI) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.timeZone = timeZone
        
        return dateFormatter.string(from: date)
    }

    func slideMonth(offset: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = offset
        
        return Calendar.current.date(byAdding: dateComponents, to: self) ?? Date()
    }

    var startingDayOfMonth: Date {
        var dateComp = Calendar.current.dateComponents([.year, .month,.day], from: self)
        dateComp.day = 1
        
        return Calendar.current.date(from: dateComp) ?? Date()
    }

    var belongsToCurrentMonth: Bool {
        let curDateComponents = Calendar.current.dateComponents([.month, .year, .day], from: Date())
        let components = Calendar.current.dateComponents([.month, .year, .day], from: self)
        
        return components.year == curDateComponents.year && components.month == curDateComponents.month
    }
    
    var daysInAMonth: Int {
        return Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
    }
    
    var dateComponent: Date {
        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: self)
        
        return Calendar.current.date(from: dateComp) ?? Date()
    }
    
    // Enums specific to Date Class.
    enum DateFormat: String {
        case dateFormatFromAPI = "yyyy-MM-dd'T'HH:mm:ss"
        case yearMonthAndDate = "yyyy-MM-dd"
        case dateMothAndYear = "dd-MM-yyyy"
        case monthAndYear = "MM-yyyy"
        case weekDayEEE = "EEE"
        case day = "d"
        case stringMonthAndYear = "MMM yyyy"
        case hourAndMinutes = "hh:mm a"
        case twentyFourHourhhmmss = "HH:mm:ss"
    }
}
