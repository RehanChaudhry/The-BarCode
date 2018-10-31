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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

    //MARK: My IBActions
    
    @IBAction func updateButtonTapped(sender: UIButton) {
        self.updateUserProfile()
    }
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fiveADaySwitchValueChanged(sender: UISwitch) {
        if !sender.isOn {
            self.showAlertController(title: "Confirm", msg: "Are you sure you want to switch these notifications off. If you switch them off you will not be able to receive great offers or pass them onto friends and receive credits?")
        }
    }
    
    @IBAction func liveOfferSwitchValueChanged(sender: UISwitch) {
        if !sender.isOn {
            self.showAlertController(title: "Confirm", msg: "Are you sure you want to switch these notifications off. If you switch them off you will not be able to receive great offers or pass them onto friends and receive credits?")
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

            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
        
    }
}
