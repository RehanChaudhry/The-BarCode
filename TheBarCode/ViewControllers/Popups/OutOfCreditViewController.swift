//
//  OutOfCreditViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class OutOfCreditViewController: UIViewController {
    
    var presentedVC : UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: IBActions
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reloadButtonTapped(_ sender: Any) {
        presentedVC = self.presentingViewController
        self.dismiss(animated: true) {
            let reloadNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReloadNavigation") as! UINavigationController)
            reloadNavigation.modalPresentationStyle = .overCurrentContext
            self.presentedVC.present(reloadNavigation, animated: true, completion: nil)
        }     
    }
    
    @IBAction func inviteButtonTapped(_ sender: Any) {
        presentedVC = self.presentingViewController
        self.dismiss(animated: true) {
            
            let inviteNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "InviteNavigation") as! UINavigationController)
            let inviteController =  inviteNavigation.viewControllers.first as! InviteViewController
            inviteController.shouldShowCancelBarButton = true
            inviteNavigation.modalPresentationStyle = .overCurrentContext
            self.presentedVC.present(inviteNavigation, animated: true, completion: nil)
            
        }
        
        
    }
    
}
