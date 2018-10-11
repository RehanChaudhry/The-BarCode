//
//  CategoriesViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class CategoriesViewController: UIViewController {

    @IBOutlet var collectionView: StatefulCollectionView!
    
    @IBOutlet var continueButton: UIButton!
    
    @IBOutlet var infoLabel: UILabel!
    
    var isUpdating: Bool = true
    
    var categories: [Category] = []
    
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
        
        categories.append(Category(title: "Beer Garden", image: "category_1", isSelected: false))
        categories.append(Category(title: "Champagne", image: "category_2", isSelected: false))
        categories.append(Category(title: "Cocktails", image: "category_3", isSelected: false))
        categories.append(Category(title: "Family", image: "category_4", isSelected: false))
        categories.append(Category(title: "Craft Beer", image: "category_5", isSelected: false))
        categories.append(Category(title: "Sports", image: "category_6", isSelected: false))
        categories.append(Category(title: "Gastropub", image: "category_7", isSelected: false))
        categories.append(Category(title: "Late License", image: "category_8", isSelected: false))
        categories.append(Category(title: "Live Music", image: "category_9", isSelected: false))
        categories.append(Category(title: "Pool", image: "category_10", isSelected: false))
        categories.append(Category(title: "Wifi", image: "category_11", isSelected: false))
        categories.append(Category(title: "Wine bar", image: "category_12", isSelected: false))
        
        self.collectionView.innerCollection.register(cellType: CategoryCollectionViewCell.self)
        self.collectionView.innerCollection.delegate = self
        self.collectionView.innerCollection.dataSource = self
        
        collectionView.backgroundColor = .clear
        for aView in collectionView.subviews {
            aView.backgroundColor = .clear
        }
        
        let layout = self.collectionView.innerCollection.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumInteritemSpacing = 16.0
        layout?.sectionInset = UIEdgeInsetsMake(0.0, 16.0, 16.0, 16.0)
        layout?.minimumLineSpacing = 16.0
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
            return category.isSelected
        }
        
        if let _ = selectedCategory {
            if isUpdating {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "CategoriesToPermissionSegue", sender: nil)
            }
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

extension CategoriesViewController: CategoryCollectionViewCellDelegate {
    func categoryCell(cell: CategoryCollectionViewCell, categoryButtonTapped sender: UIButton) {
        
        guard let indexPath = self.collectionView.innerCollection.indexPath(for: cell) else {
            debugPrint("indexpath not found for category cell")
            return
        }
        
        let category = self.categories[indexPath.item]
        category.isSelected = !category.isSelected
        self.categories[indexPath.item] = category
        
        self.collectionView.innerCollection.reloadData()
        
    }
}
