//
//  CategoriesViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import CoreStore

class CategoriesViewController: UIViewController {

    @IBOutlet var collectionView: StatefulCollectionView!
    
    @IBOutlet var continueButton: UIButton!
    
    @IBOutlet var infoLabel: UILabel!
    
    var isUpdating: Bool = true
    
    var categories: [Category] = []
    
    var statefulView: LoadingAndErrorView!
    
    let transaction = Utility.inMemoryStack.beginUnsafe()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.isUpdating {
            self.title = "Update preferences"
            self.infoLabel.text = "Please update your preferences."
            let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonTapped(sender:)))
            self.navigationItem.leftBarButtonItem = cancelBarButton
            
            self.continueButton.setTitle("Update", for: .normal)
        } else {
            self.title = "Personalize your experience"
            self.navigationItem.hidesBackButton = true
            self.infoLabel.text = "Please tap on few things you like to get started."
            
            self.continueButton.setTitle("Continue", for: .normal)
        }
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {(sender: UIButton) in
            
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.collectionView.innerCollection.register(cellType: CategoryCollectionViewCell.self)
        self.collectionView.innerCollection.delegate = self
        self.collectionView.innerCollection.dataSource = self
        
        self.collectionView.backgroundColor = .clear
        for aView in self.collectionView.subviews {
            aView.backgroundColor = .clear
        }
        
        let layout = self.collectionView.innerCollection.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumInteritemSpacing = 16.0
        layout?.sectionInset = UIEdgeInsetsMake(0.0, 16.0, 16.0, 16.0)
        layout?.minimumLineSpacing = 16.0
        
        self.getCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    func getItemSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let noOfItemsPerRow = UInt(screenWidth / 100.0)
        
        let layout = collectionView.innerCollection.collectionViewLayout as? UICollectionViewFlowLayout
        
        let itemSpacing = (CGFloat(noOfItemsPerRow - 1) * layout!.minimumInteritemSpacing) + (layout!.sectionInset.left + layout!.sectionInset.right)
        let cellWidth = (screenWidth - itemSpacing) / CGFloat(noOfItemsPerRow)
        
        let size = CGSize(width: floor(cellWidth), height: floor(cellWidth))
        return size
    }
    
    @objc func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        let selectedCategory = self.categories.first { (category) -> Bool in
            return category.isSelected.value
        }
        
        if let _ = selectedCategory {
            self.updatePreferences()
        } else {
            self.showAlertController(title: "", msg: "Select at least one to proceed")
        }
    }

}

extension CategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.innerCollection.dequeueReusableCell(for: indexPath, cellType: CategoryCollectionViewCell.self)
        cell.setUpCell(category: self.categories[indexPath.item])
        cell.delegate = self
        return cell
    }
}

//MARK: UICollectionViewDelegateFlowLayout

extension CategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getItemSize()
    }
}

//MARK: CategoryCollectionViewCellDelegate
extension CategoriesViewController: CategoryCollectionViewCellDelegate {
    func categoryCell(cell: CategoryCollectionViewCell, categoryButtonTapped sender: UIButton) {
        
        guard let indexPath = self.collectionView.innerCollection.indexPath(for: cell) else {
            debugPrint("indexpath not found for category cell")
            return
        }
        
        let category = self.categories[indexPath.item]
        category.isSelected.value = !category.isSelected.value
        
        self.collectionView.innerCollection.reloadItems(at: [indexPath])
    }
}

//MARK: Webservices Methods
extension CategoriesViewController {
    
    func getCategories() {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathCategories, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To Reload")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To Reload")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseCategories = (responseDict?["data"] as? [[String : Any]]) {
                self.categories.removeAll()

                let dataStack = Utility.inMemoryStack
                try! dataStack.perform(synchronous: { (transaction) -> Void in
                    let importedObjects = try! transaction.importUniqueObjects(Into<Category>(), sourceArray: responseCategories)
                    debugPrint("Imported categories count: \(importedObjects.count)")
                })
                
                self.categories = self.transaction.fetchAll(From<Category>().orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
                self.collectionView.innerCollection.reloadData()
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To Reload")
            }
        }
    }
    
    func updatePreferences() {
        
        let selectedCategories = self.categories.filter { (category) -> Bool in
            return category.isSelected.value
        }
        
        let selectedCategoriesIds = selectedCategories.map({$0.id.value})
        let params = ["ids" : selectedCategoriesIds]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathUpdateSelectedCategories, method: .post) { (response, serverError, error) in
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! self.transaction.commitAndWait()
            
            if self.isUpdating {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "CategoriesToPermissionSegue", sender: nil)
            }
        }
    }
    
}
