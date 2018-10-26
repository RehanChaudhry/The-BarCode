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

class BarDetailHeaderViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var mapIconImageView: UIImageView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet var favouriteButton: UIButton!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    var bar: Bar!
    
    var images: [String] = ["cover_detail", "cover_detail", "cover_detail"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpHeader()
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    func setUpHeader() {
        self.titleLabel.text = self.bar.title.value
        self.mapIconImageView.isHidden = false
        self.distanceLabel.text = "\(self.bar.distance.value) miles away"
        
        let color =  self.bar.isUserFavourite.value == true ? UIColor.appBlueColor() : UIColor.appLightGrayColor()
        self.favouriteButton.tintColor = color
    }
    
    //MARK: IBActions
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        markFavourite()
    }
    
}

//MARK: Webservices Methods
extension BarDetailHeaderViewController {
    func markFavourite() {
        debugPrint("isFav == \(self.bar.isUserFavourite.value)")
        let params:[String : Any] = ["establishment_id": self.bar.id.value,
                                     "is_favorite" : !(self.bar.isUserFavourite.value)]
        
        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
            let editedObject = transaction.edit(bar)
            editedObject!.isUserFavourite.value = !editedObject!.isUserFavourite.value
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
        }
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension BarDetailHeaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
