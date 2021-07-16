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
    func whatsOnViewController(controller: WhatsOnViewController, didSelect product: Product)
}

class WhatsOnViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
//    @IBOutlet var eventsContainerView: UIView!
//    @IBOutlet var drinklistContainerView: UIView!
//    @IBOutlet var foodMenuContainerView: UIView!
    
    @IBOutlet var placeholderView: UIView!
    
    var eventsContainer: UIView!
    var drinksContainer: UIView?
    var foodContainer: UIView!
    
    
    @IBOutlet var segmentContainer: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentControlHeightConstraint: NSLayoutConstraint!
    
    var bar: Bar!
    
    var eventsController: EventsViewController!
    var drinksController: DrinkListViewController?
    var foodMenuController: FoodMenuViewController!
    
    weak var delegate: WhatsOnViewControllerDelegate!
    
    var preSelectedTabIndex: Int = 0
    
    var viewDidLayout: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.setupContainerView()
        
        self.segmentContainer.backgroundColor = UIColor.appNavBarGrayColor()
        
        if self.bar.menuType == .barCode {
            self.drinksController = (self.storyboard!.instantiateViewController(withIdentifier: "DrinkListViewController") as! DrinkListViewController)
            self.drinksController!.bar = self.bar
            self.drinksController!.delegate = self
            self.addChildController(controller: self.drinksController!)
            self.drinksContainer?.addSubview(self.drinksController!.view)
            self.drinksController!.view.autoPinEdgesToSuperviewEdges()
            self.segmentControlHeightConstraint.constant = 47
        } else {
            self.segmentedControl.removeSegment(at: 2, animated: false)
            self.segmentedControl.setTitle("Food & Drinks", forSegmentAt: 1)
            self.segmentedControl.isHidden = true
            self.segmentControlHeightConstraint.constant = 0
        }
        
        self.foodMenuController = (self.storyboard!.instantiateViewController(withIdentifier: "FoodMenuViewController") as! FoodMenuViewController)
        self.foodMenuController.bar = self.bar
        self.foodMenuController.delegate = self
        self.addChildController(controller: self.foodMenuController)
        self.foodContainer.addSubview(self.foodMenuController.view)
        self.foodMenuController.view.autoPinEdgesToSuperviewEdges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.viewDidLayout {
            self.viewDidLayout = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let selectedSegmentIndex = self.preSelectedTabIndex > self.segmentedControl.numberOfSegments - 1 ? self.segmentedControl.numberOfSegments - 1 : self.preSelectedTabIndex
                self.segmentedControl.selectedSegmentIndex = selectedSegmentIndex
                self.segmentedControl.sendActions(for: .valueChanged)
            }
        }
        
    }
    
    //MARK: My Methods
    func setupContainerView() {
//        self.eventsContainer = UIView()
//        self.eventsContainer.backgroundColor = UIColor.clear
//        self.contentView.addSubview(self.eventsContainer)
//
//        self.eventsContainer.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.contentView)
//        self.eventsContainer.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self.contentView)
//        self.eventsContainer.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self.contentView)
//
//        self.eventsContainer.autoMatch(ALDimension.width, to: ALDimension.width, of: self.placeholderView)
//        self.eventsContainer.autoMatch(ALDimension.height, to: ALDimension.height, of: self.placeholderView)
        
        if self.bar.menuType == .barCode {
            self.drinksContainer = UIView()
            self.drinksContainer?.backgroundColor = UIColor.clear
            self.contentView.addSubview(self.drinksContainer!)
            
            self.drinksContainer!.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.contentView)
            self.drinksContainer!.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self.contentView)
            self.drinksContainer!.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self.contentView)
            
            self.drinksContainer!.autoMatch(ALDimension.width, to: ALDimension.width, of: self.placeholderView)
            self.drinksContainer!.autoMatch(ALDimension.height, to: ALDimension.height, of: self.placeholderView)
        }
        
        self.foodContainer = UIView()
        self.foodContainer.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.foodContainer)
        
        self.foodContainer.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.contentView)
        self.foodContainer.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self.contentView)
        self.foodContainer.autoPinEdge(ALEdge.left, to: self.bar.menuType == .barCode ? ALEdge.right : ALEdge.left, of: self.drinksContainer ?? self.contentView)
        self.foodContainer.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self.contentView)
        
        self.foodContainer.autoMatch(ALDimension.width, to: ALDimension.width, of: self.placeholderView)
        self.foodContainer!.autoMatch(ALDimension.height, to: ALDimension.height, of: self.placeholderView)
    }
    
    
    func reset() {
        //self.eventsController.reset()
        self.drinksController?.reset()
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
    /*func viewsForSegmentControllerToObserveContentOffsetChange() -> [UIView] {
        if let drinksController = self.drinksController {
            return [self.eventsController.statefulTableView.innerTable, drinksController.statefulTableView.innerTable, self.foodMenuController.statefulTableView.innerTable]
        } else {
            return [self.eventsController.statefulTableView.innerTable, self.foodMenuController.statefulTableView.innerTable]
        }
        
    }*/
}

//MARK: EventsViewControllerDelegate
extension WhatsOnViewController: EventsViewControllerDelegate {
    func eventsViewController(controller: EventsViewController, didSelect event: Event) {
        self.delegate.whatsOnViewController(controller: self, didSelect: event)
    }
}

//MARK: DrinkListViewControllerDelegate
extension WhatsOnViewController: DrinkListViewControllerDelegate {
    func drinkListViewController(controller: DrinkListViewController, didSelect product: Product) {
        self.delegate.whatsOnViewController(controller: self, didSelect: product)
    }
}

//MARK: FoodMenuViewControllerDelegate
extension WhatsOnViewController: FoodMenuViewControllerDelegate {
    func foodMenuViewController(controller: FoodMenuViewController, didSelect product: Product) {
        self.delegate.whatsOnViewController(controller: self, didSelect: product)
    }
}
