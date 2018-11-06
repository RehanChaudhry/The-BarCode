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
    
    var avPlayer: AVPlayer!
    
    var viewAlreadyAppeared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = Bundle.main.url(forResource: "splash", withExtension: "mp4")!
        self.avPlayer = AVPlayer(url: url)
        
        NotificationCenter.default.addObserver(forName: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (notif) in
            self.avPlayer.seek(to: kCMTimeZero)
            self.avPlayer.play()
        }
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: self.avPlayer)
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspectFill
        self.imageView.layer.addSublayer(layer)

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.avPlayer.play()
        
        if !self.viewAlreadyAppeared {
            self.viewAlreadyAppeared = true
            self.moveToNextControllerIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.avPlayer.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pagerView.itemSize = self.pagerView.frame.size
    }

    //MARK: My Methods
    func setupInitialData(){

        let option1 = IntroOption(title: "5 A Day", detail: "Looking for the ultimate boozer for your night out? Use our map and browser to check out a list of the top independent pubs and bars in your neck of the woods.", image: "login_intro_1")
        let option2 = IntroOption(title: "Live Offers", detail: "Looking for the ultimate boozer for your night out? Use our map and browser to check out a list of the top independent pubs and bars in your neck of the woods.", image: "login_intro_1")
        let option3 = IntroOption(title: "Bar finder", detail: "Looking for the ultimate boozer for your night out? Use our map and browser to check out a list of the top independent pubs and bars in your neck of the woods.", image: "login_intro_1")
        let option4 = IntroOption(title: "Invite Friends Get Credits", detail: "Looking for the ultimate boozer for your night out? Use our map and browser to check out a list of the top independent pubs and bars in your neck of the woods.", image: "login_intro_1")
        let option5 = IntroOption(title: "Reload & Get Discounts", detail: "Looking for the ultimate boozer for your night out? Use our map and browser to check out a list of the top independent pubs and bars in your neck of the woods.", image: "login_intro_1")
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
            } else {
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
                self.navigationController?.present(tabbarController!, animated: true, completion: {
                    let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                    self.navigationController?.popToViewController(loginOptions, animated: false)
                })
            }
        default:
            Utility.shared.removeUser()
            self.showAlertController(title: "", msg: "Please sign in again")
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "LoginOptionsToSignUpSegue", sender: nil)
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "LoginOptionsToLoginSegue", sender: nil)
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
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
    
}
