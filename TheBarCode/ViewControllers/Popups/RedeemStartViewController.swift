//
//  RedeemStartViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class RedeemStartViewController: UIViewController {

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
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barTenderReadyButtonTapped(_ sender: Any) {
        presentedVC = self.presentingViewController
        
        self.dismiss(animated: true) {
            let redeemActiveDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemActiveDealViewController") as! RedeemActiveDealViewController)
            redeemActiveDealViewController.modalPresentationStyle = .overCurrentContext
            self.presentedVC.present(redeemActiveDealViewController, animated: true, completion: nil)

        }
    }
    
    @IBAction func takeMeBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
