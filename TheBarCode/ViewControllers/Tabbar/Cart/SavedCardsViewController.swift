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
import CoreStore
import HTTPStatusCodes

class SavedCardsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var payButton: GradientButton!
    
    var cards: [CreditCard] = []
    
    var selectedCard: CreditCard? {
        didSet {
            if self.selectedCard == nil {
                payButton.updateColor(withGrey: true)
            } else {
                payButton.updateColor(withGrey: false)
            }
        }
    }
    
    var order: Order!
    
    var selectedVoucher: OrderDiscount?
    var selectedOffer: OrderDiscount?
    
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
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 16.0))
        footerView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = footerView
        
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
        
        self.selectedCard = nil
        
        self.getCards()
    }
    
    func moveToThankYou(order: Order) {
        let controller = (self.storyboard!.instantiateViewController(withIdentifier: "ThankYouViewController") as! ThankYouViewController)
        controller.order = order
        self.navigationController?.setViewControllers([controller], animated: true)
    }
    
    func selectCardAt(index: Int) {
        self.selectedCard = self.cards[index]
        tableView.reloadData()
    }
    
    func reloadAllSections() {
        let sections = self.tableView.numberOfSections
        let indexSet = IndexSet(integersIn: 0..<sections)
        self.tableView.reloadSections(indexSet, with: .fade)
    }
    
    func postDealRedeemNotificationIfNeeded() {
        if self.selectedOffer != nil {
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), self.order.barId))
                for bar in bars {
                    bar.canRedeemOffer.value = false
                }
            })
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
        }
    }
    
    //MARK: My IBActions
    @IBAction func payButtonTapped(sender: UIButton) {
        if let card = self.selectedCard {
            self.chargeCard(card: card)
        } else {
            self.showAlertController(title: "", msg: "Please select a card to proceed")
        }
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
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathCard, method: .get) { (response, serverError, error) in
            
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
        
        let params: [String : Any] = [:]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCard + "/\(card.cardId)", method: .delete) { (response, serverError, error) in
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
    
    func chargeCard(card: CreditCard) {
        
        let sessionId = UUID().uuidString
        
        var params: [String : Any] = ["order_id" : self.order.orderNo,
                                      "token" : card.cardToken,
                                      "session_id" : sessionId]
        
        if let split = self.order.splitPaymentInfo, split.type != .none {
            params["split_type"] = split.type.rawValue
            params["value"] = split.value
        }
        
        if let voucher = self.selectedVoucher {
            params["voucher_id"] = voucher.id
        }
        
        if let offer = self.selectedOffer {
            params["offer_id"] = offer.id
            params["offer_type"] = offer.typeRaw
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.payButton.showLoader()
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathPayment, method: .post) { (response, serverError, error) in
            self.payButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.payButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                if serverError?.statusCode == HTTPStatusCode.preconditionRequired.rawValue {
                    
                    guard let responseDict = (serverError!.rawResponse["response"] as? [String : Any]) else {
                        self.showAlertController(title: "", msg: APIHelper.shared.getGenericError().localizedDescription)
                        return
                    }
                    
                    let context = ThreeDSModelMapContext(sessionId: sessionId)
                    let threeDSModel = Mapper<ThreeDSModel>(context: context).map(JSON: responseDict)!
                    
                    let threeDSNavigation = self.storyboard!.instantiateViewController(withIdentifier: "ThreeDSNavigation") as! UINavigationController
                    threeDSNavigation.modalPresentationStyle = .fullScreen
                    
                    let threeDsWebController = threeDSNavigation.viewControllers.first as! ThreeDSWebViewController
                    threeDsWebController.threedsModel = threeDSModel
                    threeDsWebController.delegate = self
                    self.present(threeDSNavigation, animated: true, completion: nil)
                } else {
                    self.showAlertController(title: "", msg: serverError!.detail)
                }
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseObject = (responseDict?["data"] as? [String : Any]) {
                
                let context = OrderMappingContext(type: .order)
                let order = Mapper<Order>(context: context).map(JSON: responseObject)!
                
                self.moveToThankYou(order: order)
                self.postDealRedeemNotificationIfNeeded()
                
                NotificationCenter.default.post(name: notificationNameOrderPlaced, object: order)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
    }
    
    func updatePaymentStatus(secureCode: String, model: ThreeDSModel) {
        let params: [String : Any] = ["session_id" : model.sessionId,
                                      "order_id" : self.order.orderNo,
                                      "payment_code" : model.paymentCode,
                                      "secure_code" : secureCode]
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.payButton.showLoader()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathUpdatePayment, method: .post) { (response, serverError, error) in
            self.payButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.payButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.detail)
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseObject = (responseDict?["data"] as? [String : Any]) {
                
                let context = OrderMappingContext(type: .order)
                let order = Mapper<Order>(context: context).map(JSON: responseObject)!
                
                self.moveToThankYou(order: order)
                self.postDealRedeemNotificationIfNeeded()
                
                NotificationCenter.default.post(name: notificationNameOrderPlaced, object: order)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
        
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
        self.selectedCard = card

        self.tableView.reloadData()
    }
}

//MARK: ThreeDSWebViewControllerDelegate
extension SavedCardsViewController: ThreeDSWebViewControllerDelegate {
    func threeDSWebViewController(controller: ThreeDSWebViewController, didCompleted3DSAuthentication secureCode: String, model: ThreeDSModel) {
        self.updatePaymentStatus(secureCode: secureCode, model: model)
    }
}
