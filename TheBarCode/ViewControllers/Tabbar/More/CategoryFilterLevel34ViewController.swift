//
//  CategoryFilterLevel34ViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import CoreStore

protocol CategoryFilterLevel34ViewControllerDelegate: class {
    func categoryFilterLevel34ViewController(controller: CategoryFilterLevel34ViewController, parentCategoryStatusChanged parentCategory: Category)
    func categoryFilterLevel34ViewController(controller: CategoryFilterLevel34ViewController, continueButtonTapped sender: UIButton)
}

class CategoryFilterLevel34ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var continueButton: GradientButton!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    
    var parentCategory: Category!
    
    typealias SectionedCategory = (category: Category, subcategories: [Category], isExpanded: Bool)
    
    var categories: [SectionedCategory] = []
    
    var transaction: UnsafeDataTransaction!
    
    weak var delegate: CategoryFilterLevel34ViewControllerDelegate!
    
    var comingForUpdatingPreference: Bool = false
    
    var isSelectedAll: Bool {
        get {
            for categorySection in self.categories {
                if categorySection.category.isSelected.value == false {
                    return false
                }
                
                for category in categorySection.subcategories {
                    if category.isSelected.value == false {
                        return false
                    }
                }
            }
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.comingForUpdatingPreference {
            self.bottomViewHeight.constant = 0.0
            self.continueButton.setTitle("Update", for: .normal)
        } else {
            self.continueButton.setTitle("Search", for: .normal)
        }
        
        self.tableView.register(cellType: CategoryFilterLevel4Cell.self)
        self.tableView.register(headerFooterViewType: CategoryFilterLevel3HeaderView.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
//        self.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.getCachedCategories()
        
//        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButtonTapped(sender:)))
//        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
    
    //MARK: My Methods
    func getCachedCategories() {
        let level3Categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == parentCategory.id.value).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
        for level3Category in level3Categories {
            let level4Categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == level3Category.id.value).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
            
            let sectionCategory = (level3Category, level4Categories, false)
            self.categories.append(sectionCategory)
        }
    }
    
    @objc func doneBarButtonTapped(sender: UIBarButtonItem) {
        for controller in self.navigationController?.viewControllers ?? [] {
            if controller is CategoryFilterViewController {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
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
        let selection = !isAllSelected
        
        for categorysection in self.categories {
            categorysection.category.isSelected.value = selection
            markChildAsSelection(category: categorysection.category, selection: selection)
        }
        
        self.parentCategory.isSelected.value = selection
        
        self.delegate.categoryFilterLevel34ViewController(controller: self, parentCategoryStatusChanged: self.parentCategory)
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
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
    
    func updateContinueButtonState() {
        if let _ = self.categories.first(where: {$0.category.isSelected.value || $0.subcategories.first(where: {$0.isSelected.value}) != nil }) {
            self.continueButton.isEnabled = true
            self.continueButton.updateColor(withGrey: false)
        } else {
            self.continueButton.isEnabled = false
            self.continueButton.updateColor(withGrey: true)
        }
    }
    
    func toggleLevel3CategorySelection(sectionCategory: SectionedCategory) {
        let category = sectionCategory.category
        if category.isSelected.value {
            
            category.isSelected.value = false
            for category in sectionCategory.subcategories {
                category.isSelected.value = false
            }
            
            let firstSelected = self.categories.first(where: {$0.category.isSelected.value == true})
            
            self.parentCategory.isSelected.value = firstSelected != nil
            
        } else {
            self.parentCategory.isSelected.value = true
            category.isSelected.value = true
            for category in sectionCategory.subcategories {
                category.isSelected.value = true
            }
        }
        
        self.delegate.categoryFilterLevel34ViewController(controller: self, parentCategoryStatusChanged: self.parentCategory)
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
    
    //MARK: My IBActions
    @IBAction func continueButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel34ViewController(controller: self, continueButtonTapped: sender)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension CategoryFilterLevel34ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 78.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryInfo = self.categories[section]
        if !categoryInfo.isExpanded {
            return 0
        } else {
            return categoryInfo.subcategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(CategoryFilterLevel3HeaderView.self)
        let categoryInfo = self.categories[section]
        headerView?.setupForLevel3(category: categoryInfo.category, isExpanded: categoryInfo.isExpanded)
        headerView?.section = section
        headerView?.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: CategoryFilterLevel4Cell.self)
        cell.setup(category: self.categories[indexPath.section].subcategories[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

//MARK: CategoryFilterLevel4CellDelegate
extension CategoryFilterLevel34ViewController: CategoryFilterLevel4CellDelegate {
    func categoryFilterLevel4Cell(cell: CategoryFilterLevel4Cell, titleButtonTapped sender: UIButton) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let sectionCategory = self.categories[indexPath.section]
        let level3Category = sectionCategory.category
        let level4Category = sectionCategory.subcategories[indexPath.row]
        
        level4Category.isSelected.value = !level4Category.isSelected.value
        
        level3Category.isSelected.value = sectionCategory.subcategories.first(where: {$0.isSelected.value}) != nil
        
        let firstSelected = self.categories.first(where: {$0.category.isSelected.value == true})
        self.parentCategory.isSelected.value = firstSelected != nil
        
        self.delegate.categoryFilterLevel34ViewController(controller: self, parentCategoryStatusChanged: self.parentCategory)
        
        self.tableView.reloadData()
        self.updateContinueButtonState()
        self.updateRightBarButton()
    }
}

//MARK: CategoryFilterLevel3HeaderViewDelegate
extension CategoryFilterLevel34ViewController: CategoryFilterLevel3HeaderViewDelegate {
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, titleButtonTapped sender: UIButton) {
        
        let sectionCategory = self.categories[headerView.section]
        let category = sectionCategory.category
        
        if category.hasChildren.value {
            self.categoryFilterLevel3HeaderView(headerView: headerView, expandButtonTapped: headerView.expandButton)
        } else {
            self.toggleLevel3CategorySelection(sectionCategory: sectionCategory)
        }
    }
    
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, checkboxButtonTapped sender: UIButton) {
        let sectionCategory = self.categories[headerView.section]
        self.toggleLevel3CategorySelection(sectionCategory: sectionCategory)
    }
    
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, expandButtonTapped sender: UIButton) {

        self.categories[headerView.section].isExpanded = !self.categories[headerView.section].isExpanded
        
        headerView.setupForLevel3(category: self.categories[headerView.section].category, isExpanded: self.categories[headerView.section].isExpanded)
        
        var indexPaths: [IndexPath] = []
        for (index, _) in self.categories[headerView.section].subcategories.enumerated() {
            let indexPath = IndexPath(row: index, section: headerView.section)
            indexPaths.append(indexPath)
        }
        
//        self.tableView.beginUpdates()
        
        if self.categories[headerView.section].isExpanded {
            self.tableView.insertRows(at: indexPaths, with: .bottom)
        } else {
            self.tableView.deleteRows(at: indexPaths, with: .top)
        }
        
//        self.tableView.endUpdates()
//        self.tableView.reloadData()
//        let indexSet = IndexSet(integer: headerView.section)
//        self.tableView.reloadSections(indexSet, with: sectionCategory.isExpanded ? .bottom : .top)
    }
}
