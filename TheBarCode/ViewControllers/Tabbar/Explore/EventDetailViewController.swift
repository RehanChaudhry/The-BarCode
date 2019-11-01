//
//  EventDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 30/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class EventDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var bookmarkLoader: UIActivityIndicatorView!
    @IBOutlet var shareLoader: UIActivityIndicatorView!
    
    var event: Event!
    
    var images: [String] = []
    
    var eventDetailInfo: [EventDetailInfo] = []
    
    var loadingShareController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
        self.tableView.register(cellType: EventDetailExternalCTACell.self)
        self.tableView.register(cellType: EventDetailInfoCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.estimatedRowHeight = 250.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        self.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewHeight = ((273.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 44.0
        
        var headerFrame = self.headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = headerViewHeight
        self.headerView.frame = headerFrame
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //MARK: My Methods
    func reloadData() {
        self.title = self.event.name.value
        self.setupHeaderView()
        
        self.eventDetailInfo.removeAll()
        
        if self.event.shouldShowDate.value {
            let attributedValidity = self.getAttributedValidity()
            let eventDetailValidity = EventDetailInfo(title: "VALIDITY PERIOD", detail: attributedValidity, showCallToAction: false, callToActionTitle: "", iconName: "icon_timings")
            self.eventDetailInfo.append(eventDetailValidity)
        }
        
        let attributedLocation = self.getAttributedLocation()
        let eventDetailLocation = EventDetailInfo(title: "LOCATION", detail: attributedLocation, showCallToAction: true, callToActionTitle: "Get Driving Directions", iconName: "bar-location")
        self.eventDetailInfo.append(eventDetailLocation)
        
        let attributedDetail = self.getAttributedDetail()
        let eventDetailsInfo = EventDetailInfo(title: "DESCRIPTION", detail: attributedDetail, showCallToAction: false, callToActionTitle: "", iconName: "icon_info")
        self.eventDetailInfo.append(eventDetailsInfo)
        
        self.tableView.reloadData()
    }
    
    func getAttributedDetail() -> NSAttributedString {
        let whiteAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                               NSAttributedStringKey.foregroundColor : UIColor.white]
        return NSAttributedString(string: self.event.detail.value, attributes: whiteAttributes)
    }
    
    func getAttributedLocation() -> NSAttributedString {
        let whiteAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                               NSAttributedStringKey.foregroundColor : UIColor.white]
        return NSAttributedString(string: self.event.locationName.value, attributes: whiteAttributes)
    }
    
    func getAttributedValidity() -> NSAttributedString {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let validtyPlaceHodler = ""
        
        let fromDate = dateFormatter.string(from: self.event.startDateTime)
        let toDate = dateFormatter.string(from: self.event.endDateTime)
        let to = " to "
        let from = " from "
        
        let fromTime = timeFormatter.string(from: self.event.startDateTime)
        let toTime = timeFormatter.string(from: self.event.endDateTime)
        
        let blueAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let whiteAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                               NSAttributedStringKey.foregroundColor : UIColor.white]
        
        let attributedTo = NSAttributedString(string: to, attributes: whiteAttributes)
        let attributedFrom = NSAttributedString(string: from, attributes: whiteAttributes)
        
        let attributedPlaceholder = NSAttributedString(string: validtyPlaceHodler, attributes: whiteAttributes)
        let attributedFromDate = NSAttributedString(string: fromDate, attributes: blueAttributes)
        let attributedToDate = NSAttributedString(string: toDate, attributes: blueAttributes)
        
        let attributedFromTime = NSAttributedString(string: fromTime, attributes: blueAttributes)
        let attributedToTime = NSAttributedString(string: toTime, attributes: blueAttributes)
        
        let finalAttributedText = NSMutableAttributedString()
        finalAttributedText.append(attributedPlaceholder)
        finalAttributedText.append(attributedFromDate)
        finalAttributedText.append(attributedTo)
        finalAttributedText.append(attributedToDate)
        
        if self.event.shouldShowTime.value {
            finalAttributedText.append(attributedFrom)
            finalAttributedText.append(attributedFromTime)
            finalAttributedText.append(attributedTo)
            finalAttributedText.append(attributedToTime)
        }
        
        return finalAttributedText
    }
    
    func setupHeaderView() {
        
        self.images.removeAll()
        self.images.append(event.image.value)
        
        self.collectionView.reloadData()
        self.updateBookmarkButtonState()
        self.updateShareButtonState()
    }
    
    func updateBookmarkButtonState() {
        
        if self.event.isBookmarked.value {
            self.bookmarkButton.tintColor = UIColor.appBlueColor()
        } else {
            self.bookmarkButton.tintColor = UIColor.appGrayColor()
        }
        
        if self.event.savingBookmarkStatus {
            self.bookmarkLoader.startAnimating()
            self.bookmarkButton.isHidden = true
        } else {
            self.bookmarkLoader.stopAnimating()
            self.bookmarkButton.isHidden = false
        }
    }
    
    func updateShareButtonState() {
        if self.event.showSharingLoader {
            self.shareLoader.startAnimating()
            self.shareButton.isHidden = true
        } else {
            self.shareLoader.stopAnimating()
            self.shareButton.isHidden = false
        }
    }
    
    //MARK: My IBActions
    @IBAction func bookmarkButtonTapped(sender: UIButton) {
        self.updateBookmarkStatus(isBookmarked: !self.event.isBookmarked.value)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        self.loadingShareController = true
        
        self.event.showSharingLoader = true
        self.updateShareButtonState()
        
        Utility.shared.generateAndShareDynamicLink(event: event, controller: self, presentationCompletion: {
            self.event.showSharingLoader = false
            self.updateShareButtonState()
            self.loadingShareController = false
        }) {
            
        }
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.eventDetailInfo.count
        } else {
            return self.event.externalCTAs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EventDetailInfoCell.self)
            cell.setupCell(eventDetailInfo: self.eventDetailInfo[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EventDetailExternalCTACell.self)
            cell.setupCell(cta: self.event.externalCTAs[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//MARK: EventDetailInfoCellDelegate
extension EventDetailViewController: EventDetailInfoCellDelegate {
    func eventDetailInfoCell(cell: EventDetailInfoCell, directionButtonTapped sender: UIButton) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(self.event.lat.value)+\(self.event.lng.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
}

//MARK: EventDetailExternalCTACellDelegate
extension EventDetailViewController: EventDetailExternalCTACellDelegate {
    func eventDetailExternalCTACell(cell: EventDetailExternalCTACell, ctaButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let cta = self.event.externalCTAs.value[indexPath.row]
        var url = URL(string: cta.link.value)
        if url == nil {
            url = URL(string: cta.link.value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        }
        
        guard let externalUrl = url else {
            self.showAlertController(title: "", msg: "Invalid url entered")
            return
        }
        
        UIApplication.shared.open(externalUrl, options: [:]) { (finished) in
            
        }
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension EventDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.images[indexPath.item])
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension EventDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}

//MARK: Webservices Methods
extension EventDetailViewController {
    func updateBookmarkStatus(isBookmarked: Bool) {
        
        guard !self.event.savingBookmarkStatus else {
            debugPrint("Already saving bookmark status")
            return
        }
        
        self.event.savingBookmarkStatus = true
        self.updateBookmarkButtonState()
        
        
        let eventId: String = self.event.id.value
        
        let params: [String : Any] = ["event_id" : eventId,
                                      "is_favorite" : isBookmarked]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddRemoveBookmarkedEvents, method: .put) { (response, serverError, error) in
            
            defer {
                self.updateBookmarkButtonState()
            }
            
            self.event.savingBookmarkStatus = false
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while saving bookmark event status: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while saving bookmark event status: \(serverError!.errorMessages())")
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let edittedEvent = transaction.edit(self.event)
                edittedEvent?.isBookmarked.value = isBookmarked
            })
            
            if isBookmarked {
                NotificationCenter.default.post(name: notificationNameEventBookmarked, object: self.event)
            } else {
                NotificationCenter.default.post(name: notificationNameBookmarkedEventRemoved, object: self.event)
            }
        }
        
    }
}
