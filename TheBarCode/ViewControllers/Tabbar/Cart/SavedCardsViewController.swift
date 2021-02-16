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
import SquareInAppPaymentsSDK
import SquareBuyerVerificationSDK
import KVNProgress

class SavedCardsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomSafeAreaView: UIView!
    
    @IBOutlet var payButton: GradientButton!
    
    var closeBarButtonItem: UIBarButtonItem!
    
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
    
    var order: Order?
    
    var selectedVoucher: OrderDiscount?
    var selectedOffer: OrderDiscount?
    
    var totalBillPayable: Double = 0.0
    
    var statefulView: LoadingAndErrorView!
    
    var useCredit: Bool = false
    
    var cardType: String {
        get {
            if self.order?.menuTypeRaw == MenuType.squareup.rawValue {
                return "squareup"
            } else {
                return "worldpay"
            }
        }
    }
    
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
        
        self.closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(closeBarButtonTapped(sender:)))
        
        if self.order == nil {
            self.bottomViewBottom.constant = self.bottomView.frame.height
            self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
            self.bottomView.isHidden = true
            self.bottomSafeAreaView.isHidden = true
        } else {
            self.bottomViewBottom.constant = 0.0
            self.bottomView.isHidden = false
            self.bottomSafeAreaView.isHidden = false
        }
        
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
    
    //MARK: My Methods
    @objc func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
        
        guard let order = self.order else {
            return
        }
        
        if self.selectedOffer != nil {
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), order.barId))
                for bar in bars {
                    bar.canRedeemOffer.value = false
                }
            })
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
        }
    }
    
    func makeCardEntryViewController() -> SQIPCardEntryViewController {
        let theme = Utility.shared.makeSquareTheme()
        let cardEntryController = SQIPCardEntryViewController(theme: theme)
        return cardEntryController
    }
    
    func makeVerificationParameters(card: CreditCard,
                                    locationId: String,
                                    orderAmount: Double) -> SQIPVerificationParameters {
        
        let fullName = card.fullName
        var components = fullName.components(separatedBy: " ")
        
        var firstName = ""
        var lastName = ""
        
        if components.count > 0 {
            lastName = components.removeLast()
            firstName = components.joined(separator: " ")
        }
        
        let contact = SQIPContact()
        contact.givenName = firstName
        contact.familyName = lastName
        contact.addressLines = [card.address]
        contact.city = card.city
        contact.country = SQIPCountry.GB
        contact.postalCode = card.postCode

        return SQIPVerificationParameters(
            paymentSourceID: card.cardToken,
            buyerAction: SQIPBuyerAction.charge(SQIPMoney(amount: Int(orderAmount * 100.0), currency: .GBP)),
            locationID: locationId,
            contact: contact
        )
    }
    
    //MARK: My IBActions
    @IBAction func payButtonTapped(sender: UIButton) {
        if let card = self.selectedCard {
            if self.order?.menuTypeRaw == MenuType.squareup.rawValue {
                self.squareUpChargeCard(card: card)
            } else {
                self.generateTokenIfNeededAndCharge(card: card)
            }
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
            
            cell.setUpCell(card: card, isSelected: card.cardId == self.selectedCard?.cardId, canShowSelection: self.order != nil)
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
        
        var params: [String : Any] = ["card_type" : self.cardType]
        if let order = self.order {
            params["establishment_id"] = order.barId
        }
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCard, method: .get) { (response, serverError, error) in
            
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
    
    func generateTokenIfNeededAndCharge(card: CreditCard) {
        
        if card.cardToken.count > 0 {
            self.chargeCard(card: card, token: card.cardToken)
        } else {
            
            guard let order = self.order else {
                self.showAlertController(title: "", msg: "Order details not available")
                return
            }
            
            guard let cardDetails = card.detailsRaw else {
                self.showAlertController(title: "", msg: "Card details not available")
                return
            }
            
            guard let clientKey = order.establishmentWorldpayClientKey else {
                self.showAlertController(title: "", msg: "Client key not available")
                return
            }

            UIApplication.shared.beginIgnoringInteractionEvents()
            self.payButton.showLoader()
            
            let worldpay = Worldpay.sharedInstance()!
            worldpay.clientKey = clientKey
            
            let name = cardDetails.name
            let cardNumber = cardDetails.number
            let expiryMonth = cardDetails.expiryMonth
            let expiryYear = cardDetails.expiryYear
            let cvc = cardDetails.cvc
            
            worldpay.createTokenWithName(onCard: name,
                                         cardNumber: cardNumber,
                                         expirationMonth: expiryMonth,
                                         expirationYear: expiryYear,
                                         cvc: cvc,
                                         success: { (code, response) in
                                            
                                            UIApplication.shared.endIgnoringInteractionEvents()
                                            self.payButton.hideLoader()
                                            
                                            let token = response?["token"] as? String ?? ""
                                            self.chargeCard(card: card, token: token)
                                            
            }) { (response, errors) in
                
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.payButton.hideLoader()
                
                let errorReason = (errors as? [NSError])?.first?.localizedDescription ?? "Unable to create token"
                let msg = "We are unable to charge your card at this time.\n\(errorReason)"
                
                self.showAlertController(title: "Payment Failed", msg: msg)
            }
        }
    }
    
    func chargeCard(card: CreditCard, token: String, sqVerificationToken: String? = nil) {
        
        guard let order = self.order else {
            self.showAlertController(title: "", msg: "Order information is unavailable")
            return
        }
        
        let sessionId = UUID().uuidString
        
        var params: [String : Any] = ["order_id" : order.orderNo,
                                      "token" : token,
                                      "session_id" : sessionId,
                                      "card_uid" : card.cardId]
        
        if let verificationToken = sqVerificationToken {
            params["verification_token"] = verificationToken
        }
        
        if let split = order.splitPaymentInfo, split.type != .none {
            params["split_type"] = split.type.rawValue
            params["value"] = split.value
        }
        
        if let voucher = self.selectedVoucher {
            params["voucher_id"] = voucher.id
        }
        
        if let offer = self.selectedOffer {
            params["offer_id"] = offer.id
            params["offer_type"] = offer.typeRaw
            
            if self.useCredit {
                params["use_credit"] = self.useCredit
            }
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
        
        guard let order = self.order else {
            self.showAlertController(title: "", msg: "Order information is unavailable")
            return
        }
        
        var params: [String : Any] = ["session_id" : model.sessionId,
                                      "order_id" : order.orderNo,
                                      "payment_code" : model.paymentCode,
                                      "secure_code" : secureCode]
        
        if self.selectedOffer != nil, self.useCredit {
            params["use_credit"] = self.useCredit
        }
        
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
    
    func squareUpChargeCard(card: CreditCard) {
        
        guard let applicationId = order?.establishmentSquareUpAppId else {
            self.showAlertController(title: "", msg: "Squareup application id not available")
            return
        }
        
        SQIPInAppPaymentsSDK.squareApplicationID = applicationId
        
        guard let locationId = self.order?.squareUpLocationId, locationId.count > 0 else {
            self.showAlertController(title: "", msg: "Location id is required for square up")
            return
        }
        
        
        
        let sourceId = card.cardToken
        let params = self.makeVerificationParameters(card: card,
                                                     locationId: locationId,
                                                     orderAmount: self.totalBillPayable)

        self.payButton.showLoader()
        self.view.isUserInteractionEnabled = false
        SQIPBuyerVerificationSDK.shared.verify(with: params,
                                               theme: Utility.shared.makeSquareTheme(),
                                               viewController: self,
                                               success: { (detail) in
                                                
                                                self.view.isUserInteractionEnabled = true
                                                self.chargeCard(card: card,
                                                                token: sourceId,
                                                                sqVerificationToken: detail.verificationToken)
                                                
            
        }) { (error) in
            self.payButton.hideLoader()
            self.view.isUserInteractionEnabled = true
            KVNProgress.showError(withStatus: error.localizedDescription)
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
        
        if self.order?.menuTypeRaw == MenuType.squareup.rawValue {
            
            guard let applicationId = order?.establishmentSquareUpAppId else {
                self.showAlertController(title: "", msg: "Squareup application id not available")
                return
            }
            
            SQIPInAppPaymentsSDK.squareApplicationID = applicationId
            
            let vc = self.makeCardEntryViewController()
            vc.delegate = self

            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .fullScreen
            self.present(nc, animated: true, completion: nil)
        } else {
            let addCardNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "AddCardNavigation") as! UINavigationController)
            addCardNavigation.modalPresentationStyle = .fullScreen
            
            let addCardController = addCardNavigation.viewControllers.first as! AddCardViewController
            addCardController.delegate = self
            
            self.navigationController?.present(addCardNavigation, animated: true, completion: nil)
        }
    }
}

//MARK: SQIPCardEntryViewControllerDelegate
extension SavedCardsViewController: SQIPCardEntryViewControllerDelegate {
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didCompleteWith status: SQIPCardEntryCompletionStatus) {
        cardEntryViewController.dismiss(animated: true, completion: nil)
    }
    
    func cardEntryViewController(_ cardEntryViewController: SQIPCardEntryViewController, didObtain cardDetails: SQIPCardDetails, completionHandler: @escaping (Error?) -> Void) {
        
        guard let locationId = self.order?.squareUpLocationId, locationId.count > 0 else {
            self.showAlertController(title: "", msg: "Location id is required for square up")
            return
        }
        
        guard let barId = self.order?.barId else {
            let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey : "Establishment id is required"])
            completionHandler(error)
            return
        }
        
        let addCardNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "AddCardNavigation") as! UINavigationController)
        addCardNavigation.modalPresentationStyle = .fullScreen
        
        let addCardController = (addCardNavigation.viewControllers.first as! AddCardViewController)
        addCardController.delegate = self
        addCardController.sqVerificationParams = (cardDetails: cardDetails, barId: barId, locationId: locationId, completion: { (verificationError) in
            completionHandler(verificationError)
        })
        cardEntryViewController.present(addCardNavigation, animated: true, completion: nil)
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
