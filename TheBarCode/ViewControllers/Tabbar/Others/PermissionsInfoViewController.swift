//
//  PermissionsInfoViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class PermissionsInfoViewController: UIViewController {

    @IBOutlet var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = false
        self.overlayView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showOverlayView() {
        self.overlayView.alpha = 0.0
        self.overlayView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 1.0
        }) { (completed: Bool) in
            
        }
    }
    
    func hideOverlayView(completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 0.0
        }) { (completed: Bool) in
            self.overlayView.isHidden = true
            completion()
        }
    }
    
    func presentTabbarController() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
        self.navigationController?.present(tabbarController!, animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    
    @IBAction func askMeButtonTapped(sender: UIButton) {
        self.showOverlayView()
    }
    
    @IBAction func notNowButtonTapped(sender: UIButton) {
        self.hideOverlayView {
            self.presentTabbarController()
        }
    }
    
    @IBAction func alwaysAllowButtonTapped(sender: UIButton) {
        self.hideOverlayView {
            
        }
    }
    
    @IBAction func whileUsingAppButtonTapped(sender: UIButton) {
        self.hideOverlayView {
            
        }
    }
}
