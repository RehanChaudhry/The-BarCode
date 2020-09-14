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
    
    let transaction = Utility.barCodeDataStack.beginUnsafe()
    
    weak var delegate: CategoryFilterViewControllerDelegate?
    
    var preSelectedCategories: [Category] = []
    
    var shouldDismiss: Bool = false
    
    var comingForUpdatingPreference: Bool = false
    var comingFromSplash: Bool = false
    
    var isViewAlreadyAppeared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        if self.comingForUpdatingPreference {
            self.title = "Update Preferences"
            self.continueButton.setTitle("Update", for: .normal)
        } else {
            self.title = "Filter by Preferences"
            self.continueButton.setTitle("Search", for: .normal)
        }
        
        if !self.comingFromSplash {
            let backImage = UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal)
            let cancelBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(cancelBarButtonTapped(sender:)))
            self.navigationItem.leftBarButtonItem = cancelBarButton
            self.addBackButton()
        } else {
            self.navigationItem.hidesBackButton = true
            self.navigationItem.leftBarButtonItem = nil
        }
        
        
        
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
        
        if !self.isViewAlreadyAppeared {
            self.isViewAlreadyAppeared = true
            
            if self.comingFromSplash {
                self.showUpdateInfoPopup()
            }
        }
    }
    
    func showUpdateInfoPopup() {
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = "Don't miss out on the preferences that we have updated. Check them now!"
        cannotRedeemViewController.titleText = "Preferences"
        cannotRedeemViewController.headerImageName = "login_intro_reload_5"
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        cannotRedeemViewController.delegate = self
        self.present(cannotRedeemViewController, animated: true, completion: nil)
        
        let _ = cannotRedeemViewController.view
        
        cannotRedeemViewController.cancelButton.isHidden = true
        cannotRedeemViewController.actionButton.setTitle("Ok", for: .normal)
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
        if shouldDismiss || self.comingForUpdatingPreference {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func clearBarButtonTapped(sender: UIBarButtonItem) {
        let categories = try! self.transaction.fetchAll(From<Category>())
        for category in categories {
            category.isSelected.value = false
        }
        
        self.collectionView.innerCollection.reloadData()
    }
    
    func getCachedCategories() {
        self.categories = try! self.transaction.fetchAll(From<Category>().where(\Category.parentId == "0").orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title))))
    }
    
    func setUpPreselectedCategories() {
        
        guard !self.comingForUpdatingPreference else {
            debugPrint("preselecting only required when coming for list filtering")
            return
        }
        
        let categories = try! self.transaction.fetchAll(From<Category>())
        for category in categories {
            if let _ = self.preSelectedCategories.first(where: {$0.id.value == category.id.value}) {
                category.isSelected.value = true
            } else {
                category.isSelected.value = false
            }
        }
    }
    
    func preselectAllChildForSelectedCategories() {
        let categories = try! self.transaction.fetchAll(From<Category>().where(\Category.parentId == "0" && \Category.isSelected == true).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title))))
        
        func markChildAsSelected(category: Category) {
            if category.hasChildren.value {
                let childCategories = try! self.transaction.fetchAll(From<Category>().where(\Category.parentId == category.id.value))
                for childCategory in childCategories {
                    childCategory.isSelected.value = true
                    markChildAsSelected(category: childCategory)
                    
                    debugPrint("marking child as selection: \(childCategory.title.value)")
                }
            }
        }
        
        for category in categories {
            markChildAsSelected(category: category)
        }
    }
    
    func moveToNextLevel(category: Category) {
        let categoryLevel2Controller = self.storyboard!.instantiateViewController(withIdentifier: "CategoryFilterLevel2ViewController") as! CategoryFilterLevel2ViewController
        categoryLevel2Controller.title = category.title.value
        categoryLevel2Controller.parentCategory = category
        categoryLevel2Controller.transaction = self.transaction
        categoryLevel2Controller.delegate = self
        categoryLevel2Controller.comingForUpdatingPreference = self.comingForUpdatingPreference
        self.navigationController?.pushViewController(categoryLevel2Controller, animated: true)
    }
    
    //MARK: My IBActions
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        if self.comingForUpdatingPreference {
            let selectedCategories = try! self.transaction.fetchAll(From<Category>().where(\Category.isSelected == true))
            if selectedCategories.count == 0 {
                self.showAlertController(title: "", msg: "Select at least one to proceed")
            } else {
                self.updatePreferences()
            }
        } else {
            let selectedCategories = try! self.transaction.fetchAll(From<Category>().where(\Category.isSelected == true))
            
            let filteredCategories = selectedCategories.filter({ $0.hasChildren.value == false })
            
            var fetchedSelectedCategories: [Category] = []
            var fetchedFilteredCategories: [Category] = []
            
            for object in selectedCategories {
                let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                fetchedSelectedCategories.append(fetchedObject!)
            }
            
            for object in filteredCategories {
                let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                fetchedFilteredCategories.append(fetchedObject!)
            }
            
            if self.shouldDismiss && selectedCategories.count == 0 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.delegate?.categoryFilterViewController(controller: self, didSelectPrefernces: fetchedSelectedCategories, filteredPreferences: fetchedFilteredCategories)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            debugPrint("selected categories: \(fetchedFilteredCategories.map({$0.title.value}))")
            
            self.transaction.flush()
        }
    }
}

