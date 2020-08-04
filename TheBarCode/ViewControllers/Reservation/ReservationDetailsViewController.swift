//
//  ReservationDetailsViewController.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView

class ReservationDetailsViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    @IBOutlet var closeBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var headerView: UIView!
    
    var showHeader: Bool = false
    
    var reservation: Reservation!
    var viewModels: [OrderViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Table Reservations"
        self.setUpStatefulTableView() 
        self.setupViewModel()

        if self.showHeader {
            self.statefulTableView.innerTable.tableHeaderView = self.headerView
        } else {
            let aView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 16.0))
            aView.backgroundColor = UIColor.clear
            self.statefulTableView.innerTable.tableHeaderView = aView
        }
        
        self.closeBarButtonItem.image = self.closeBarButtonItem.image?.withRenderingMode(.alwaysOriginal)
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
              
        self.statefulTableView.innerTable.register(cellType: OrderInfoTableViewCell.self)

        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
              
        self.statefulTableView.backgroundColor = .clear
        for aView in self.statefulTableView.subviews {
            aView.backgroundColor = .clear
        }
              
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.canPullToRefresh = false
        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
        self.statefulTableView.innerTable.estimatedRowHeight = 200.0
        self.statefulTableView.innerTable.tableFooterView = UIView()

    }
    
    func setupViewModel() {
        
        let barInfo = BarInfo(barName: self.reservation.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)
        
        
        let reservationInfo1 = ReservationInfo(title: "Date", value: self.reservation.date)
        let reservationInfo2 = ReservationInfo(title: "Time", value: self.reservation.time )
        let reservationInfo3 = ReservationInfo(title: "Number of People", value: "\(self.reservation.noOfPersons)" )
        let reservationInfo4 = ReservationInfo(title: "Card selected", value: "Visa-->Ending In-->1881", type: .card)

        let reservationInfoViewModel = ReservationInfoViewModel(items: [reservationInfo1, reservationInfo2, reservationInfo3, reservationInfo4])
        self.viewModels.append(reservationInfoViewModel)
    
        
        let reservationStatusInfo = ReservationInfo(title: "Reservation status", value: self.reservation.status.rawValue )
        let reservationStatusViewModel = ReservationStatusViewModel(items: [reservationStatusInfo])
        self.viewModels.append(reservationStatusViewModel)

    }

    //MARK: IBActions
    @IBAction func closeBarButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension ReservationDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
          return self.viewModels.count
      }
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          let viewModel = self.viewModels[section]
          return viewModel.rowCount
    }
      
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = self.viewModels[indexPath.section]
        
        if let section = viewModel as? BarInfoSection {
               
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(barInfo: section.items[indexPath.row], showSeparator: true)
            cell.adjustMargins(adjustTop: true, adjustBottom: true)
            return cell
            
        } else  if let section = viewModel as? ReservationInfoViewModel {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            let reservationInfo = section.items[indexPath.row]
            
            cell.setupCell(reservationInfo: reservationInfo, showSeparator: true)
            cell.adjustMargins(adjustTop: true, adjustBottom: true)
            cell.maskCorners(radius: 0.0, mask: [])
            return cell
                   
        } else if let section = viewModel as? ReservationStatusViewModel {

            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(reservationInfo: section.items[indexPath.row], status: self.reservation.status, showSeparator: false)
            cell.adjustMargins(adjustTop: true, adjustBottom: true)
            cell.maskCorners(radius: 8.0, mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            
            return cell
            
        } else {
            return UITableViewCell()
        }
     
    }
         
    

}
