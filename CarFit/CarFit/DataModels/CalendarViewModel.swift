//
//  CalenderViewModel.swift
//  CarFit
//
//  Created by Saurabh Gupta on 07/07/20.
//  Copyright © 2020 Test Project. All rights reserved.
//

import Foundation

class CalendarViewModel {
    
    var date = Date()
    private var dateSelected = [Date().dateComponent]
    var notifyDateChanged: ((String) -> ())?
    var notifyMonthChanged: (() -> ())?
    var notifyDateDeselected: ((String) -> ())?

    private var day: Int {            
        return Calendar.current.component(.day, from: date)
    }
    
    private var month: Int {
        return Calendar.current.component(.month, from: date)
    }
    
    private var year: Int {
        return Calendar.current.component(.year, from: date)
    }
    
    var numberOfDays: Int {
        return date.daysInAMonth
    }

    var monthAndYear: String? {
        let date = Date.getDate(from: "\(month)-\(year)", timeZone: .current, dateFormat: .monthAndYear)
        
        return Date.getString(fromDate: date ?? Date(), timeZone: .current, dateFormat: .stringMonthAndYear)
    }

    var selectedDates: [Date] {
        dateSelected
    }
    
    var selectedDateIndexPath: IndexPath? {
        return IndexPath(item: day - 1, section: 0)
    }
    
    func date(for day: Int) -> Date {
        return Date.getDate(from: "\(day)-\(month)-\(year)", timeZone: .current, dateFormat: .dateMothAndYear) ?? Date()
    }

    //MARK: Prepares the ViewModel to set data based on date selected and notifies the view controller.
    func changeDate(_ date: Date) {
        dateSelected.append(date)
        notifyDateChanged?(Date.getString(fromDate: date, timeZone: .current, dateFormat: .yearMonthAndDate))
    }
    
    func changeMonth(offSet: Int) {
        var date = self.date.slideMonth(offset: offSet)
        if date.belongsToCurrentMonth {
            date = Date().dateComponent
        } else {
            date = date.startingDayOfMonth
        }
        self.date = date

        notifyMonthChanged?()
    }
    
    func didDeselectDate(_ date: Date) {
        if let index = dateSelected.firstIndex(of: date) {
            let deselectedDate = dateSelected.remove(at: index)
            notifyDateDeselected?(Date.getString(fromDate: deselectedDate, timeZone: .current, dateFormat: .yearMonthAndDate))
        }
    }
}

class CalenderDayViewModel: NSObject {
    
    private var date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    var weekday: String? {
        return Date.getString(fromDate: date, timeZone: .current, dateFormat: .weekDayEEE)
    }

    var day: String? {
        return Date.getString(fromDate: date, timeZone: .current, dateFormat: .day)
    }

    var selectedDate: Date {
        return date
    }
}
