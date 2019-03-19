//
//  NotificationSettingsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class NotificationSettingsViewController: UIViewController {

    @IBOutlet var fiveADaySwitch: UISwitch!
    @IBOutlet var liveOfferSwitch: UISwitch!
    
    @IBOutlet var updateButton: GradientButton!
    
    enum SelectedSwitchType: String {
        case fiveADay = "fiveADay",
        liveOfferSwitch = "liveOfferSwitch"
    }
    
    var selectedSwitchType: SelectedSwitchType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Notification Settings"
        
        self.definesPresentationContext = true
        self.setUpNotificationSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    func setUpNotificationSettings() {
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User not found")
            return
        }
        
        self.fiveADaySwitch.isOn = user.fiveADayNotificationEnabled.value
        self.liveOfferSwitch.isOn = user.liveOfferNotificationEnabled.value
    }

    
    func showCustomAlert(title: String, message: String){
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = message
        cannotRedeemViewController.titleText = title
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        cannotRedeemViewController.delegate = self
        cannotRedeemViewController.headerImageName = "login_intro_five_a_day_5"
        self.present(cannotRedeemViewController, animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    
    @IBAction func updateButtonTapped(sender: UIButton) {
        self.updateUserProfile()
    }
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fiveADaySwitchValueChanged(sender: UISwitch) {
        
        self.selectedSwitchType = .fiveADay
        
        if !sender.isOn {
            sender.isOn = !sender.isOn
            self.showCustomAlert(title: "Confirm", message: "Are you sure you want to turn off your notifications? Think of all the great deals you won't hear about!")
        }
    }
    
    @IBAction func liveOfferSwitchValueChanged(sender: UISwitch) {
        
        self.selectedSwitchType = .liveOfferSwitch
        
        if !sender.isOn {
            sender.isOn = !sender.isOn
            self.showCustomAlert(title: "Confirm", message: "Are you sure you want to turn off your notifications? Think of all the great deals you won't hear about!")
        }
    }

}

//MARK: Webservices Methods
extension NotificationSettingsViewController {
    func updateUserProfile() {
        
        let params = ["is_5_day_notify" : self.fiveADaySwitch.isOn,
                      "is_live_offer_notify" : self.liveOfferSwitch.isOn]
        
        self.updateButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let apiPath = apiPathUserProfileUpdate + "/\(Utility.shared.getCurrentUser()!.userId.value)"
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPath, method: .put) { (response, serverError, error) in
            self.updateButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let _ = (responseDict?["data"] as? [String : Any]) {
                
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let editedUser = transaction.edit(Utility.shared.getCurrentUser())
                    editedUser?.fiveADayNotificationEnabled.value = self.fiveADaySwitch.isOn
                    editedUser?.liveOfferNotificationEnabled.value = self.liveOfferSwitch.isOn
                })
                
                self.dismiss(animated: true, completion: nil)

            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
        
    }
}


extension NotificationSettingsViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        if self.selectedSwitchType == .fiveADay {
            self.fiveADaySwitch.isOn = !self.fiveADaySwitch.isOn
        } else if self.selectedSwitchType == .liveOfferSwitch {
            self.liveOfferSwitch.isOn = !self.liveOfferSwitch.isOn
        }
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}
