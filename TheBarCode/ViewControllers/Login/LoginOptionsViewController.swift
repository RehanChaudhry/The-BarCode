//
//  LoginOptionsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class LoginOptionsViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var introOptions: [IntroOption] = [IntroOption(), IntroOption(), IntroOption()]
    
    var cellSize = CGSize(width: 375.0, height: 400.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        
        self.collectionView.register(cellType: LoginIntroCollectionViewCell.self)
        
        self.pageControl.numberOfPages = self.introOptions.count
        self.pageControl.currentPage = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.cellSize = self.collectionView.frame.size
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: My IBActions
    
    @IBAction func signUpButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "LoginOptionsToSignUpSegue", sender: nil)
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "LoginOptionsToLoginSegue", sender: nil)
    }

}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension LoginOptionsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let page = (scrollView.contentOffset.x + (0.5 * width)) / width
        
        pageControl.currentPage = Int(page)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return introOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: LoginIntroCollectionViewCell.self)
        cell.setUpCell()
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout

extension LoginOptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
