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

class BarDetailHeaderViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
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
    
    var bar: Bar!
    
    var avplayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var playerObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.mapIconImageView.image = self.mapIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.mapIconImageView.tintColor = UIColor.appBlueColor()
        
        self.setUpHeader()
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
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
        self.collectionView.reloadData()
    }
    
    func setUpHeader() {
        self.titleLabel.text = self.bar.title.value
        self.mapIconImageView.isHidden = false
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: self.bar.distance.value), for: .normal)
        let color =  self.bar.isUserFavourite.value == true ? UIColor.appBlueColor() : UIColor.appLightGrayColor()
        self.favouriteButton.tintColor = color
        
        UIView.performWithoutAnimation {
            if let timings = self.bar.timings.value {
                if timings.dayStatus == .opened {
                    if timings.isOpen.value {
                        self.statusButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
                        self.statusButton.backgroundColor = UIColor.appStatusButtonOpenColor().withAlphaComponent(0.6)
                        self.statusButton.setTitle("Open", for: .normal)
                    } else {
                        self.statusButton.setTitleColor(UIColor.appRedColor(), for: .normal)
                        self.statusButton.setTitle("Closed", for: .normal)
                        self.statusButton.backgroundColor = UIColor.appStatusButtonColor().withAlphaComponent(0.6)
                    }
                } else {
                    self.statusButton.setTitleColor(UIColor.appRedColor(), for: .normal)
                    self.statusButton.setTitle("Closed", for: .normal)
                    self.statusButton.backgroundColor = UIColor.appStatusButtonColor().withAlphaComponent(0.6)
                }
                
            } else {
                self.statusButton.setTitleColor(UIColor.appRedColor(), for: .normal)
                self.statusButton.setTitle("Closed", for: .normal)
                self.statusButton.backgroundColor = UIColor.appStatusButtonColor().withAlphaComponent(0.6)
            }
            
            self.statusButton.layoutIfNeeded()
        }
        
        self.pageControl.numberOfPages = self.bar.images.count
        let pageNumber = round(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        self.pageControl.currentPage = Int(pageNumber)
        
        if let videoUrlString = self.bar.videoUrlString.value {
            
            self.collectionView.isHidden = true
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
            
            self.addPreriodicTimeObsever()
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.avplayer?.currentItem)
            
        } else {
            self.collectionView.isHidden = false
            self.pageControl.isHidden = false
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
    
    func showDirection(bar: Bar){
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
        
        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
            if let bars = transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value)) {
                for bar in bars {
                    bar.isUserFavourite.value = !bar.isUserFavourite.value
                }
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

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension BarDetailHeaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.pageControl.currentPage = Int(pageNumber)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bar.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.bar.images[indexPath.item].url.value)
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension BarDetailHeaderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
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
