//
//  MapPinsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 24/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

protocol MapPinsViewControllerDelegate: class {
    func mapPinsViewController(controller: MapPinsViewController, didSelectMapBar mapBar: MapBasicBar)
}

class MapPinsViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet var bgButton: UIButton!
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var centerYConstraint: NSLayoutConstraint!
    
    var mapBars: [MapBasicBar] = []
    
    weak var delegate: MapPinsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(cellType: MapPinCell.self)
        self.tableView.rowHeight = 63.0
        self.tableView.tableFooterView = UIView()
        
        self.heightConstraint.constant = CGFloat.minimum(CGFloat(self.mapBars.count) * 63.0, 300.0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: My IBActions
    @IBAction func backgrounButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension MapPinsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapBars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MapPinCell.self)
        cell.setUpCell(mapBar: self.mapBars[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mapBar = self.mapBars[indexPath.row]
        self.delegate.mapPinsViewController(controller: self, didSelectMapBar: mapBar)
    }
}

