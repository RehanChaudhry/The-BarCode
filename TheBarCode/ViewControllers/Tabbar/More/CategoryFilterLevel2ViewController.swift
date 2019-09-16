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

class CategoryFilterLevel2ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var transaction: UnsafeDataTransaction!
    
    var parentCategory: Category!
    var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(cellType: CategoryFilterLevel2Cell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.addBackButton()
        
        self.getCachedCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    //MARK: My Methods
    func getCachedCategories() {
        self.categories = self.transaction.fetchAll(From<Category>().where(\Category.parentId == parentCategory.id.value).orderBy(OrderBy.SortKey.ascending(String(keyPath: \Category.title)))) ?? []
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
            self.navigationController?.pushViewController(nextLevelViewController, animated: true)
            
        } else {
            category.isSelected.value = !category.isSelected.value
        }
        
        self.parentCategory.isSelected.value = self.categories.first(where: {$0.isSelected.value}) != nil
        
        self.tableView.reloadData()
    }
}

//MARK: CategoryFilterLevel34ViewControllerDelegate
extension CategoryFilterLevel2ViewController: CategoryFilterLevel34ViewControllerDelegate {
    func categoryFilterLevel34ViewController(controller: CategoryFilterLevel34ViewController, parentCategoryStatusChanged parentCategory: Category) {
        self.parentCategory.isSelected.value = (parentCategory.isSelected.value || self.categories.first(where: {$0.isSelected.value}) != nil)
        
        self.tableView.reloadData()
    }
}
