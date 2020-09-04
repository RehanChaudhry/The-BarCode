//
//  SavedCardsViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 08/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import PureLayout

class SavedCardsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var payButton: GradientButton!
    
    var cards: [CreditCard] = []
    
    var selectedCard: CreditCard?
    
    var order: Order!
    var viewModels: [OrderViewModel] = []
    var totalBillPayable: Double = 0.0
    
    var statefulView: LoadingAndErrorView!
    
    enum CardSectionType: Int {
        case info = 0, addCard = 1
        
        static func allTypes() -> [CardSectionType] {
            return [.info, .addCard]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Payment Method"
        
        self.tableView.tableHeaderView = self.headerView
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(cellType: CardInfoCell.self)
        self.tableView.register(cellType: AddNewCardCell.self)
        
        self.payButton.setTitle(String(format: "Pay - £ %.2f", self.totalBillPayable), for: .normal)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.backgroundColor = self.view.backgroundColor
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.getCards()
        }
        
        self.statefulView.autoPinEdge(toSuperviewSafeArea: ALEdge.top)
        self.statefulView.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self.view)
        self.statefulView.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self.view)
        self.statefulView.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self.view)
        
        self.getCards()
    }
    
    func moveToThankYou() {
        let controller = (self.storyboard!.instantiateViewController(withIdentifier: "ThankYouViewController") as! ThankYouViewController)
        controller.order = self.order
        controller.viewModels = self.viewModels
        self.navigationController?.setViewControllers([controller], animated: true)
    }
    
    func selectCardAt(index: Int) {
        self.selectedCard = self.cards[index]
        tableView.reloadData()
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
            
            let card = self.cards[indexPath.row]
            
            cell.setUpCell(card: card, isSelected: card.cardId == self.selectedCard?.cardId)
            cell.delegate = self
            
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
        
        if indexPath.section == CardSectionType.info.rawValue {
            self.selectCardAt(index: indexPath.row)
        }
        
    }
}

//MARK: Webservices Methods
extension SavedCardsViewController {
    func getCards() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathGetCards, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To refresh")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let data = responseDict?["data"] as? [[String : Any]] {
                self.cards.removeAll()
                let cards = Mapper<CreditCard>().mapArray(JSONArray: data)
                self.cards.append(contentsOf: cards)
                
                self.selectedCard = self.cards.first
                self.tableView.reloadData()
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
        }
    }
    
    func deleteCard(card: CreditCard) {
        card.isDeleting = true
        self.tableView.reloadData()
        
        let params: [String : Any] = ["card_id" : card.cardId]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathDeleteCard, method: .post) { (response, serverError, error) in
            card.isDeleting = false
            
            guard error == nil else {
                self.tableView.reloadData()
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.tableView.reloadData()
                self.showAlertController(title: "", msg: serverError!.detail)
                return
            }
            
            if let index = self.cards.firstIndex(where: {$0.cardId == card.cardId}) {
                self.cards.remove(at: index)
                
                if self.selectedCard?.cardId == card.cardId {
                    self.selectedCard = self.cards.first
                }
            }
            
            self.reloadAllSections()
        }
    }
    
    func reloadAllSections() {
        let sections = self.tableView.numberOfSections
        let indexSet = IndexSet(integersIn: 0..<sections)
        self.tableView.reloadSections(indexSet, with: .fade)
    }
}

//MARK: CardInfoCellDelegate
extension SavedCardsViewController: CardInfoCellDelegate {
    func cardInfoCell(cell: CardInfoCell, cardButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        self.selectCardAt(index: indexPath.row)
    }
    
    func cardInfoCell(cell: CardInfoCell, deleteButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        self.deleteCard(card: self.cards[indexPath.row])
    }
}

//MARK: AddNewCardCellDelegate
extension SavedCardsViewController: AddNewCardCellDelegate {
    func addNewCardCell(cell: AddNewCardCell, addNewCardButtonTapped sender: UIButton) {
        let addCardNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "AddCardNavigation") as! UINavigationController)
        addCardNavigation.modalPresentationStyle = .fullScreen
        
        let addCardController = addCardNavigation.viewControllers.first as! AddCardViewController
        addCardController.delegate = self
        
        self.navigationController?.present(addCardNavigation, animated: true, completion: nil)
    }
}

//MARK: AddCardViewControllerDelegate
extension SavedCardsViewController: AddCardViewControllerDelegate {
    func addCardViewController(controller: AddCardViewController, cardDidAdded card: CreditCard) {
        
        self.cards.insert(card, at: 0)
        if self.selectedCard == nil {
            self.selectedCard = card
        }
        
        self.tableView.reloadData()
    }
}
