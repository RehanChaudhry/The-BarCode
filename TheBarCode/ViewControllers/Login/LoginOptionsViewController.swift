//
//  LoginOptionsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import AVFoundation
import FSPagerView
import CoreLocation

class LoginOptionsViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var introOptions: [IntroOption] = []
    
    var avPlayer: AVPlayer?
    
    var viewAlreadyAppeared: Bool = false
    
    var shouldShowPreferences: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        self.navigationItem.hidesBackButton = true
        
        self.pagerView.register(LoginIntroCollectionViewCell.nib, forCellWithReuseIdentifier: LoginIntroCollectionViewCell.reuseIdentifier)
        self.pagerView.backgroundColor = .clear
        self.pagerView.itemSize = self.pagerView.frame.size
        self.pagerView.isInfinite = true
        self.pagerView.automaticSlidingInterval = 4.0
        
        self.pageControl.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        self.setupInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
        self.setupPlayerLayer()
        
        if !self.viewAlreadyAppeared {
            self.viewAlreadyAppeared = true
            self.moveToNextControllerIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.avPlayer?.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.clearPlayerLayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pagerView.itemSize = self.pagerView.frame.size
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "LoginOptionsToLoginViaSegue", let forSignup = sender as? Bool {
            let controller = segue.destination as! LoginViaViewController
            controller.forSignUp = forSignup
        }
    }
    
    
    //MARK: My Methods
    
    func setupPlayerLayer() {
        let url = Bundle.main.url(forResource: "splash", withExtension: "mp4")!
        self.avPlayer = AVPlayer(url: url)
        
        let playerItem = self.avPlayer!.currentItem!
        NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { [unowned self] (notif) in
            self.avPlayer?.seek(to: kCMTimeZero)
            self.avPlayer?.play()
        }
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspectFill
        self.imageView.layer.addSublayer(layer)
    }
    
    //DONOT CALL WITHOUT BEIGN SETUP
    func clearPlayerLayer() {
        self.avPlayer?.pause()
        let playerItem = self.avPlayer!.currentItem!
        NotificationCenter.default.removeObserver(playerItem, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        for subLayer in self.imageView.layer.sublayers ?? [] {
            subLayer.removeFromSuperlayer()
        }
        
        self.avPlayer = nil
    }
    
    func setupInitialData(){
        
        let option1 = IntroOption(title: "Discover", detail: "Discover awesome Independent venues", type: .barFinder)
    
        let option2 = IntroOption(title: "Edits", detail: "Get a daily bundle of offers specific to you", type: .fiveADay)
        
        let option3 = IntroOption(title: "Live Alerts", detail: "Receive real-time offers from your nearest and dearest", type: .liveOffers)

        let option4 = IntroOption(title: "Reload and get Discounts", detail: "Reload all offers for just \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.reload)", type: .reload)
        
        let option5 = IntroOption(title: "Get Credits", detail: "Earn credits by inviting friends and sharing offers", type: .credits)

        introOptions = [option1, option2, option3, option4, option5]
        
        self.pageControl.numberOfPages = self.introOptions.count
        self.pageControl.currentPage = 0
        self.pagerView.reloadData()
    }
    
    func moveToNextControllerIfNeeded() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("No user found")
            return
        }
        
        switch user.status {
        case .active:
            if !user.isCategorySelected.value {
                self.performSegue(withIdentifier: "SignOptionsToCategoriesSegue", sender: nil)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.performSegue(withIdentifier: "SignOptionsToPermissionSegue", sender: nil)
            } else if self.shouldShowPreferences {
                self.moveToCategoryUpdate()
            } else {
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
                tabbarController?.modalPresentationStyle = .fullScreen
                self.navigationController?.present(tabbarController!, animated: false, completion: {
                    let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                    self.navigationController?.popToViewController(loginOptions, animated: false)
                })
            }
        default:
            Utility.shared.logout()
            self.showAlertController(title: "", msg: "Please sign in again")
        }
    }
    
    func moveToCategoryUpdate() {
        let categoryFilterViewController = self.storyboard!.instantiateViewController(withIdentifier: "CategoryFilterViewController") as! CategoryFilterViewController
        categoryFilterViewController.comingForUpdatingPreference = true
        categoryFilterViewController.comingFromSplash = true
        self.navigationController?.pushViewController(categoryFilterViewController, animated: false)
    }
    
    //MARK: My IBActions
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "LoginOptionsToLoginViaSegue", sender: true)
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "LoginOptionsToLoginViaSegue", sender: false)
    }

}

//MARK: FSPagerViewDataSource, FSPagerViewDelegate

extension LoginOptionsViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return false
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.introOptions.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let identifier = LoginIntroCollectionViewCell.reuseIdentifier
        let cell = self.pagerView.dequeueReusableCell(withReuseIdentifier: identifier, at: index) as! LoginIntroCollectionViewCell
        cell.setUpCell(option: self.introOptions[index])
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        let loginIntroCell = cell as! LoginIntroCollectionViewCell
        
        debugPrint("login introl image dimension: \(String(describing: loginIntroCell.coverImage.frame.size))")
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
    
}
