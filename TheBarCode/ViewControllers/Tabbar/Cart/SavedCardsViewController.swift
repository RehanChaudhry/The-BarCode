//
//  SavedCardsViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 08/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class SavedCardsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var payButton: GradientButton!
    
    var cards: [String] = [""]
    
    var order: Order!
    var viewModels: [OrderViewModel] = []
    var totalBillPayable: Double = 0.0
    
    enum CardSectionType: Int {
        case info = 0, addCard = 1
        
        static func allTypes() -> [CardSectionType] {
            return [.info, .addCard]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Payment Methods"
        
        self.tableView.tableHeaderView = self.headerView
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(cellType: CardInfoCell.self)
        self.tableView.register(cellType: AddNewCardCell.self)
        
        self.payButton.setTitle(String(format: "Pay - £ %.2f", self.totalBillPayable), for: .normal)
    }
    
    func moveToThankYou() {
        let controller = (self.storyboard!.instantiateViewController(withIdentifier: "ThankYouViewController") as! ThankYouViewController)
        controller.order = self.order
        controller.viewModels = self.viewModels
        self.navigationController?.setViewControllers([controller], animated: true)
    }
    
    //MARK: My IBActions
    @IBAction func payButtonTapped(sender: UIButton) {
        self.moveToThankYou()
    }
    

}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SavedCardsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CardSectionType.allTypes().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == CardSectionType.info.rawValue {
            return self.cards.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == CardSectionType.info.rawValue {
            
            let isFirstCell = indexPath.row == 0
            
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: CardInfoCell.self)
            cell.setUpCell()
            cell.maskCorners(radius: 8.0, mask: isFirstCell ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [])
            return cell
        } else if indexPath.section == CardSectionType.addCard.rawValue {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: AddNewCardCell.self)
            cell.maskCorners(radius: 8.0, mask: self.cards.count == 0 ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: AddNewCardCellDelegate
extension SavedCardsViewController: AddNewCardCellDelegate {
    func addNewCardCell(cell: AddNewCardCell, addNewCardButtonTapped sender: UIButton) {
        let addCardNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "AddCardNavigation") as! UINavigationController)
        addCardNavigation.modalPresentationStyle = .fullScreen
        self.navigationController?.present(addCardNavigation, animated: true, completion: nil)
    }
}
