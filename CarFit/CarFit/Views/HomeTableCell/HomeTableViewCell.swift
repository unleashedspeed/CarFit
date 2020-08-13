//
//  HomeTableViewCell.swift
//  Calendar
//
//  Test Project
//

import UIKit
import CoreLocation

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var customer: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var tasks: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var timeRequired: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var carWashVisitViewModel: CarWashVisitViewModel! {
        didSet {
            customer.text = carWashVisitViewModel.ownerName
            destination.text = carWashVisitViewModel.ownerAddress
            tasks.text = carWashVisitViewModel.tasks
            timeRequired.text = carWashVisitViewModel.totalTimeRequired
            status.text = carWashVisitViewModel.visitState?.rawValue
            arrivalTime.text = carWashVisitViewModel.arrivalTime
            distance.text = carWashVisitViewModel.distance
            
            switch carWashVisitViewModel.visitState {
            case .done:
                statusView.backgroundColor = .doneOption
            case .toDo:
                statusView.backgroundColor = .todoOption
            case .inProgress:
                statusView.backgroundColor = .inProgressOption
            case .rejected:
                statusView.backgroundColor = .rejectedOption
            case .none:
                // A default Color can be set here
                statusView.backgroundColor = .white
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.layer.cornerRadius = 10.0
        self.statusView.layer.cornerRadius = self.status.frame.height / 2.0
        self.statusView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }

}
