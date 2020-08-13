//
//  ReviewPaymentViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 12/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView

class ReviewPaymentViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
   
    @IBOutlet var payButton: UIButton!
    
    var order: Order!
    var viewModels: [OrderViewModel] = []
    
    var totalBillPayable: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Split The Bill"
        
        let paymentHeading = Heading(title: "BILL SPLIT")
        let paymentHeadingSection = HeadingSection(items: [paymentHeading])
        self.viewModels.append(paymentHeadingSection)
        
        let orderPaymentInfo1 = OrderPaymentInfo(title: "BEN MILNES", percentage: 50, status: "Paid", price: 11.5)
        let orderPaymentInfo2 = OrderPaymentInfo(title: "YOU", percentage: 50, status: "Paid", price: 11.5)
        let orderPaymentInfoSection = OrderPaymentInfoSection(items: [orderPaymentInfo1, orderPaymentInfo2])
        self.viewModels.append(orderPaymentInfoSection)
        
        self.payButton.setTitle(String(format: "Confirm Pay - £ %.2f", self.totalBillPayable), for: .normal)
        
        self.setUpStatefulTableView()
    }
    

     //MARK: My Methods
    func setUpStatefulTableView() {
         
        self.statefulTableView.innerTable.register(cellType: OrderInfoTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderStatusTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderPaymentTableViewCell.self)

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
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView

     }
    
    func moveToPaymentMethods() {
        let controller = (self.storyboard!.instantiateViewController(withIdentifier: "SavedCardsViewController") as! SavedCardsViewController)
        controller.totalBillPayable = self.totalBillPayable
        controller.order = self.order
        controller.viewModels = self.viewModels
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: My IBActions
    @IBAction func payButtonTapped(sender: UIButton) {
        self.moveToPaymentMethods()
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension ReviewPaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
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
        
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.rowCount - 1
        
        if let section = viewModel as? OrderStatusSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderStatusTableViewCell.self)
            cell.setupCell(orderStatusInfo: section.items[indexPath.row], showSeparator: false)
            return cell

        } else if let section = viewModel as? BarInfoSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(barInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
        
        } else if let section = viewModel as? OrderProductsInfoSection {
     
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderItem: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell

        } else if let section = viewModel as? OrderDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDiscountInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: false)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? HeadingSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderStatusTableViewCell.self)
            cell.setupCell(heading: section.items[indexPath.row], showSeparator: section.shouldShowSeparator)
            return cell
            
        } else if let section = viewModel as? OrderPaymentInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderPaymentTableViewCell.self)
            cell.setupCell(orderPaymentInfo: section.items[indexPath.row], showSeparator: section.shouldShowSeparator)
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
    }
}
