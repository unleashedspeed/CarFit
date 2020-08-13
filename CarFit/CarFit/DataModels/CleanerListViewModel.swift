//
//  CleanerListViewModel.swift
//  CarFit
//
//  Created by Saurabh Gupta on 06/07/20.
//  Copyright © 2020 Test Project. All rights reserved.
//

import Foundation
import CoreLocation
		
// MARK: CleanerListViewModel representing as DataSource for all CarWashVisits
class CleanerListViewModel: NSObject {
    
    var job: CarWash?
    var carWashVisits = [String: Any]()
    var selectedDates = [String]()
    var notifyObserver: ((Error?) -> Void)?
    
    override init() {
        super.init()
        
        fetchAllData()
    }
    
    //MARK: Fetch all the data from Json file
    func fetchAllData() {
        guard let data = CarFitUtils.dataFromFile("carfit") else {
            notifyObserver?(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "File not found."]))
            
            return
        }
        
        do {
            job = try JSONDecoder().decode(CarWash.self, from: data)
        } catch {
            notifyObserver?(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Data could not be parsed."]))
        }
    }
    
    //MARK: Refreshes data from file (or API if exist) and filter for selected date.
    func refreshData() {
        fetchAllData()
        
        for date in selectedDates {
            filterData(for: date) { (washVisits) in
                self.carWashVisits[date] = washVisits
            }
        }
        
        
        notifyObserver?(nil)
    }
    
    //MARK: Invalidates carWashVisits and filters carWashVisits for all selected date.
    func filterWashVisits(for date: String) {
        carWashVisits.removeAll()
        selectedDates.append(date)
        for date in selectedDates {
            filterData(for: date) { (washVisits) in
                if washVisits.count > 0 {
                    self.carWashVisits[date] = washVisits
                }
            }
        }
                
        notifyObserver?(nil)
    }
    
    //MARK: Removes carWashVisits for selected date.
    func removeData(for date: String) {
        if let index = selectedDates.firstIndex(of: date) {
            selectedDates.remove(at: index)
        }
        carWashVisits.removeValue(forKey: date)
        notifyObserver?(nil)
    }
    
    //MARK: Filters carWashVisits for a selected date.
    private func filterData(for date: String, completion: @escaping ([CarWashVisitViewModel]) -> Void) {
        if let filteredVisits = job?.visits.filter ({ (visit) -> Bool in
            if let visitStartTime = visit.startTimeUtc, let visitDate = Date.getDate(from: visitStartTime, timeZone: .current) {
                return Date.getString(fromDate: visitDate, timeZone: .current, dateFormat: .yearMonthAndDate) == date
            }
            
            return false
        }) {
            var washVisits = [CarWashVisitViewModel]()
            var previousVisit:CarWashVisit? = nil
            for carWashVisit in filteredVisits {
                washVisits.append(CarWashVisitViewModel(currentCarWashVisit: carWashVisit, lastCarWashVisit: previousVisit))
                previousVisit = carWashVisit
            }
    
            completion(washVisits)
        }
    }
    
    var title: String? {
        if selectedDates.count > 1 {
           return NSLocalizedString("Jobs", comment: "Represents Jobs for multiple dates.")
        } else if selectedDates.count == 1 && selectedDates.first == Date.getString(fromDate: Date(), timeZone: .current, dateFormat: .yearMonthAndDate) {
            return NSLocalizedString("I DAG", comment: "Represents Today")
        }
        
        return nil
    }
    
    func titleFor(section: Int) -> String {
        return selectedDates[section]
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if let visits = carWashVisits[selectedDates[section]] as? [CarWashVisitViewModel] {
            return visits.count
        }
        
        return 0
    }
    
    func washVisit(for indexPath: IndexPath) -> CarWashVisitViewModel? {
        return (carWashVisits[selectedDates[indexPath.section]] as? [CarWashVisitViewModel])?[indexPath.row]
    }
}

// MARK: CarWashVisitViewModel representing as DataSource for single CarWashVisit
class CarWashVisitViewModel: NSObject {
    var currentCarWashVisit: CarWashVisit
    var lastCarWashVisit: CarWashVisit?
    
    init(currentCarWashVisit: CarWashVisit, lastCarWashVisit: CarWashVisit?) {
        self.currentCarWashVisit = currentCarWashVisit
        self.lastCarWashVisit = lastCarWashVisit
    }
    
    var ownerName: String {
        var houseOwnerFullName = ""
        if let firstName = currentCarWashVisit.houseOwnerFirstName {
            houseOwnerFullName += firstName
        }
        if let lastName = currentCarWashVisit.houseOwnerLastName {
            houseOwnerFullName += " " + lastName
        }
        
        return houseOwnerFullName
    }
    
    var ownerAddress: String {
        var houseOwnerFullAddress = ""
        if let ownerAddress = currentCarWashVisit.houseOwnerAddress {
            houseOwnerFullAddress += ownerAddress
        }
        if let ownerZip = currentCarWashVisit.houseOwnerZip {
            houseOwnerFullAddress += " " + ownerZip
        }
        if let ownerCity = currentCarWashVisit.houseOwnerCity {
            houseOwnerFullAddress += " " + ownerCity
        }
        
        return houseOwnerFullAddress
    }
    
    var tasks: String? {
        guard let carWashTasks = currentCarWashVisit.tasks else { return nil }
        let tasksArray = carWashTasks.map { $0.title ?? "" }
    
        return tasksArray.joined(separator: ", ")
    }
    
    var totalTimeRequired: String? {
        guard let carWashTasks = currentCarWashVisit.tasks else { return nil }
        let tasksTimeArray = carWashTasks.map { $0.timesInMinutes ?? 0}
        
        return "\(tasksTimeArray.reduce(0, +)) min"
    }
    
    var visitState: VisitState? {
        return VisitState(rawValue: currentCarWashVisit.visitState ?? "")
    }
    
    var arrivalTime: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let startTime = dateFormatter.date(from: currentCarWashVisit.startTimeUtc ?? ""), let expectedTime = currentCarWashVisit.expectedTime {
            let convertDateFormatter = DateFormatter()
            convertDateFormatter.dateFormat = "HH:mm"
            
            return convertDateFormatter.string(from: startTime) + " / " + expectedTime.replacingOccurrences(of: "/", with: "-")
        }
        
        return nil
    }
    
    var distance: String? {
        // If we don't have distance information we a default value of 0 km
        guard let lastCarWashVisitLatitude = lastCarWashVisit?.houseOwnerLatitude, let lastCarWashVisitLongitude = lastCarWashVisit?.houseOwnerLongitude, let currentCarWashVisitLatitude = currentCarWashVisit.houseOwnerLatitude, let currentCarWashVisitLongitude = currentCarWashVisit.houseOwnerLongitude else { return "0 km" }
        
        let lastLocation = CLLocation(latitude: lastCarWashVisitLatitude, longitude: lastCarWashVisitLongitude)
        let currentLocation = CLLocation(latitude: currentCarWashVisitLatitude, longitude: currentCarWashVisitLongitude)
        let visitDistance = lastLocation.distance(from: currentLocation)

        return "\((visitDistance / 1000).roundToDecimal(2)) km"
    }
    
    var visitDate: Date {
        if let startTime = currentCarWashVisit.startTimeUtc, let date = Date.getDate(from: startTime, timeZone: .current, dateFormat: .dateFormatFromAPI)  {
            return date
        }
        
        return Date()
    }
}
