//
//  ExploreDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import PureLayout

class BarDetailViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var standardRedeemButton: GradientButton!

    var headerController: BarDetailHeaderViewController!
    
    var aboutController: BarDetailAboutViewController!
    var dealsController: BarDealsViewController!
    var offersController: BarLiveOffersViewController!
    
    var segmentedController: SJSegmentedViewController!
    
    var selectedBar: Bar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpSegmentedController()
        self.addBackButton()
        
        if selectedBar.canRedeemOffer.value {
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //MARK: My Methods
    
    func setUpSegmentedController() {
        
        let collectionViewHeight = ((178.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        self.headerController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailHeaderViewController") as! BarDetailHeaderViewController)
        headerController.bar = self.selectedBar
        let _ = self.headerController.view
        self.headerController.collectionViewHeight.constant = collectionViewHeight
        
        self.aboutController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailAboutViewController") as! BarDetailAboutViewController)
        self.aboutController.bar = self.selectedBar
        self.aboutController.title = "About"
        self.aboutController.view.backgroundColor = self.containerView.backgroundColor
        
        self.dealsController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDealsViewController") as! BarDealsViewController)
        self.dealsController.bar = self.selectedBar
        self.dealsController.title = "Deals"
        self.dealsController.delegate = self
        self.dealsController.view.backgroundColor = self.containerView.backgroundColor
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "BarLiveOffersViewController") as! BarLiveOffersViewController)
        self.offersController.bar = self.selectedBar
        self.offersController.title = "Live Offers"
        self.offersController.delegate = self
        self.offersController.view.backgroundColor = self.containerView.backgroundColor
        
        self.aboutController.automaticallyAdjustsScrollViewInsets = false
        self.dealsController.automaticallyAdjustsScrollViewInsets = false
        self.offersController.automaticallyAdjustsScrollViewInsets = false
        
        self.segmentedController = SJSegmentedViewController(headerViewController: self.headerController, segmentControllers: [self.aboutController, self.dealsController, self.offersController])
        self.segmentedController.delegate = self
        self.segmentedController.headerViewHeight = headerViewHeight
        self.segmentedController.segmentViewHeight = 44.0
        self.segmentedController.selectedSegmentViewHeight = 1.0
        self.segmentedController.selectedSegmentViewColor = UIColor.appBlueColor()
        self.segmentedController.segmentTitleColor = UIColor.white
        self.segmentedController.segmentBackgroundColor = self.headerController.view.backgroundColor!
        self.segmentedController.segmentTitleFont = UIFont.appRegularFontOf(size: 16.0)

        self.addChildViewController(self.segmentedController)
        self.segmentedController.willMove(toParentViewController: self)
        self.containerView.addSubview(self.segmentedController.view)
        
        self.segmentedController.view.autoPinEdgesToSuperviewEdges()
        
    }

    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getOffButtonTapped(_ sender: Any) {
    
        if self.selectedBar.canRedeemOffer.value {
            redeemStandardDeal()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExploreDetailToOfferDetailSegue" {
            let vc = segue.destination as! OfferDetailViewController
            vc.deal = sender as? Deal
        }
    }
    
    
}

//MARK: SJSegmentedViewControllerDelegate
extension BarDetailViewController: SJSegmentedViewControllerDelegate {
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        
        for segment in self.segmentedController.segments {
            segment.titleColor(UIColor.white)
        }
        
        let segmentTab = self.segmentedController.segments[index]
        segmentTab.titleColor(UIColor.appBlueColor())
    }
}

//MARK: ExploreDetailDealsViewControllerDelegate
extension BarDetailViewController: BarDealsViewControllerDelegate {
    func barDealsController(controller: BarDealsViewController, didSelectRowAt deal: Deal) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: deal)
    }
}

//MARK: ExploreDetailLiveOffersViewControllerDelegate
extension BarDetailViewController: BarLiveOffersViewControllerDelegate {
    func barLiveOffersController(controller: BarLiveOffersViewController, didSelectRowAt offer: LiveOffer) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: offer)
    }
}

//MARK: WebService Method
extension BarDetailViewController {
    func redeemStandardDeal() {
        
        let params: [String: Any] = ["establishment_id": self.selectedBar.id.value,
                                     "type": OfferType.standard.serverParamValue()]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error?.localizedDescription ?? genericErrorMessage)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError?.errorMessages() ?? genericErrorMessage)
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                        let editedObject = transaction.edit(self.selectedBar)
                        editedObject!.canRedeemOffer.value = false
                    })
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    self.showAlertController(title: "", msg: genericError.localizedDescription)
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
    }
}
