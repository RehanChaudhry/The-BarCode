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
import CoreLocation

class BarDetailAboutViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var bar : Bar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(cellType: ExploreAboutTableViewCell.self)
        self.tableView.register(cellType: SocialLinksCell.self)
        self.tableView.estimatedRowHeight = 400.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData(bar: Bar) {
        self.bar = bar
        self.tableView.reloadData()
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BarDetailAboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var hasFBLink = false
        if let fbLink = self.bar.facebookPageUrl.value, fbLink.count > 0 {
            hasFBLink = true
        }
        
        var hasTwitterLink = false
        if let twitterLink = self.bar.twitterProfileUrl.value, twitterLink.count > 0 {
            hasTwitterLink = true
        }
        
        var hasInstagramLink = false
        if let instagramLink = self.bar.instagramProfileUrl.value, instagramLink.count > 0 {
            hasInstagramLink = true
        }
        
        if hasFBLink || hasTwitterLink || hasInstagramLink {
            return 2
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ExploreAboutTableViewCell.self)
            cell.setUpCell(explore: self.bar)
            cell.delegate = self
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: SocialLinksCell.self)
            cell.delegate = self
            cell.setupCell(bar: self.bar)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: SocialLinksCellDelegate
extension BarDetailAboutViewController: SocialLinksCellDelegate {
    func socialLinksCell(cell: SocialLinksCell, facebookButtonTapped sender: UIButton) {
        guard let fbLink = self.bar.facebookPageUrl.value, fbLink.count > 0, let url = URL(string: fbLink) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (completed) in
            
        }
    }
    
    func socialLinksCell(cell: SocialLinksCell, twitterButtonTapped sender: UIButton) {
        guard let twitterLink = self.bar.twitterProfileUrl.value, twitterLink.count > 0, let url = URL(string: twitterLink) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (completed) in
            
        }
    }
    
    func socialLinksCell(cell: SocialLinksCell, instagramButtonTapped sender: UIButton) {
        guard let instagramLink = self.bar.instagramProfileUrl.value, instagramLink.count > 0, let url = URL(string: instagramLink) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (completed) in
            
        }
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
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, showButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        self.bar.timingExpanded = !self.bar.timingExpanded
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, websiteButtonTapped sender: UIButton) {
        let urlString = self.bar.website.value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, callButtonTapped sender: UIButton) {
        
        let phoneNumber: String = "tel://\(self.bar.contactNumber.value)"
        let urlString = phoneNumber.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            debugPrint("Phone number url nil")
        }
    }
    
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, directionsButtonTapped sender: UIButton) {
        
        let user = Utility.shared.getCurrentUser()!
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let source = CLLocationCoordinate2D(latitude: user.latitude.value, longitude: user.longitude.value)
            
            let urlString = String(format: "comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",source.latitude,source.longitude,bar.latitude.value,bar.longitude.value)
 
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
            mailComposerController.mailComposeDelegate = self
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

