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
import PureLayout

class BarDetailAboutViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var headerView: UIView!
    
    var bar : Bar!
    
    enum BarDetailAboutSections: Int {
        case details = 0, timings = 1, delivery = 2, contact = 3, social = 4
        
        static func allSections() -> [BarDetailAboutSections] {
            return [.details, .timings, .delivery, .contact, .social]
        }
    }
    
    lazy var headerViewController: BarDetailHeaderViewController = {
        let headerViewController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailHeaderViewController") as! BarDetailHeaderViewController)
        headerViewController.bar = self.bar
        self.addChildViewController(headerViewController)
        headerViewController.willMove(toParentViewController: self)
        self.headerView.addSubview(headerViewController.view)
        headerViewController.view.autoPinEdgesToSuperviewEdges()
        
        let collectionViewHeight = ((162.0 / 288.0) * self.view.frame.width)
        let headerViewHeight = ceil(collectionViewHeight + 83.0)
        
        headerViewController.collectionViewHeight.constant = collectionViewHeight
        
        let headerFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: headerViewHeight)
        self.headerView.frame = headerFrame
        self.tableView.tableHeaderView = self.headerView
        
        return headerViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.register(cellType: BarAboutTableViewCell.self)
        self.tableView.register(cellType: BarTimingTableViewCell.self)
        self.tableView.register(cellType: BarDeliveryTableViewCell.self)
        self.tableView.register(cellType: BarContactTableViewCell.self)
        self.tableView.register(cellType: SocialLinksCell.self)
        
        self.tableView.estimatedRowHeight = 400.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let _ = self.headerViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData(bar: Bar) {
        self.bar = bar
        self.headerViewController.reloadData(bar: self.bar)
        self.tableView.reloadData()
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BarDetailAboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return BarDetailAboutSections.allSections().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = BarDetailAboutSections(rawValue: section)!
        if section == .details || section == .timings || section == .contact {
            return 1
        } else if section == .delivery {
            return self.bar.isDeliveryAvailable.value ? 1 : 0
        } else if section == .social {
            let hasFBLink = (self.bar.facebookPageUrl.value?.count ?? 0) > 0
            let hasTwitterLink = (self.bar.twitterProfileUrl.value?.count ?? 0) > 0
            let hasInstagramLink = (self.bar.instagramProfileUrl.value?.count ?? 0) > 0
            
            if hasFBLink || hasTwitterLink || hasInstagramLink {
                return 1
            } else {
                return 0
            }
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = BarDetailAboutSections(rawValue: indexPath.section)!
        if section == .details {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: BarAboutTableViewCell.self)
            cell.setupCell(bar: self.bar)
            cell.delegate = self
            return cell
        } else if section == .timings {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: BarTimingTableViewCell.self)
            cell.setupCell(bar: self.bar)
            cell.delegate = self
            return cell
        } else if section == .delivery {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: BarDeliveryTableViewCell.self)
            cell.setupCell(bar: self.bar)
            cell.delegate = self
            return cell
        } else if section == .contact {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: BarContactTableViewCell.self)
            cell.setupCell(bar: self.bar)
            cell.delegate = self
            return cell
        } else if section == .social {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: SocialLinksCell.self)
            cell.delegate = self
            cell.setupCell(bar: self.bar)
            return cell
        }
        
        return UITableViewCell()
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

//MARK: BarAboutTableViewCellDelegate
extension BarDetailAboutViewController: BarAboutTableViewCellDelegate {
    func barAboutTableViewCell(cell: BarAboutTableViewCell, reserveTableButtonTapped sender: UIButton) {
        
        var url = URL(string: self.bar.reservationUrl.value)
        if url == nil {
            url = URL(string: self.bar.reservationUrl.value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        }
        
        guard let reservation = url else {
            self.showAlertController(title: "", msg: "Invalid URL")
            return
        }
        
        UIApplication.shared.open(reservation, options: [:]) { (finished) in
            
        }
    }
}

//MARK: SJSegmentedViewControllerViewSource
extension BarDetailAboutViewController: SJSegmentedViewControllerViewSource {
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return self.tableView
    }
}

//MARK: BarTimingTableViewCellDelegate
extension BarDetailAboutViewController: BarTimingTableViewCellDelegate {
    func barTimingTableViewCell(cell: BarTimingTableViewCell, showTimingButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        self.bar.timingExpanded = !self.bar.timingExpanded
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

//MARK: BarDeliveryTableViewCellDelegate
extension BarDetailAboutViewController: BarDeliveryTableViewCellDelegate {
    func barDeliveryTableViewCell(cell: BarDeliveryTableViewCell, showTimingButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        self.bar.deliveryExpanded = !self.bar.deliveryExpanded
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

//MARK: BarContactTableViewCellDelegate
extension BarDetailAboutViewController: BarContactTableViewCellDelegate {
    func barContactTableViewCell(cell: BarContactTableViewCell, websiteButtonTapped sender: UIButton) {
        let urlString = self.bar.website.value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: urlString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func barContactTableViewCell(cell: BarContactTableViewCell, callButtonTapped sender: UIButton) {
        let phoneNumber: String = "tel://\(self.bar.contactNumber.value)"
        let urlString = phoneNumber.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            debugPrint("Phone number url nil")
        }
    }
    
    func barContactTableViewCell(cell: BarContactTableViewCell, emailButtonTapped sender: UIButton) {
        let mailComposerController = MFMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            mailComposerController.delegate = self
            mailComposerController.mailComposeDelegate = self
            mailComposerController.setToRecipients([self.bar.contactEmail.value])
            present(mailComposerController, animated: true, completion: nil)
        }
    }
    
    func barContactTableViewCell(cell: BarContactTableViewCell, directionButtonTapped sender: UIButton) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
}

//MARK: MFMailComposeViewControllerDelegate
extension BarDetailAboutViewController: MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