//MARK: CategoryFilterLevel2ViewControllerDelegate
extension CategoryFilterViewController: CategoryFilterLevel2ViewControllerDelegate {
    func categoryFilterLevel2ViewController(controller: CategoryFilterLevel2ViewController, continueButtonTapped sender: UIButton) {
        self.continueButton.sendActions(for: .touchUpInside)
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
                
                let dataStack = Utility.barCodeDataStack
                try! dataStack.perform(synchronous: { (transaction) -> Void in
                    let importedObjects = try! transaction.importUniqueObjects(Into<Category>(), sourceArray: responseCategories)
                    
                    
                    func markParentsAsSelected(category: Category) {
                        if let parentId = category.parentId.value,
                            parentId != "0",
                            let parentCategory = try! transaction.fetchOne(From<Category>().where(\Category.id == category.parentId.value ?? "")) {
                            
                            parentCategory.isSelected.value = true
                            markParentsAsSelected(category: parentCategory)
                            
                            debugPrint("marking parent as selected: \(parentCategory.title.value)")
                            
                        } else {
                            category.isSelected.value = true
                        }
                    }
                    
                    let lastLevelCategories = try! transaction.fetchAll(From<Category>().where(\Category.isSelected == true && \Category.hasChildren == false))
                    for category in lastLevelCategories {
                        markParentsAsSelected(category: category)
                    }
                    
                    debugPrint("Imported categories count: \(importedObjects.count)")
                })
                
                self.getCachedCategories()
                self.setUpPreselectedCategories()
                if self.comingFromSplash {
                    self.preselectAllChildForSelectedCategories()
                }
                self.collectionView.innerCollection.reloadData()
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
        }
    }
    
    func updatePreferences() {
        
        let selectedCategories = try! self.transaction.fetchAll(From<Category>().where(\Category.isSelected == true))
        
//        let filteredCategories = selectedCategories.filter({ $0.hasChildren.value == false })
        
        let selectedCategoriesIds = selectedCategories.map({$0.id.value})
        let params = ["ids" : selectedCategoriesIds]
        
        self.continueButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathUpdateSelectedCategories, method: .post) { (response, serverError, error) in
            
            self.continueButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! self.transaction.commitAndWait()
            
            let user = Utility.shared.getCurrentUser()!
            try! CoreStore.perform(synchronous: { (transaction) -> Void in
                let edittedUser = transaction.edit(user)
                edittedUser?.isCategorySelected.value = true
            })
            
            if self.comingFromSplash {
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
                tabbarController?.modalPresentationStyle = .fullScreen
                
                self.navigationController?.present(tabbarController!, animated: false, completion: {
                    let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                    self.navigationController?.popToViewController(loginOptions, animated: false)
                })
            } else if self.comingForUpdatingPreference {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
}

//CannotRedeemViewControllerDelegate
extension CategoryFilterViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}
