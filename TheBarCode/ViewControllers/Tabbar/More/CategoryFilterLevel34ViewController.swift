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
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var continueButton: GradientButton!
    @IBOutlet var bottomViewHeight: NSLayoutConstraint!
    
    var parentCategory: Category!
    
    typealias SectionedCategory = (category: Category, subcategories: [Category], isExpanded: Bool)
    
    var categories: [SectionedCategory] = []
    var searchingCategories: [SectionedCategory] = []
    
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
    
    var searchController: UISearchController!
    
    var isSearching: Bool {
        get {
            return self.searchController.isActive && self.searchController.searchBar.text!.count > 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.definesPresentationContext = true
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.backgroundColor = self.view.backgroundColor
        self.searchController.searchBar.backgroundImage = UIImage()
        self.searchController.searchBar.searchBarStyle = .minimal
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        
        let textFieldInsideSearchBar = self.searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        if self.comingForUpdatingPreference {
            self.bottomViewHeight.constant = 0.0
            self.bottomView.isHidden = true
            self.continueButton.setTitle("Update", for: .normal)
        } else {
            self.continueButton.setTitle("Search", for: .normal)
        }
        
        self.tableView.register(cellType: CategoryFilterLevel4Cell.self)
        self.tableView.register(headerFooterViewType: CategoryFilterLevel3HeaderView.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clear
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
    
    func toggleLevel3CategorySelection(selectedSectionCategory: SectionedCategory) {
        
        guard let index = self.categories.firstIndex(where: {$0.category == selectedSectionCategory.category}) else {
            debugPrint("Index not found")
            return
        }
        
        let sectionCategory = self.categories[index]
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchController.searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 78.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isSearching {
            return self.searchingCategories.count
        } else {
            return self.categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryInfo: SectionedCategory
        if self.isSearching {
            categoryInfo = self.searchingCategories[section]
        } else {
            categoryInfo = self.categories[section]
        }
        
        if !categoryInfo.isExpanded {
            return 0
        } else {
            return categoryInfo.subcategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(CategoryFilterLevel3HeaderView.self)
        
        let categoryInfo: SectionedCategory
        if self.isSearching {
            categoryInfo = self.searchingCategories[section]
        } else {
            categoryInfo = self.categories[section]
        }
        
        headerView?.setupForLevel3(category: categoryInfo.category, isExpanded: categoryInfo.isExpanded)
        headerView?.section = section
        headerView?.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: CategoryFilterLevel4Cell.self)
        
        let category: Category
        if self.isSearching {
            category = self.searchingCategories[indexPath.section].subcategories[indexPath.row]
        } else {
            category = self.categories[indexPath.section].subcategories[indexPath.row]
        }
        
        cell.setup(category: category)
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
        
        let sectionCategory: SectionedCategory
        if self.isSearching {
            sectionCategory = self.searchingCategories[indexPath.section]
        } else {
            sectionCategory = self.categories[indexPath.section]
        }
        
        guard let originalIndex = self.categories.firstIndex(where: {$0.category == sectionCategory.category}) else {
            debugPrint("Index not found")
            return
        }
        
        let originalCategory = self.categories[originalIndex]
        
        let level3Category = sectionCategory.category
        let level4Category = sectionCategory.subcategories[indexPath.row]
        
        level4Category.isSelected.value = !level4Category.isSelected.value
        
        level3Category.isSelected.value = originalCategory.subcategories.first(where: {$0.isSelected.value}) != nil
        
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
        
        let sectionCategory: SectionedCategory
        if self.isSearching {
            sectionCategory = self.searchingCategories[headerView.section]
        } else {
            sectionCategory = self.categories[headerView.section]
        }
        
        let category = sectionCategory.category
        
        if category.hasChildren.value {
            self.categoryFilterLevel3HeaderView(headerView: headerView, expandButtonTapped: headerView.expandButton)
        } else {
            self.toggleLevel3CategorySelection(selectedSectionCategory: sectionCategory)
        }
    }
    
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, checkboxButtonTapped sender: UIButton) {
        let sectionCategory: SectionedCategory
        if self.isSearching {
            sectionCategory = self.searchingCategories[headerView.section]
        } else {
            sectionCategory = self.categories[headerView.section]
        }
        self.toggleLevel3CategorySelection(selectedSectionCategory: sectionCategory)
    }
    
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, expandButtonTapped sender: UIButton) {

        var sectionCategory: SectionedCategory
        if self.isSearching {
            sectionCategory = self.searchingCategories[headerView.section]
            sectionCategory.isExpanded = !sectionCategory.isExpanded
            self.searchingCategories[headerView.section] = sectionCategory
        } else {
            sectionCategory = self.categories[headerView.section]
            sectionCategory.isExpanded = !sectionCategory.isExpanded
            self.categories[headerView.section] = sectionCategory
        }
        
        headerView.setupForLevel3(category: sectionCategory.category, isExpanded: sectionCategory.isExpanded)
        
        var indexPaths: [IndexPath] = []
        for i in 0..<sectionCategory.subcategories.count {
            let indexPath = IndexPath(row: i, section: headerView.section)
            indexPaths.append(indexPath)
        }
        
        if sectionCategory.isExpanded {
            self.tableView.insertRows(at: indexPaths, with: .bottom)
        } else {
            self.tableView.deleteRows(at: indexPaths, with: .top)
        }
    }
}

//MARK: UISearchResultsUpdating
extension CategoryFilterLevel34ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        
        self.searchingCategories.removeAll()
        
        for categorySection in self.categories {
            let hasSearchText = categorySection.category.title.value.lowercased().contains(searchText)
            let subCategories = categorySection.subcategories.filter({$0.title.value.lowercased().contains(searchText)})
            
            if hasSearchText || subCategories.count > 0 {
                let filteredSection = (categorySection.category, subCategories, true)
                self.searchingCategories.append(filteredSection)
            }
        }
        
        self.tableView.reloadData()
    }
}

//MARK: UISearchControllerDelegate
extension CategoryFilterLevel34ViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
    }
}
