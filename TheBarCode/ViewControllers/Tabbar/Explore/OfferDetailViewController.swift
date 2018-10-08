//
//  OfferDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OfferDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    var images: [String] = ["cover_offer_detail"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
        self.tableView.register(cellType: OfferDetailTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.estimatedRowHeight = 250.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewHeight = ((273.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        var headerFrame = self.headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = headerViewHeight
        self.headerView.frame = headerFrame
    }
    
    //MARK: IBAction
    @IBAction func redeemDealButtonTapped(_ sender: Any) {
        let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
        outOfCreditViewController.modalPresentationStyle = .overCurrentContext
        self.present(outOfCreditViewController, animated: true, completion: nil)
    }
    

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension OfferDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: OfferDetailTableViewCell.self)
        return cell
    }
}


//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension OfferDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
extension OfferDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}
