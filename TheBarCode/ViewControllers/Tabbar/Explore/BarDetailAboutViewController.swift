//
//  ExploreAboutViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import SJSegmentedScrollView

class BarDetailAboutViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var bar : Bar!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(cellType: ExploreAboutTableViewCell.self)
        self.tableView.estimatedRowHeight = 400.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BarDetailAboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ExploreAboutTableViewCell.self)
        cell.setUpCell(explore: self.bar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: SJSegmentedViewControllerViewSource
extension BarDetailAboutViewController: SJSegmentedViewControllerViewSource {
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return self.tableView
    }
}
