//
//  CarWashModel.swift
//  CarFit
//
//  Created by Saurabh Gupta on 06/07/20.
//  Copyright © 2020 Test Project. All rights reserved.
//

import Foundation

// MARK: Data Model for CarWashVisits to CarFitClients

struct CarWash: Codable {
    var visits = [CarWashVisit]()
    
    private enum CodingKeys: String, CodingKey {
        case visits = "data"
    }
}

struct CarWashVisit: Codable {
    let houseOwnerFirstName: String?
    let houseOwnerLastName: String?
    let visitState: String?
    let startTimeUtc: String?
    let expectedTime: String?
    let houseOwnerAddress: String?
    let houseOwnerZip: String?
    let houseOwnerCity: String?
    let houseOwnerLatitude: Double?
    let houseOwnerLongitude: Double?
    let tasks: [Task]?
    
    struct Task: Codable {
        let title: String?
        let timesInMinutes: Int?
    }
}

enum VisitState: String {
    case done = "Done"
    case toDo = "ToDo"
    case inProgress = "InProgress"
    case rejected = "Rejected"
}
