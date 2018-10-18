//
//  ReloadViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

@objc protocol ReloadViewControllerDelegate: class {
    @objc optional func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int)
}

class ReloadViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    
    @IBOutlet var creditsLabel: UILabel!
    
    var isRedeemingDeal: Bool = false
    
    weak var delegate: ReloadViewControllerDelegate?
    
    var selectedIndex: Int = NSNotFound
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let coverHeight = ((249.0 / 375.0) * self.view.frame.width)
        var headerFrame = headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = coverHeight + 100.0
        headerView.frame = headerFrame
        
        self.view.backgroundColor = UIColor.appBgGrayColor()
        self.headerView.backgroundColor = UIColor.clear
        self.creditsLabel.layer.borderColor = UIColor.appGradientGrayStart().cgColor
        
        self.tableView.estimatedRowHeight = 500.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My IBActions
    @IBAction func reloadButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.reloadController?(controller: self, cancelButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }

}

extension ReloadViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
    }
}
