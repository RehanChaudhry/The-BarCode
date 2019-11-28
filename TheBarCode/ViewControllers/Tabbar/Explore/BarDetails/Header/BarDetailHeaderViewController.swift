//
//  ExploreDetailHeaderViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import CoreStore
import FirebaseAnalytics
import CoreLocation
import AVKit
import FSPagerView

class BarDetailHeaderViewController: UIViewController {

    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var videoContainerView: UIView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var mapIconImageView: UIImageView!
    
    @IBOutlet var distanceButton: UIButton!
    
    @IBOutlet var favouriteButton: UIButton!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var statusButton: UIButton!
    
    @IBOutlet var playerLoaderView: ShadowView!
    @IBOutlet var playerActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var unlimitedRedemptionView: ShadowView!
    
    var bar: Bar!
    
    var avplayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let nib = UINib(nibName: "ExploreDetailHeaderCollectionViewCell", bundle: nil)
        self.pagerView.register(nib, forCellWithReuseIdentifier: "ExploreDetailHeaderCollectionViewCell")
        
        
        self.pagerView.backgroundColor = UIColor.clear
        self.pagerView.backgroundView = nil
        self.pagerView.isInfinite = true
        self.pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        
        self.mapIconImageView.image = self.mapIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.mapIconImageView.tintColor = UIColor.appBlueColor()
        
        self.setUpHeader()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.playerLayer?.frame = self.videoContainerView.bounds
    }
    
    deinit {
        
        if let observer = self.playerObserver {
            //removing time observer
            self.avplayer?.removeTimeObserver(observer)
            self.playerObserver = nil
        }
        
        self.avplayer?.pause()
        self.avplayer = nil
        
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    //MARK: My Methods
    
    func reloadData(bar: Bar) {
        self.bar = bar
        self.setUpHeader()
        self.pagerView.reloadData()
    }
    
    func setUpHeader() {
        self.titleLabel.text = self.bar.title.value
        self.mapIconImageView.isHidden = false
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: self.bar.distance.value), for: .normal)
        let color =  self.bar.isUserFavourite.value == true ? UIColor.appBlueColor() : UIColor.appLightGrayColor()
        self.favouriteButton.tintColor = color
        
        UIView.performWithoutAnimation {
            if self.bar.currentlyBarIsOpened {
                self.statusButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
                self.statusButton.backgroundColor = UIColor.appStatusButtonOpenColor().withAlphaComponent(0.6)
                self.statusButton.setTitle("Open", for: .normal)
            } else {
                self.statusButton.setTitleColor(UIColor.appRedColor(), for: .normal)
                self.statusButton.setTitle("Closed", for: .normal)
                self.statusButton.backgroundColor = UIColor.appStatusButtonColor().withAlphaComponent(0.6)
            }
            
            self.statusButton.layoutIfNeeded()
        }
        
        self.unlimitedRedemptionView.isHidden = !self.bar.currentlyUnlimitedRedemptionAllowed
        
        self.pageControl.numberOfPages = self.bar.images.count
        
        self.scrollToCurrentImage()
        self.pagerView.automaticSlidingInterval = self.bar.images.count > 1 ? 2.0 : 0.0
        
        if let videoUrlString = self.bar.videoUrlString.value {
            
            self.pagerView.isHidden = true
            self.pageControl.isHidden = true
            self.videoContainerView.isHidden = false
            
            if self.avplayer != nil {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.avplayer?.currentItem)
            }
            
            if let observer = self.playerObserver {
                //removing time observer
                self.avplayer?.removeTimeObserver(observer)
                self.playerObserver = nil
            }
            
            self.avplayer?.pause()
            self.avplayer = nil
            
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
            
            let videoUrl = URL(string: videoUrlString)!
            self.avplayer = AVPlayer(url: videoUrl)
            self.avplayer?.actionAtItemEnd = .none
            self.playerLayer = AVPlayerLayer(player: self.avplayer)
            self.playerLayer?.frame = self.videoContainerView.bounds
            self.playerLayer?.videoGravity = .resizeAspectFill
            self.videoContainerView.layer.addSublayer(self.playerLayer!)
            self.avplayer?.play()
            
            self.playerLoaderView.isHidden = false
            
            self.addPreriodicTimeObsever()
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.avplayer?.currentItem)
            
        } else {
            self.pagerView.isHidden = false
            self.pageControl.isHidden = self.pageControl.numberOfPages <= 1
            self.videoContainerView.isHidden = true
        }
    }
    
    func addPreriodicTimeObsever(){
        
        let intervel : CMTime = CMTimeMake(1, 10)
        self.playerObserver = avplayer?.addPeriodicTimeObserver(forInterval: intervel, queue: DispatchQueue.main) { [weak self] time in
            
            guard let `self` = self else { return }
            
            let playbackLikelyToKeepUp = self.avplayer?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false {
                self.playerLoaderView.isHidden = false
            } else {
                self.playerLoaderView.isHidden = true
            }
        }
    }
    
    func showDirection(bar: Bar) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
    
    func scrollToCurrentImage() {
        
        let imagesCount = self.bar?.images.count ?? 0
        let currentIndex = self.bar?.currentImageIndex ?? 0
        
        if currentIndex < imagesCount {
            self.pageControl.currentPage = currentIndex
            self.pagerView.layoutIfNeeded()
            self.pagerView.scrollToItem(at: currentIndex, animated: false)
        } else {
            self.pageControl.currentPage = 0
            self.pagerView.layoutIfNeeded()
            self.pagerView.scrollToItem(at: 0, animated: false)
        }
    }
    
    //MARK: IBActions
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        Analytics.logEvent(markABarAsFavorite, parameters: nil)
        markFavourite()
    }
    
    @IBAction func directionButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.showDirection(bar: self.bar)
    }
    
}

//MARK: Webservices Methods
extension BarDetailHeaderViewController {
    func markFavourite() {
        debugPrint("isFav == \(self.bar.isUserFavourite.value)")
        let params:[String : Any] = ["establishment_id": self.bar.id.value,
                                     "is_favorite" : !(self.bar.isUserFavourite.value)]
        
        try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
            let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value))
            for bar in bars {
                bar.isUserFavourite.value = !bar.isUserFavourite.value
            }
        })
        
        self.setUpHeader()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiUpdateFavorite, method: .put) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error == \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror == \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let response = response as! [String : Any]
            let responseDict = response["response"] as! [String : Any]

            if let responseID = (responseDict["data"] as? Int) {
                debugPrint("responseID == \(responseID)")                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
            
            if self.bar.isUserFavourite.value {
                NotificationCenter.default.post(name: notificationNameBarFavouriteAdded, object: self.bar)
            } else {
                NotificationCenter.default.post(name: notificationNameBarFavouriteRemoved, object: self.bar)
            }
        }
    }
}

extension BarDetailHeaderViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
        self.bar?.currentImageIndex = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
        self.bar?.currentImageIndex = pagerView.currentIndex
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.bar.images.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "ExploreDetailHeaderCollectionViewCell", at: index) as! ExploreDetailHeaderCollectionViewCell
        cell.setUpCell(imageName: self.bar.images[index].url.value)
        return cell
    }
    
    
    
}

//MARK: Notification Methods
extension BarDetailHeaderViewController {
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
            debugPrint("Video playback restarted")
        }
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        if self.avplayer?.isPlaying ==  false {
            self.avplayer?.play()
        }
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
