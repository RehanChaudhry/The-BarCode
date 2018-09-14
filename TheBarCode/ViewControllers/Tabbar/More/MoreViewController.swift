//
//  MoreViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var menuItems: [MenuItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 21))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.appBoldFontOf(size: 16.0)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Welcome, Phillip May"
        self.navigationItem.titleView = titleLabel
        
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.rowHeight = 70.0
        self.tableView.estimatedRowHeight = 70.0
        self.tableView.tableFooterView = UIView()
        
        self.menuItems = MenuItemType.allMenuItems()
        
        self.tableView.register(cellType: MenuCell.self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MenuCell.self)
        cell.setUpCell(menuItem: menuItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = menuItems[indexPath.row]
        
        if menuItem.type == .signOut {
            let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (action) in
                self.tabBarController?.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            self.tabBarController?.present(alertController, animated: true, completion: nil)
        } else if menuItem.type == .preferences {
            let navController = self.storyboard?.instantiateViewController(withIdentifier: menuItem.type.description().storyboardId) as! UINavigationController
            let categoriesController = navController.viewControllers.first as! CategoriesViewController
            categoriesController.isUpdating = true
            self.tabBarController?.present(navController, animated: true, completion: nil)
        }
        else {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: menuItem.type.description().storyboardId)
            self.tabBarController?.present(controller!, animated: true, completion: nil)
        }
    }
}
