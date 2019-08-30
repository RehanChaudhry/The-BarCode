//
//  CategoryFilterViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import CoreStore
import CoreLocation

protocol CategoryFilterViewControllerDelegate: class {
    func categoryFilterViewController(controller: CategoryFilterViewController, didSelectPrefernces selectedPreferences: [Category], filteredPreferences: [Category])
}

class CategoryFilterViewController: UIViewController {

    @IBOutlet var collectionView: StatefulCollectionView!
    
    @IBOutlet var continueButton: GradientButton!
    
    var categories: [Category] = []
    
    var statefulView: LoadingAndErrorView!
    
    let transaction = Utility.inMemoryStack.beginUnsafe()
    
    weak var delegate: CategoryFilterViewControllerDelegate?
    
    var preSelectedCategories: [Category] = []
    
    var shouldDismiss: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Filter by Preferences"
        let cancelBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelBarButtonTapped(sender:)))
        self.navigationItem.leftBarButtonItem = cancelBarButton
        self.addBackButton()
        
        self.continueButton.setTitle("Update", for: .normal)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self] (sender: UIButton) in
            self.getCategories()
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
        
        for aView in self.collectionView.innerCollection.subviews {
            if aView.isMember(of: UIRefreshControl.self) {
                aView.removeFromSuperview()
                break
            }
        }
        
        self.getCachedCategories()
        self.setUpPreselectedCategories()
        
        if self.categories.count == 0 {
            self.getCategories()
        } else {
            self.statefulView.isHidden = true
        }
        
        let clearBarButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearBarButtonTapped(sender:)))
        self.navigationItem.rightBarButtonItem = clearBarButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        self.collectionView.innerCollection.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func getItemSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let noOfItemsPerRow = UInt(screenWidth / 120.0)
        
        let layout = collectionView.innerCollection.collectionViewLayout as? UICollectionViewFlowLayout
        
        let itemSpacing = (CGFloat(noOfItemsPerRow - 1) * layout!.minimumInteritemSpacing) + (layout!.sectionInset.left + layout!.sectionInset.right)
        let cellWidth = (screenWidth - itemSpacing) / CGFloat(noOfItemsPerRow)
        
        let size = CGSize(width: floor(cellWidth), height: floor(cellWidth))
        return size
    }
    
    @objc func cancelBarButtonTapped(sender: UIBarButtonItem) {
        if shouldDismiss {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func clearBarButtonTapped(sender: UIBarButtonItem) {
        let categories = self.transaction.fetchAll(From<Category>()) ?? []
        for category in categories {
            category.isSelected.value = false
        }
        
        self.collectionView.innerCollection.reloadData()
    }
    
    func getCachedCategories() {
        self.categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == "0").orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
    }
    
    func setUpPreselectedCategories() {
        let categories = self.transaction.fetchAll(From<Category>()) ?? []
        for category in categories {
            if let _ = self.preSelectedCategories.first(where: {$0.id.value == category.id.value}) {
                category.isSelected.value = true
            } else {
                category.isSelected.value = false
            }
        }
    }
    
    func moveToNextLevel(category: Category) {
        let categoryLevel2Controller = self.storyboard!.instantiateViewController(withIdentifier: "CategoryFilterLevel2ViewController") as! CategoryFilterLevel2ViewController
        categoryLevel2Controller.title = category.title.value
        categoryLevel2Controller.parentCategory = category
        categoryLevel2Controller.transaction = self.transaction
        self.navigationController?.pushViewController(categoryLevel2Controller, animated: true)
    }
    
    //MARK: My IBActions
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        let selectedCategories = self.transaction.fetchAll(From<Category>().where(\Category.isSelected == true)) ?? []
        
        let filteredCategories = selectedCategories.filter({ $0.hasChildren.value == false })
        
        var fetchedSelectedCategories: [Category] = []
        var fetchedFilteredCategories: [Category] = []
        
        for object in selectedCategories {
            let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
            fetchedSelectedCategories.append(fetchedObject!)
        }
        
        for object in filteredCategories {
            let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
            fetchedFilteredCategories.append(fetchedObject!)
        }
        
        if self.shouldDismiss && selectedCategories.count == 0 {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.delegate?.categoryFilterViewController(controller: self, didSelectPrefernces: fetchedSelectedCategories, filteredPreferences: fetchedFilteredCategories)
            self.navigationController?.popViewController(animated: true)
        }
        
        debugPrint("selected categories: \(fetchedFilteredCategories.map({$0.title.value}))")
        
        self.transaction.flush()
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension CategoryFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
extension CategoryFilterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getItemSize()
    }
}

//MARK: CategoryCollectionViewCellDelegate
extension CategoryFilterViewController: CategoryCollectionViewCellDelegate {
    func categoryCell(cell: CategoryCollectionViewCell, categoryButtonTapped sender: UIButton) {
        
        guard let indexPath = self.collectionView.innerCollection.indexPath(for: cell) else {
            debugPrint("indexpath not found for category cell")
            return
        }
        
        let category = self.categories[indexPath.item]
        if category.hasChildren.value {
            self.moveToNextLevel(category: category)
        } else {
            category.isSelected.value = !category.isSelected.value
        }

        self.collectionView.innerCollection.reloadItems(at: [indexPath])
    }
}

//MARK: Webservices Methods
extension CategoryFilterViewController {
    
    func getCategories() {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathCategories, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To refresh")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")
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
                
                self.getCachedCategories()
                self.setUpPreselectedCategories()
                self.collectionView.innerCollection.reloadData()
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
        }
    }
}
