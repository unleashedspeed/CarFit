//
//  DayCell.swift
//  Calendar
//
//  Test Project
//

import UIKit

class DayCell: UICollectionViewCell {

    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var weekday: UILabel!
    
    var dayCellViewModel: CalenderDayViewModel! {
        didSet {
            day.text = dayCellViewModel.day
            weekday.text = dayCellViewModel.weekday
        }
    }
    
    var ifSelected: Bool! {
        didSet {
            dayView.backgroundColor = ifSelected ? .daySelected : .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dayView.layer.cornerRadius = self.dayView.frame.width / 2.0
        self.dayView.backgroundColor = .clear
    }
    
}
