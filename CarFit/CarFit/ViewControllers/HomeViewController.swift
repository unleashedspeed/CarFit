//
//  ViewController.swift
//  Calendar
//
//  Test Project
//

import UIKit

class HomeViewController: UIViewController, AlertDisplayer {

    @IBOutlet var navBar: UINavigationBar!
    @IBOutlet var calendarView: UIView!
    @IBOutlet weak var calendar: UIView!
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    @IBOutlet weak var workOrderTableView: UITableView!
    @IBOutlet weak var calenderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var workOrderTopContraint: NSLayoutConstraint!
    
    private let cellID = "HomeTableViewCell"
    fileprivate var viewModel: CleanerListViewModel!
    var calenderViewHeightConstant: CGFloat {
        return 200
    }
    var workOrderTopConstant: CGFloat {
        return 112
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)

        return refreshControl
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addCalendar()
        hideCalenderView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        initializeViewModelAndBindObserver()
        fetchData()
    }
    
    //MARK:- Add calender to view
    private func addCalendar() {
        if let calendar = CalendarView.addCalendar(self.calendar) {
            calendar.delegate = self
        }
    }

    //MARK:- UI setups
    private func setupUI() {
        self.navBar.transparentNavigationBar()
        let nib = UINib(nibName: self.cellID, bundle: nil)
        self.workOrderTableView.register(nib, forCellReuseIdentifier: self.cellID)
        self.workOrderTableView.rowHeight = UITableView.automaticDimension
        self.workOrderTableView.estimatedRowHeight = 170
        workOrderTableView.refreshControl = refreshControl
        workOrderTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideCalender)))
    }
    
    //MARK:- Initializes viewModel and binds its data update observer to view
    private func initializeViewModelAndBindObserver() {
        viewModel = CleanerListViewModel()
        viewModel.notifyObserver = { error in
            if error == nil {
                DispatchQueue.main.async {
                    self.workOrderTableView.reloadData()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                    self.navBar.topItem?.title = self.viewModel.title
                }
            } else {
                self.displayAlert(with: NSLocalizedString("Error", comment: "Error"), message: error?.localizedDescription ?? NSLocalizedString("Some Error Occured.", comment: "Error Message"), actions: [UIAlertAction(title: NSLocalizedString("Ok", comment: "Error"), style: .default, handler: nil)])
            }
        }
    }
    
    //MARK: Start fetching data for default date i.e. today
    private func fetchData() {
        let today = Date.getString(fromDate: Date(), timeZone: .current, dateFormat: .yearMonthAndDate)
        viewModel.filterWashVisits(for: today)
    }
    
    //MARK:- Refresh the view
    @objc func handleRefresh() {
        viewModel.refreshData()
    }
    
    //MARK:- Animate and discard calender view
    fileprivate func hideCalenderView() {
        calenderViewHeightConstraint.constant = 0
        workOrderTopContraint.constant = 0
    }
    
    @objc func hideCalender() {
        hideCalenderView()
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- Show calendar when tapped, Hide the calendar when tapped outside the calendar view
    @IBAction func calendarTapped(_ sender: UIBarButtonItem) {
        calenderViewHeightConstraint.constant = calenderViewHeightConstant
        workOrderTopContraint.constant = workOrderTopConstant
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
}


//MARK:- Tableview delegate and datasource methods
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.carWashVisits.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! HomeTableViewCell
        if let carWashVisitViewModel = viewModel.washVisit(for: indexPath) {
            cell.carWashVisitViewModel = carWashVisitViewModel
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleFor(section: section)
    }
}

//MARK:- Get selected calendar date
extension HomeViewController: CalendarDelegate {
    
    func getSelectedDate(_ date: String) {
        viewModel.filterWashVisits(for: date)
    }
    
    func getDeSelectedDate(_ date: String) {
        viewModel.removeData(for: date)
    }
}
