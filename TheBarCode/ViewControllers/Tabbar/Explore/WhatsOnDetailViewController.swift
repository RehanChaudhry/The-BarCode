//
//  WhatsOnDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

enum WhatsOnType: String {
    case event = "event", drink = "drink", food = "food"
}

class WhatsOnDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    var bar: Bar!
    var type: WhatsOnType!
    
    var event: Event?
    var drink: Drink?
    var food: Food?
    
    var images: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
        self.tableView.register(cellType: WhatsOnDetailFoodCell.self)
        self.tableView.register(cellType: WhatsOnDetailEventCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.estimatedRowHeight = 250.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        switch self.type! {
        case .event:
            self.images = [self.event!.image.value]
            self.title = self.event!.name.value
        case .drink:
            self.images = [self.drink!.image.value]
            self.title = self.drink!.name.value
        case .food:
            self.images = [self.food!.image.value]
            self.title = self.food!.name.value
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewHeight = ((273.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight
        
        var headerFrame = self.headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = headerViewHeight
        self.headerView.frame = headerFrame
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }

    //MARK: My IBActions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension WhatsOnDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.type! {
        case .event:
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: WhatsOnDetailEventCell.self)
            cell.setupEvent(event: self.event!, bar: self.bar!)
            cell.delegate = self
            return cell
        case .drink:
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: WhatsOnDetailFoodCell.self)
            cell.setupDrink(drink: self.drink!, bar: self.bar!)
            return cell
        case .food:
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: WhatsOnDetailFoodCell.self)
            cell.setupFood(food: self.food!, bar: self.bar!)
            return cell
        }
    }
    
}


//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension WhatsOnDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.images[indexPath.item])
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension WhatsOnDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}

//MARK: WhatsOnDetailCellDelegate
extension WhatsOnDetailViewController: WhatsOnDetailFoodCellDelegate {
    func whatsOnDetailFoodCell(cell: WhatsOnDetailFoodCell, directionButtonTapped sender: UIButton) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(self.bar.latitude.value),\(self.bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
}

//MARK: WhatsOnDetailEventCellDelegate
extension WhatsOnDetailViewController: WhatsOnDetailEventCellDelegate {
    func whatsOnDetailEventCell(cell: WhatsOnDetailEventCell, directionsButtonTapped sender: UIButton) {
        if let lat = self.event?.lat.value, let lng = self.event?.lng.value {
            let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)"
            UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
                
            }
        }
    }
}
