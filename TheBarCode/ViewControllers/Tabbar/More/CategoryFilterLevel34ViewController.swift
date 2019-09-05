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
}

class CategoryFilterLevel34ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var parentCategory: Category!
    
    typealias SectionedCategory = (category: Category, subcategories: [Category])
    
    var categories: [SectionedCategory] = []
    
    var transaction: UnsafeDataTransaction!
    
    weak var delegate: CategoryFilterLevel34ViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(cellType: CategoryFilterLevel4Cell.self)
        self.tableView.register(headerFooterViewType: CategoryFilterLevel3HeaderView.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 32.0, bottom: 0.0, right: 0.0)
        
        self.getCachedCategories()
        
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButtonTapped(sender:)))
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    //MARK: My Methods
    func getCachedCategories() {
        let level3Categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == parentCategory.id.value).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
        for level3Category in level3Categories {
            let level4Categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == level3Category.id.value).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
            
            let sectionCategory = (level3Category, level4Categories)
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
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension CategoryFilterLevel34ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories[section].subcategories.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(CategoryFilterLevel3HeaderView.self)
        headerView?.setupForLevel3(category: self.categories[section].category)
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
    }
}

//MARK: CategoryFilterLevel3HeaderViewDelegate
extension CategoryFilterLevel34ViewController: CategoryFilterLevel3HeaderViewDelegate {
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, titleButtonTapped sender: UIButton) {
        
        let sectionCategory = self.categories[headerView.section]
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
    }
}
