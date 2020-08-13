//
//  CalendarView.swift
//  Calendar
//
//  Test Project
//

import UIKit

protocol CalendarDelegate: class {
    func getSelectedDate(_ date: String)
    func getDeSelectedDate(_ date: String)
}

class CalendarView: UIView {

    @IBOutlet weak var monthAndYear: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var daysCollectionView: UICollectionView!
    
    private let cellID = "DayCell"
    weak var delegate: CalendarDelegate?
    
    private var calendarViewModel: CalendarViewModel!

    //MARK:- Initialize calendar
    private func initialize() {
        let nib = UINib(nibName: self.cellID, bundle: nil)
        self.daysCollectionView.register(nib, forCellWithReuseIdentifier: self.cellID)
        self.daysCollectionView.delegate = self
        self.daysCollectionView.dataSource = self
        self.daysCollectionView.allowsMultipleSelection = true
        fetchCalendarData()
        bindViewModelObserver()
    }
    
    //MARK:- Initializes calendarViewModel to load calender with current month.
    private func fetchCalendarData() {
        calendarViewModel = CalendarViewModel()
        monthAndYear.text = calendarViewModel.monthAndYear
        if let indexPath = self.calendarViewModel.selectedDateIndexPath {
            self.daysCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
    //MARK:- Binds calendarViewModel data update observers to view
    private func bindViewModelObserver() {
        calendarViewModel.notifyDateChanged = { date in
            self.daysCollectionView.reloadData()
            self.delegate?.getSelectedDate(date)
        }
        
        calendarViewModel.notifyMonthChanged = {
            self.daysCollectionView.reloadData()
            self.monthAndYear.text = self.calendarViewModel.monthAndYear
            
            if let indexPath = self.calendarViewModel.selectedDateIndexPath {
                self.daysCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            }
        }
        
        calendarViewModel.notifyDateDeselected = { date in
            self.delegate?.getDeSelectedDate(date)
            self.daysCollectionView.reloadData()
        }
    }
    
    //MARK:- Change month when left and right arrow button tapped
    @IBAction func arrowTapped(_ sender: UIButton) {
        calendarViewModel.changeMonth(offSet: sender == leftBtn ? -1 : 1)
    }
}

//MARK:- Calendar collection view delegate and datasource methods
extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarViewModel.numberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! DayCell
        cell.dayCellViewModel = CalenderDayViewModel(date: calendarViewModel.date(for: indexPath.item + 1))
        cell.ifSelected = calendarViewModel.selectedDates.contains(cell.dayCellViewModel.selectedDate)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DayCell {
            if cell.ifSelected {
                calendarViewModel.didDeselectDate(cell.dayCellViewModel.selectedDate)
            } else {
                calendarViewModel.changeDate(cell.dayCellViewModel.selectedDate)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        /*TODO:  For some unknown reason this delegate doesn't get called when a date is deselected rather didSelectItemAt gets called.
                 So didSelectItemAt is handling deselection of date a present by tracking cell's ifSelected property. This should be replaced
                 with didSelectItemAt
        */
    }
    
}

//MARK:- Add calendar to the view
extension CalendarView {
    
    public class func addCalendar(_ superView: UIView) -> CalendarView? {
        var calendarView: CalendarView?
        if calendarView == nil {
            calendarView = UINib(nibName: "CalendarView", bundle: nil).instantiate(withOwner: self, options: nil).last as? CalendarView
            guard let calenderView = calendarView else { return nil }
            calendarView?.frame = CGRect(x: 0, y: 0, width: superView.bounds.size.width, height: superView.bounds.size.height)
            superView.addSubview(calenderView)
            calenderView.initialize()
            return calenderView
        }
        return nil
    }
    
}
