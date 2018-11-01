//
//  ExploreAboutViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import SJSegmentedScrollView
import MessageUI

class BarDetailAboutViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var bar : Bar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(cellType: ExploreAboutTableViewCell.self)
        self.tableView.estimatedRowHeight = 400.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BarDetailAboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ExploreAboutTableViewCell.self)
        cell.setUpCell(explore: self.bar)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: SJSegmentedViewControllerViewSource
extension BarDetailAboutViewController: SJSegmentedViewControllerViewSource {
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return self.tableView
    }
}

//MARK: ExploreAboutTableViewCellDelegate
extension BarDetailAboutViewController: ExploreAboutTableViewCellDelegate {
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, websiteButtonTapped sender: UIButton) {
        let urlString = self.bar.website.value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, callButtonTapped sender: UIButton) {
        let phoneNumber: String = "tel://\(self.bar.contactNumber.value)"
        let url = URL(string: phoneNumber)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, directionsButtonTapped sender: UIButton) {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?saddr=%f,%f&daddr=,&directionsmode=driving", self.bar.latitude.value, self.bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, emailButtonTapped sender: UIButton) {
        let mailComposerController = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailComposerController.delegate = self
            mailComposerController.setToRecipients([self.bar.contactEmail.value])
            present(mailComposerController, animated: true, completion: nil)
        }
    }
}

//MARK: MFMailComposeViewControllerDelegate
extension BarDetailAboutViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

