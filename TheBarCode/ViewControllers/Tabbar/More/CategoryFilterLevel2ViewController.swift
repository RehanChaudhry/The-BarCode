//
//  CategoryFilterLevel2ViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import CoreStore

protocol CategoryFilterLevel2ViewControllerDelegate: class {
    func categoryFilterLevel2ViewController(controller: CategoryFilterLevel2ViewController, continueButtonTapped sender: UIButton)
}

class CategoryFilterLevel2ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var continueButton: GradientButton!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    
    var comingForUpdatingPreference: Bool = false
    
    var transaction: UnsafeDataTransaction!
    
    var parentCategory: Category!
    var categories: [Category] = []
    
    weak var delegate: CategoryFilterLevel2ViewControllerDelegate!
    
    var isSelectedAll: Bool {
        get {
            return self.categories.first(where: {$0.isSelected.value == false}) == nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.comingForUpdatingPreference {
            self.bottomView.isHidden = true
            self.bottomViewHeight.constant = 0.0
            self.continueButton.setTitle("Update", for: .normal)
        } else {
            self.continueButton.setTitle("Search", for: .normal)
        }
        
        self.tableView.register(cellType: CategoryFilterLevel2Cell.self)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 8.0))
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
//        self.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.addBackButton()
        
        self.getCachedCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
    
    //MARK: My Methods
    
    func updateRightBarButton() {
        if self.categories.count > 0 {
            let barButton = UIBarButtonItem(title: self.isSelectedAll ? "Deselect All" : "Select All", style: .plain, target: self, action: #selector(rightBarButtonTapped(sender:)))
            self.navigationItem.rightBarButtonItem = barButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func rightBarButtonTapped(sender: UIBarButtonItem) {
        
        let isAllSelected = self.isSelectedAll
        
        for category in self.categories {
            let selection = !isAllSelected
            category.isSelected.value = selection
            
            markChildAsSelection(category: category, selection: selection)
        }
    
        self.parentCategory.isSelected.value = self.categories.first(where: {$0.isSelected.value}) != nil
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
    
    func getCachedCategories() {
        self.categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == parentCategory.id.value).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
    }
    
    func updateContinueButtonState() {
        if let _ = self.categories.first(where: {$0.isSelected.value}) {
            self.continueButton.isEnabled = true
            self.continueButton.updateColor(withGrey: false)
        } else {
            self.continueButton.isEnabled = false
            self.continueButton.updateColor(withGrey: true)
        }
    }
    
    func markChildAsSelection(category: Category, selection: Bool) {
        if category.hasChildren.value,
            let childCategories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == category.id.value)) {
            for childCategory in childCategories {
                childCategory.isSelected.value = selection
                markChildAsSelection(category: childCategory, selection: selection)
                
                debugPrint("marking child as selection: \(childCategory.title.value)")
            }
        }
    }
    
    //MARK: My IBActions
    @IBAction func continueButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel2ViewController(controller: self, continueButtonTapped: sender)
    }
}

//MARK: CategoryFilterLevel34ViewControllerDelegate
extension CategoryFilterLevel2ViewController: CategoryFilterLevel34ViewControllerDelegate {
    func categoryFilterLevel34ViewController(controller: CategoryFilterLevel34ViewController, continueButtonTapped sender: UIButton) {
        self.delegate.categoryFilterLevel2ViewController(controller: self, continueButtonTapped: sender)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension CategoryFilterLevel2ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: CategoryFilterLevel2Cell.self)
        cell.setup(category: self.categories[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

//MARK: CategoryFilterLevel2CellDelegate
extension CategoryFilterLevel2ViewController: CategoryFilterLevel2CellDelegate {
    
    func categoryFilterLevel34ViewController(controller: CategoryFilterLevel34ViewController, parentCategoryStatusChanged parentCategory: Category) {
        self.parentCategory.isSelected.value = (parentCategory.isSelected.value || self.categories.first(where: {$0.isSelected.value}) != nil)
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
    
    func categoryFilterLevel2Cell(cell: CategoryFilterLevel2Cell, titleButtonTapped sender: UIButton) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let category = self.categories[indexPath.row]
        if category.hasChildren.value {
            let nextLevelViewController = self.storyboard!.instantiateViewController(withIdentifier: "CategoryFilterLevel34ViewController") as! CategoryFilterLevel34ViewController
            nextLevelViewController.title = category.title.value
            nextLevelViewController.transaction = self.transaction
            nextLevelViewController.parentCategory = category
            nextLevelViewController.delegate = self
            nextLevelViewController.comingForUpdatingPreference = self.comingForUpdatingPreference
            self.navigationController?.pushViewController(nextLevelViewController, animated: true)
            
        } else {
            category.isSelected.value = !category.isSelected.value
            
            self.parentCategory.isSelected.value = self.categories.first(where: {$0.isSelected.value}) != nil
            
            self.tableView.reloadData()
            self.updateContinueButtonState()
            self.updateRightBarButton()
        }
    }
    
    func categoryFilterLevel2Cell(cell: CategoryFilterLevel2Cell, checkboxButtonTapped sender: UIButton) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let category = self.categories[indexPath.row]
        
        let selection = !category.isSelected.value
        category.isSelected.value = selection
        
        markChildAsSelection(category: category, selection: selection)
        
        self.parentCategory.isSelected.value = self.categories.first(where: {$0.isSelected.value}) != nil
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
}

