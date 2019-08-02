//
//  WhatsOnViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import SJSegmentedScrollView

protocol WhatsOnViewControllerDelegate: class {
    func whatsOnViewController(controller: WhatsOnViewController, didSelect event: Event)
    func whatsOnViewController(controller: WhatsOnViewController, didSelect food: Food)
    func whatsOnViewController(controller: WhatsOnViewController, didSelect drink: Drink)
}

class WhatsOnViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var eventsContainerView: UIView!
    @IBOutlet var drinklistContainerView: UIView!
    @IBOutlet var foodMenuContainerView: UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var bar: Bar!
    
    var eventsController: EventsViewController!
    var drinksController: DrinkListViewController!
    var foodMenuController: FoodMenuViewController!
    
    weak var delegate: WhatsOnViewControllerDelegate!
    
    var preSelectedTabIndex: Int = 0
    
    var viewDidLayout: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.eventsController = (self.storyboard!.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController)
        self.eventsController.bar = self.bar
        self.eventsController.delegate = self
        self.addChildController(controller: self.eventsController)
        self.eventsContainerView.addSubview(self.eventsController.view)
        self.eventsController.view.autoPinEdgesToSuperviewEdges()
        
        self.drinksController = (self.storyboard!.instantiateViewController(withIdentifier: "DrinkListViewController") as! DrinkListViewController)
        self.drinksController.bar = self.bar
        self.drinksController.delegate = self
        self.addChildController(controller: self.drinksController)
        self.drinklistContainerView.addSubview(self.drinksController.view)
        self.drinksController.view.autoPinEdgesToSuperviewEdges()
        
        self.foodMenuController = (self.storyboard!.instantiateViewController(withIdentifier: "FoodMenuViewController") as! FoodMenuViewController)
        self.foodMenuController.bar = self.bar
        self.foodMenuController.delegate = self
        self.addChildController(controller: self.foodMenuController)
        self.foodMenuContainerView.addSubview(self.foodMenuController.view)
        self.foodMenuController.view.autoPinEdgesToSuperviewEdges()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.viewDidLayout {
            self.viewDidLayout = true
            
            self.segmentedControl.selectedSegmentIndex = self.preSelectedTabIndex
            self.segmentedControl.sendActions(for: .valueChanged)
        }
        
    }
    
    //MARK: My Methods
    func reset() {
        self.eventsController.reset()
        self.drinksController.reset()
        self.foodMenuController.reset()
    }
    
    func addChildController(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.willMove(toParentViewController: self)
        controller.view.backgroundColor = UIColor.clear
    }
    
    //MARK: My IBActions
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.scrollView.scrollToPage(page: sender.selectedSegmentIndex, animated: true)
    }

}

//MARK: SJSegmentedViewControllerViewSource
extension WhatsOnViewController: SJSegmentedViewControllerViewSource {
    func viewsForSegmentControllerToObserveContentOffsetChange() -> [UIView] {
        return [self.eventsController.statefulTableView.innerTable,
                self.drinksController.statefulTableView.innerTable,
                self.foodMenuController.statefulTableView.innerTable]
    }
}

//MARK: EventsViewControllerDelegate
extension WhatsOnViewController: EventsViewControllerDelegate {
    func eventsViewController(controller: EventsViewController, didSelect event: Event) {
        self.delegate.whatsOnViewController(controller: self, didSelect: event)
    }
}

//MARK: DrinkListViewControllerDelegate
extension WhatsOnViewController: DrinkListViewControllerDelegate {
    func drinkListViewController(controller: DrinkListViewController, didSelect drink: Drink) {
        self.delegate.whatsOnViewController(controller: self, didSelect: drink)
    }
}

//MARK: FoodMenuViewControllerDelegate
extension WhatsOnViewController: FoodMenuViewControllerDelegate {
    func foodMenuViewController(controller: FoodMenuViewController, didSelect food: Food) {
        self.delegate.whatsOnViewController(controller: self, didSelect: food)
    }
}
