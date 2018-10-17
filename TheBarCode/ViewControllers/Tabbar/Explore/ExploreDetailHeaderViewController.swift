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

class ExploreDetailHeaderViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var favouriteButton: UIButton!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    var explore: Explore!
    
    var images: [String] = ["cover_detail", "cover_detail", "cover_detail"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.pageControl.numberOfPages = self.images.count
        let color =  self.explore.isUserFavourite.value == true ? UIColor.appLightGrayColor() : UIColor.appBlueColor()
        self.favouriteButton.tintColor = color
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        markFavourite()
    }
    
    
}

//MARK: Webservices Methods
extension ExploreDetailHeaderViewController {
    func markFavourite() {
      
        let params:[String : Any] = ["establishment_id": self.explore.id.value, "is_favorite" : !(self.explore.isUserFavourite.value)]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiUpdateFavorite, method: .put) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error == \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror == \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let responseDict = (response as? [String : Any])
            debugPrint("responseDict == \(responseDict)")
            if let responseID = (responseDict?["data"] as? Int) {
                
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
//                    let bar : Bar = try! transaction.fetchOne(From<Bar>().where(\.id == "\(responseID)"))
//                    bar.isUserFavourite.value = !(self.explore.isUserFavourite.value)
                })
              
                self.explore.isUserFavourite.value = !(self.explore.isUserFavourite.value)
                
                let color =  self.explore.isUserFavourite.value == true ? UIColor.appLightGrayColor() : UIColor.appBlueColor()
                self.favouriteButton.tintColor = color
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
        }
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension ExploreDetailHeaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.explore.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.explore.images[indexPath.item].url.value)
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension ExploreDetailHeaderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}
