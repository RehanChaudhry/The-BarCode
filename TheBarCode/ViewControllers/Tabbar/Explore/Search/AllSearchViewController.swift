//
//  AllSearchViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 19/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import GoogleMaps
import ObjectMapper
import CoreStore
import Alamofire

protocol AllSearchViewControllerDelegate: class {
    func allSearchViewController(controller: AllSearchViewController, viewMoreButtonTapped type: AllSearchItemType)
}

class AllSearchViewController: BaseSearchScopeViewController {
    
    var viewModels: [AllSearchViewModelItem] = []
    
    weak var allSearchDelegate: AllSearchViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(headerFooterViewType: AllSearchExtendedFooterView.self)
        self.statefulTableView.innerTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.statefulTableView.frame.size.width, height: 0.01))
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: DealTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: FoodMenuCell.self)
        self.statefulTableView.innerTable.register(cellType: FoodBarCell.self)
        self.statefulTableView.innerTable.register(cellType: EventCell.self)
        self.statefulTableView.innerTable.register(headerFooterViewType: AllSearchHeaderView.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
        
    }
    
    override func prepareToReset() {
        super.prepareToReset()
        
        self.dataRequest?.cancel()
        self.resetCurrentData()
    }
    
    override func reset() {
        super.reset()
        
        self.prepareToReset()
        self.statefulTableView.triggerInitialLoad()
    }
    
    override func resetCurrentData() {
        super.resetCurrentData()
        
        self.viewModels.removeAll()
        self.statefulTableView.innerTable.reloadData()
    }
    
    func mapBars(results: [[String : Any]], mappingType: ExploreMappingType) -> [Bar] {
        
        var fetchedBars: [Bar] = []
        for result in results {
            var bars: [Bar] = []
            var mutableResult = result
            mutableResult["mapping_type"] = mappingType.rawValue
            try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                let bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableResult)
                bars.append(bar!)
            })
            
            for bar in bars {
                let fetchedBar = Utility.inMemoryStack.fetchExisting(bar)
                fetchedBars.append(fetchedBar!)
                debugPrint("fetched bar title: \(fetchedBar!.title.value)")
            }
        }
        
        return fetchedBars
    }
    
    override func setUpMapViewForLocations() {
        
        super.setUpMapViewForLocations()
        
        self.mapErrorView.isHidden = true
        self.mapApiState.isLoading = true
        
        self.getBarsForMap { (error) in
            
            self.mapApiState.isLoading = false
            
            guard error == nil else {
                debugPrint("Error while getting basic map bars: \(error!)")
                self.mapErrorView.isHidden = false
                return
            }
            
            self.mapErrorView.isHidden = true
            self.setUpMarkers()
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension AllSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollDidScroll(scrollView: scrollView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let viewModel = self.viewModels[section]
        let footerModel = viewModel.footerModel
        if !footerModel.shouldShowViewMoreButon &&
            !footerModel.shouldShowSeparator &&
            !footerModel.shouldShowExpandButton {
            return 0.0
        } else {
            return UITableViewAutomaticDimension
        }
//        switch viewModel.footerType {
//        case .singleLine:
//            return 12.0
//        case .viewMore, .expandableWithoutViewMoreWithOutSeparator, .expandableWithoutViewMoreWithSeparator:
//            return 46.0
//        case .expandableWithViewMore:
//            return 75.0
//        case .none:
//            return 0.0
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = self.viewModels[section].sectionTitle {
            return UITableViewAutomaticDimension
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewModel = self.viewModels[section]
        if let title = viewModel.sectionTitle {
            let headerView = self.statefulTableView.innerTable.dequeueReusableHeaderFooterView(AllSearchHeaderView.self)
            headerView?.setup(title: title, strokeColor: viewModel.headerStrokeColor)
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let viewModel = self.viewModels[section]
        let footerModel = viewModel.footerModel
        if !footerModel.shouldShowViewMoreButon &&
            !footerModel.shouldShowSeparator &&
            !footerModel.shouldShowExpandButton {
            return nil
        } else {
            let footerView = self.statefulTableView.innerTable.dequeueReusableHeaderFooterView(AllSearchExtendedFooterView.self)
            footerView?.section = section
            footerView?.delegate = self
            
            if let foodViewModel = viewModel as? AllSearchViewModelTypeFood {
                footerView?.setupFooterView(model: footerModel, isExpanded: foodViewModel.isExpanded)
            } else if let drinkViewModel = viewModel as? AllSearchViewModelTypeDrink {
                footerView?.setupFooterView(model: footerModel, isExpanded: drinkViewModel.isExpanded)
            } else {
                footerView?.setupFooterView(model: footerModel, isExpanded: true)
            }

            return footerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = self.viewModels[indexPath.section]
        if let model = viewModel as? AllSearchViewModelTypeBar, viewModel.type == .bar {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
            cell.setUpCell(bar: model.items[indexPath.row])
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let model = viewModel as? AllSearchViewModelTypeDeal, viewModel.type == .deal {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: DealTableViewCell.self)
            cell.setUpCell(explore: model.items[indexPath.row])
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let model = viewModel as? AllSearchViewModelTypeLiveOffer, viewModel.type == .liveOffer {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
            cell.setUpCell(explore: model.items[indexPath.row])
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let model = viewModel as? AllSearchViewModelTypeFood, viewModel.type == .food {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
            cell.setupCellForFood(food: model.items[indexPath.row])
            return cell
        } else if let model = viewModel as? AllSearchViewModelTypeDrink, viewModel.type == .drink {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
            cell.setupCellForDrink(drink: model.items[indexPath.row])
            return cell
        } else if let model = viewModel as? AllSearchViewModelTypeEvent, viewModel.type == .event {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: EventCell.self)
            
            let event = model.items[indexPath.row]
            cell.setupCell(event: event, barName: event.bar.value?.title.value)
            
            return cell
        } else if let model = viewModel as? AllSearchViewModelTypeFoodBar, viewModel.type == .foodBar {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodBarCell.self)
            cell.setUpCell(explore: model.items[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            return UITableViewCell(frame: .zero)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let viewModel = self.viewModels[indexPath.section]
        if let aCell = cell as? BarTableViewCell, let model = viewModel as? AllSearchViewModelTypeBar, viewModel.type == .bar {
            
            aCell.scrollToCurrentImage()
            
            let bar = model.items[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
        } else if let aCell = cell as? DealTableViewCell, let model = viewModel as? AllSearchViewModelTypeDeal, viewModel.type == .deal {
            
            aCell.scrollToCurrentImage()
            
            let bar = model.items[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? LiveOfferTableViewCell, let model = viewModel as? AllSearchViewModelTypeLiveOffer, viewModel.type == .liveOffer {
            
            aCell.scrollToCurrentImage()
            
            let bar = model.items[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? FoodBarCell, let model = viewModel as? AllSearchViewModelTypeFoodBar, viewModel.type == .foodBar {
            
            aCell.scrollToCurrentImage()
            
            let bar = model.items[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? EventCell, let model = viewModel as? AllSearchViewModelTypeEvent, viewModel.type == .event {
            aCell.startTimer(event: model.items[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        } else if let aCell = cell as? DealTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        } else if let aCell = cell as? LiveOfferTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        } else if let aCell = cell as? FoodBarCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        } else if let aCell = cell as? EventCell {
            aCell.stopTimer()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.handleItemSelection(indexPath: indexPath)
    }
    
    func handleItemSelection(indexPath: IndexPath) {
        let viewModel = self.viewModels[indexPath.section]
        if let model = viewModel as? AllSearchViewModelTypeBar, viewModel.type == .bar {
            self.moveToBarDetails(barId: model.items[indexPath.row].id.value, scopeType: .bar)
        } else if let model = viewModel as? AllSearchViewModelTypeDeal, viewModel.type == .deal {
            self.moveToBarDetails(barId: model.items[indexPath.row].id.value, scopeType: .deal)
        } else if let model = viewModel as? AllSearchViewModelTypeLiveOffer, viewModel.type == .liveOffer {
            self.moveToBarDetails(barId: model.items[indexPath.row].id.value, scopeType: .liveOffer)
        } else if let model = viewModel as? AllSearchViewModelTypeFoodBar, viewModel.type == .foodBar {
            self.moveToBarDetails(barId: model.items[indexPath.row].id.value, scopeType: .bar)
        } else if let model = viewModel as? AllSearchViewModelTypeEvent, viewModel.type == .event {
            self.moveToBarDetails(barId: model.items[indexPath.row].bar.value!.id.value, scopeType: .event)
        } else if let model = viewModel as? AllSearchViewModelTypeFood, viewModel.type == .food {
            self.moveToBarDetails(barId: model.items[indexPath.row].establishmentId.value, scopeType: .food)
        } else if let model = viewModel as? AllSearchViewModelTypeDrink, viewModel.type == .drink {
            self.moveToBarDetails(barId: model.items[indexPath.row].establishmentId.value, scopeType: .drink)
        }
    }
}

//MARK: AllSearchExtendedFooterViewDelegate
extension AllSearchViewController: AllSearchExtendedFooterViewDelegate {
    func allSearchExtendedFooterView(footerView: AllSearchExtendedFooterView, viewMoreButtonTapped sender: UIButton) {
        let itemType = self.viewModels[footerView.section].type
        self.allSearchDelegate.allSearchViewController(controller: self, viewMoreButtonTapped: itemType)
    }
    
    func allSearchExtendedFooterView(footerView: AllSearchExtendedFooterView, expandableButtonTapped sender: UIButton) {
        let viewModel = self.viewModels[footerView.section]
        let itemType = viewModel.type
        guard itemType == .drink || itemType == .food else {
            debugPrint("Item does not support expandable")
            return
        }
        
        if let drinkViewModel = viewModel as? AllSearchViewModelTypeDrink {
            drinkViewModel.isExpanded = !drinkViewModel.isExpanded
            self.statefulTableView.innerTable.reloadData()
        } else if let foodViewModel = viewModel as? AllSearchViewModelTypeFood {
            foodViewModel.isExpanded = !foodViewModel.isExpanded
            self.statefulTableView.innerTable.reloadData()
        } else {
            debugPrint("isExpanded property does not exists")
        }
    }
}

//MARK: AllSearchFooterViewDelegate
extension AllSearchViewController: AllSearchFooterViewDelegate {
    func allSearchFooterView(footerView: AllSearchFooterView, viewMoreButtonTapped sender: UIButton) {
        self.allSearchDelegate.allSearchViewController(controller: self, viewMoreButtonTapped: footerView.type)
    }
}

//MARK: ExploreBaseTableViewCellDelegate
extension AllSearchViewController: ExploreBaseTableViewCellDelegate {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        self.handleItemSelection(indexPath: tableCellIndexPath)
        
    }
}

//MARK: FoodBarCellDelegate
extension AllSearchViewController: FoodBarCellDelegate {
    func foodBarCell(cell: FoodBarCell, didSelectPagerItemAt indexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.indexPathForCell(cell) else {
            debugPrint("IndexPath not found")
            return
        }
        
        let viewModel = self.viewModels[tableCellIndexPath.section]
        if let model = viewModel as? AllSearchViewModelTypeFoodBar, viewModel.type == .foodBar {
            self.moveToBarDetails(barId: model.items[tableCellIndexPath.row].id.value, scopeType: .bar)
        }
    }
}

//MARK: BarTableViewCellDelegare
extension AllSearchViewController: BarTableViewCellDelegare {
    
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        if let viewModel = self.viewModels[indexPath.section] as? AllSearchViewModelTypeBar {
            let bar = viewModel.items[indexPath.row]
            markFavourite(bar: bar, cell: cell)
        }
        
    }
    
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        if let viewModel = self.viewModels[indexPath.section] as? AllSearchViewModelTypeBar {
            let bar = viewModel.items[indexPath.row]
            self.showDirection(bar: bar)
        }
    }
}

//MARK: DealTableViewCellDelegate
extension AllSearchViewController: DealTableViewCellDelegate {
    func dealTableViewCell(cell: DealTableViewCell, distanceButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        if let viewModel = self.viewModels[indexPath.section] as? AllSearchViewModelTypeDeal {
            let bar = viewModel.items[indexPath.row]
            self.showDirection(bar: bar)
        }
    }
    
    func dealTableViewCell(cell: DealTableViewCell, bookmarkButtonTapped sender: UIButton) {
        
    }
}

//MARK: LiveOfferTableViewCellDelegate
extension AllSearchViewController: LiveOfferTableViewCellDelegate {
    
    func liveOfferCell(cell: LiveOfferTableViewCell, bookmarButtonTapped sender: UIButton) {
        
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, shareButtonTapped sender: UIButton) {
        
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, distanceButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        if let viewModel = self.viewModels[indexPath.section] as? AllSearchViewModelTypeLiveOffer {
            let bar = viewModel.items[indexPath.row]
            self.showDirection(bar: bar)
        }
    }
}

//MARK: Webservices Methods
extension AllSearchViewController {
    
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.dataRequest?.cancel()
        
        var params:[String : Any] =  ["pagination" : false,
                                      "keyword" : self.keyword]
        
        if self.selectedPreferences.count > 0 {
            let ids = self.selectedPreferences.map({$0.id.value})
            params["interest_ids"] = ids
        }
        
        if self.selectedStandardOffers.count > 0 {
            let ids = self.selectedStandardOffers.map({$0.id.value})
            params["tier_ids"] = ids
        }
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathSearchAll, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                for (responseIndex, responseDict) in responseArray.enumerated() {
                    let title = responseDict["title"] as? String
                    let type = "\(responseDict["type"]!)"
                    let results = responseDict["results"] as? [[String : Any]] ?? []
                    let isResultsComplete = responseDict["is_results_complete"] as? Bool ?? true
                    let hasMore = !isResultsComplete
                    if type == "1" {
                        let bars = self.mapBars(results: results, mappingType: .bars)
                        let shouldShowSeparator = responseIndex == responseArray.count - 1 ? false : true
                        
                        let footerModel = AllSearchFooterViewModel(shouldShowSeparator: shouldShowSeparator, shouldShowExpandButton: false, shouldShowViewMoreButon: hasMore, footerStrokeColor: .appSearchScopeYellowColor())
                        let viewModel = AllSearchViewModelTypeBar(sectionTitle: title, items: bars, footerModel: footerModel)
                        self.viewModels.append(viewModel)
                        
                    } else if type == "2" {
                        let bars = self.mapBars(results: results, mappingType: .deals)
                        let shouldShowSeparator = responseIndex == responseArray.count - 1 ? false : true
                        
                        let footerModel = AllSearchFooterViewModel(shouldShowSeparator: shouldShowSeparator, shouldShowExpandButton: false, shouldShowViewMoreButon: hasMore, footerStrokeColor: .appSearchScopeOrangeColor())
                        let viewModel = AllSearchViewModelTypeDeal(sectionTitle: title, items: bars, footerModel: footerModel)
                        self.viewModels.append(viewModel)
                        
                    } else if type == "3" {
                        let bars = self.mapBars(results: results, mappingType: .liveOffers)
                        let shouldShowSeparator = responseIndex == responseArray.count - 1 ? false : true
                        
                        let footerModel = AllSearchFooterViewModel(shouldShowSeparator: shouldShowSeparator, shouldShowExpandButton: false, shouldShowViewMoreButon: hasMore, footerStrokeColor: .appSearchScopeBlueColor())
                        let viewModel = AllSearchViewModelTypeLiveOffer(sectionTitle: title, items: bars, footerModel: footerModel)
                        self.viewModels.append(viewModel)
                        
                    } else if type == "4" {
                        
                        for (index, result) in results.enumerated() {
                            var bar: Bar!
                            var foods: [Food] = []
                            try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                                
                                var mutableBarDict = result
                                mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                                bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                                
                                let foodsArray = result["menus"] as? [[String : Any]] ?? []
                                foods = try! transaction.importUniqueObjects(Into<Food>(), sourceArray: foodsArray)
                            })
                            
                            let fetchedBar = Utility.inMemoryStack.fetchExisting(bar)!
                            
                            let sectionTitle = index == 0 ? title : nil
                            
                            let footerModel = AllSearchFooterViewModel(shouldShowSeparator: false, shouldShowExpandButton: false, shouldShowViewMoreButon: false, footerStrokeColor: .clear)
                            
                            let barViewModel = AllSearchViewModelTypeFoodBar(sectionTitle: sectionTitle, items: [fetchedBar], footerModel: footerModel, isDrink: false)
                            self.viewModels.append(barViewModel)
                            
                            var fetchedFoods: [Food] = []
                            for food in foods {
                                let fetchedFood  = Utility.inMemoryStack.fetchExisting(food)
                                fetchedFoods.append(fetchedFood!)
                            }
                            
                            let hasSeparator: Bool
                            let isExpandable: Bool = foods.count > 3
                            let hasViewMore: Bool = hasMore && index == results.count - 1
                            if index == results.count - 1 {
                                hasSeparator = responseIndex == responseArray.count - 1 ? false : true
                            } else {
                                hasSeparator = false
                            }
                            
                            let footerInfo = AllSearchFooterViewModel(shouldShowSeparator: hasSeparator, shouldShowExpandButton: isExpandable, shouldShowViewMoreButon: hasViewMore, footerStrokeColor: .appSearchScopePurpleColor())
                            
                            let foodsViewModel = AllSearchViewModelTypeFood(sectionTitle: nil, items: fetchedFoods, footerModel: footerInfo)
                            self.viewModels.append(foodsViewModel)
                        }
                        
                    } else if type == "5" {
                        
                        for (index, result) in results.enumerated() {
                            var bar: Bar!
                            var drinks: [Drink] = []
                            try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                                
                                var mutableBarDict = result
                                mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                                bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                                
                                let drinksArray = result["menus"] as? [[String : Any]] ?? []
                                drinks = try! transaction.importUniqueObjects(Into<Drink>(), sourceArray: drinksArray)
                            })
                            
                            let fetchedBar = Utility.inMemoryStack.fetchExisting(bar)!
                            
                            let sectionTitle = index == 0 ? title : nil
                            
                            let footerModel = AllSearchFooterViewModel(shouldShowSeparator: false, shouldShowExpandButton: false, shouldShowViewMoreButon: false, footerStrokeColor: .clear)
                            let barViewModel = AllSearchViewModelTypeFoodBar(sectionTitle: sectionTitle, items: [fetchedBar], footerModel: footerModel, isDrink: true)
                            self.viewModels.append(barViewModel)
                            
                            var fetchedDrinks: [Drink] = []
                            for drink in drinks {
                                let fetchedDrink  = Utility.inMemoryStack.fetchExisting(drink)
                                fetchedDrinks.append(fetchedDrink!)
                            }
                            
                            let hasSeparator: Bool
                            let isExpandable: Bool = drinks.count > 3
                            let hasViewMore: Bool = hasMore && index == results.count - 1
                            if index == results.count - 1 {
                                hasSeparator = responseIndex == responseArray.count - 1 ? false : true
                            } else {
                                hasSeparator = false
                            }
                            
                            let footerInfo = AllSearchFooterViewModel(shouldShowSeparator: hasSeparator, shouldShowExpandButton: isExpandable, shouldShowViewMoreButon: hasViewMore, footerStrokeColor: .appSearchScopePinkColor())
                            let drinksViewModel = AllSearchViewModelTypeDrink(sectionTitle: nil, items: fetchedDrinks, footerModel: footerInfo)
                            self.viewModels.append(drinksViewModel)
                        }
                        
                    } else if type == "6" {
                        
                        var importedObjects: [Event] = []
                        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                            let objects = try! transaction.importUniqueObjects(Into<Event>(), sourceArray: results)
                            importedObjects.append(contentsOf: objects)
                        })
                        
                        var fetchedEvents: [Event] = []
                        for object in importedObjects {
                            let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                            fetchedEvents.append(fetchedObject!)
                        }
                        
                        let shouldShowSeparator = responseIndex == responseArray.count - 1 ? false : true
                        
                        let footerModel = AllSearchFooterViewModel(shouldShowSeparator: shouldShowSeparator, shouldShowExpandButton: false, shouldShowViewMoreButon: hasMore, footerStrokeColor: .appSearchScopeGreenColor())
                        let eventsViewModel = AllSearchViewModelTypeEvent(sectionTitle: title, items: fetchedEvents, footerModel: footerModel)
                        self.viewModels.append(eventsViewModel)
                    }
                    
                    
                    
                }
                    
                
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.innerTable.reloadData()
                self.setUpMarkers()
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func getBarsForMap(completion: @escaping (_ error: NSError?) -> Void) {
        
        var params:[String : Any] =  ["pagination" : false,
                                      "is_for_map" : true,
                                      "keyword" : self.keyword]
        
        if self.selectedPreferences.count > 0 {
            let ids = self.selectedPreferences.map({$0.id.value})
            params["interest_ids"] = ids
        }
        
        if self.selectedStandardOffers.count > 0 {
            let ids = self.selectedStandardOffers.map({$0.id.value})
            params["tier_ids"] = ids
        }
        
        self.mapApiState.isLoading = true
        
        self.mapDataRequest?.cancel()
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathSearchAll, method: .get) { (response, serverError, error) in
            
            self.mapApiState.isLoading = false
            
            guard error == nil else {
                self.mapApiState.error = error! as NSError
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                self.mapApiState.error = serverError!.nsError()
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                self.mapBars.removeAll()
                
                var responseBars: [[String : Any]] = []
                for responseDict in responseArray {

                    let type = "\(responseDict["type"]!)"
                    let results = responseDict["results"] as? [[String : Any]] ?? []
                    
                    if type == "1" || type == "2" || type == "3" || type == "4" || type == "5" {
                        responseBars.append(contentsOf: results)
                    } else if type == "6" {
                        let barsArray = results.compactMap({$0["establishment"] as? [String : Any]})
                        responseBars.append(contentsOf: barsArray)
                    }
                }
                
                let mapBars = Mapper<MapBasicBar>().mapArray(JSONArray: responseBars)
                self.mapBars.append(contentsOf: mapBars)
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func markFavourite(bar: Bar, cell: BarTableViewCell) {
        
        debugPrint("isFav == \(bar.isUserFavourite.value)")
        
        let params:[String : Any] = ["establishment_id": bar.id.value,
                                     "is_favorite" : !(bar.isUserFavourite.value)]
        
        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
            if let bars = transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value)) {
                for bar in bars {
                    bar.isUserFavourite.value = !bar.isUserFavourite.value
                }
            }
        })
        
        cell.setUpCell(bar: bar)
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiUpdateFavorite, method: .put) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error == \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror == \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let response = response as! [String : Any]
            let responseDict = response["response"] as! [String : Any]
            
            if let responseID = (responseDict["data"] as? Int) {
                debugPrint("responseID == \(responseID)")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
            
            if bar.isUserFavourite.value {
                NotificationCenter.default.post(name: notificationNameBarFavouriteAdded, object: bar)
            } else {
                NotificationCenter.default.post(name: notificationNameBarFavouriteRemoved, object: bar)
            }
        }
    }
}

//MARK: StatefulTableDelegate
extension AllSearchViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        self.resetCurrentData()
        self.getBars(isRefreshing: false) {  [unowned self] (error) in
            handler(self.viewModels.count == 0, error)
        }
        
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.getBars(isRefreshing: false) { (error) in
            handler(false, error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.refreshSnackBar()
        self.getBars(isRefreshing: true) { [unowned self] (error) in
            handler(self.viewModels.count == 0, error)
        }
    }
    
    func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
        let initialErrorView = LoadingAndErrorView.loadFromNib()
        initialErrorView.backgroundColor = .clear
        initialErrorView.showLoading()
        return initialErrorView
    }
    
    func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
        if forInitialLoadError == nil {
            let title = "Searching for something specific, why not type what you’re looking for in the search bar?"
            let subTitle = "Tap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = .clear
            initialErrorView.showErrorViewWithRetry(errorMessage: forInitialLoadError!.localizedDescription, reloadMessage: "Tap to refresh")
            
            initialErrorView.retryHandler = {(sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return initialErrorView
        }
    }
    
    func statefulTableViewLoadMoreErrorView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView? {
        let loadingView = LoadingAndErrorView.loadFromNib()
        loadingView.showErrorView(canRetry: true)
        loadingView.backgroundColor = .clear
        
        if forLoadMoreError == nil {
            loadingView.showLoading()
        } else {
            loadingView.showErrorViewWithRetry(errorMessage: forLoadMoreError!.localizedDescription, reloadMessage: "Tap to refresh")
        }
        
        loadingView.retryHandler = {(sender: UIButton) in
            tvc.triggerLoadMore()
        }
        
        return loadingView
    }
}
