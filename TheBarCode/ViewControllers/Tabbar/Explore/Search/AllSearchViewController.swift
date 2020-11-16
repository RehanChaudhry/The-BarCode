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
import KVNProgress

protocol AllSearchViewControllerDelegate: class {
    func allSearchViewController(controller: AllSearchViewController, viewMoreButtonTapped type: AllSearchItemType)
}

class AllSearchViewController: BaseSearchScopeViewController {
    
    var viewModels: [AllSearchSectionViewModel] = []
    
    weak var allSearchDelegate: AllSearchViewControllerDelegate!
    
    var loadingShareController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(foodCartUpdatedNotification(notification:)), name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(drinkCartUpdatedNotification(notification:)), name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameMyCartUpdated, object: nil)
    }
    
    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.statefulTableView.frame.size.width, height: 0.01))
        
        self.statefulTableView.innerTable.register(cellType: AllSearchHeaderCell.self)
        self.statefulTableView.innerTable.register(cellType: AllSearchFooterCell.self)
        self.statefulTableView.innerTable.register(cellType: AllSearchViewMoreCell.self)
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
        self.statefulTableView.state = .idle
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
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableResult)
                bars.append(bar!)
            })
            
            for bar in bars {
                let fetchedBar = Utility.barCodeDataStack.fetchExisting(bar)
                fetchedBars.append(fetchedBar!)
                debugPrint("fetched bar title: \(fetchedBar!.title.value)")
            }
        }
        
        return fetchedBars
    }
    
    override func setUpMapViewForLocations() {
        
        super.setUpMapViewForLocations()
        
        self.mapErrorView.isHidden = true
        self.mapLoadingIndicator.startAnimating()
        self.mapReloadButton.isHidden = true
        
        self.getBarsForMap { (error) in
            
            self.mapLoadingIndicator.stopAnimating()
            self.mapReloadButton.isHidden = false
            
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
        let viewModel = self.viewModels[section]
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewModel = self.viewModels[section]
        
        let headerView = self.statefulTableView.innerTable.dequeueReusableHeaderFooterView(AllSearchHeaderView.self)
        headerView?.setup(strokeColor: viewModel.headerStrokeColor)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.item]
        
        if let item = viewModelItem as? AllSearchHeaderModel, item.type == .headerCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: AllSearchHeaderCell.self)
            cell.setup(title: item.title, strokeColor: viewModel.headerStrokeColor)
            return cell
        } else if let item = viewModelItem as? AllSearchBarModel, item.type == .barCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
            cell.setUpCell(bar: item.bar, bottomPadding: indexPath.row == viewModel.items.count - 1)
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchBarModel, item.type == .deliveryBarCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
            cell.setUpCell(bar: item.bar, bottomPadding: indexPath.row == viewModel.items.count - 1, showDeliveryRadius: true)
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchBarModel, item.type == .dealCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: DealTableViewCell.self)
            cell.setUpCell(explore: item.bar)
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchBarModel, item.type == .liveOfferCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
            cell.setUpCell(explore: item.bar)
            cell.updateBottomPadding(showPadding: indexPath.row == viewModel.items.count - 1)
            cell.delegate = self
            cell.exploreBaseDelegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchEventModel, item.type == .eventCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: EventCell.self)
            
            let event = item.event
            cell.setupCell(event: event, barName: event.bar.value?.title.value)
            cell.eventCellDelegate = self
            
            return cell
        } else if let item = viewModelItem as? AllSearchBarModel, item.type == .foodBarCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodBarCell.self)
            cell.setUpCell(explore: item.bar)
            cell.delegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchBarModel, item.type == .drinkBarCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodBarCell.self)
            cell.setUpCell(explore: item.bar)
            cell.delegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchFoodModel, item.type == .foodCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
            cell.setupCellForFood(food: item.food, isInAppPaymentOn: item.isInAppPaymentOn)
            cell.delegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchDrinkModel, item.type == .drinkCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
            cell.setupCellForDrink(drink: item.drink, isInAppPaymentOn: item.isInAppPaymentOn)
            cell.delegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchExpandModel, item.type == .footerCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: AllSearchFooterCell.self)
            cell.setupCell(isExpanded: item.isExpanded)
            cell.delegate = self
            return cell
        } else if let item = viewModelItem as? AllSearchViewMoreModel, item.type == .viewMoreCell {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: AllSearchViewMoreCell.self)
            cell.delegate = self
            cell.setup(model: item)
            return cell
        }

        return UITableViewCell(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.row]
        
        if let aCell = cell as? BarTableViewCell,
            let item = viewModelItem as? AllSearchBarModel,
            item.type == .barCell {
            
            aCell.scrollToCurrentImage()
            let imageCount = item.bar.images.value.count
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? BarTableViewCell,
            let item = viewModelItem as? AllSearchBarModel,
            item.type == .deliveryBarCell {
            
            aCell.scrollToCurrentImage()
            let imageCount = item.bar.images.value.count
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? DealTableViewCell,
            let item = viewModelItem as? AllSearchBarModel,
            item.type == .dealCell {
            
            aCell.scrollToCurrentImage()
            let imageCount = item.bar.images.value.count
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? LiveOfferTableViewCell,
            let item = viewModelItem as? AllSearchBarModel,
            item.type == .liveOfferCell {
            
            aCell.scrollToCurrentImage()
            let imageCount = item.bar.images.value.count
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
            
        } else if let aCell = cell as? EventCell,
            let item = viewModelItem as? AllSearchEventModel,
            item.type == .eventCell {
            
            aCell.startTimer(event:item.event)
            
        } else if let aCell = cell as? FoodBarCell,
            let item = viewModelItem as? AllSearchBarModel {
            
            aCell.scrollToCurrentImage()
            
            let bar = item.bar
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
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
        if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel, viewModelItem.type == .barCell {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .bar)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel, viewModelItem.type == .deliveryBarCell {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .delivery)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel, viewModelItem.type == .dealCell {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .deal)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel, viewModelItem.type == .liveOfferCell {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .liveOffer)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel, viewModelItem.type == .foodBarCell {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .bar)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel, viewModelItem.type == .drinkBarCell {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .bar)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchFoodModel, viewModelItem.type == .foodCell {
            self.moveToBarDetails(barId: viewModelItem.food.establishmentId.value, scopeType: .food)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchDrinkModel, viewModelItem.type == .drinkCell {
            self.moveToBarDetails(barId: viewModelItem.drink.establishmentId.value, scopeType: .drink)
        } else if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchEventModel, viewModelItem.type == .eventCell {
            self.moveToBarDetails(barId: viewModelItem.event.bar.value!.id.value, scopeType: .event)
        }
    }
}

//MARK: FoodMenuCellDelegate
extension AllSearchViewController: FoodMenuCellDelegate {
    func foodMenuCell(cell: FoodMenuCell, removeFromCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.item]
        
        if let item = viewModelItem as? AllSearchDrinkModel, item.type == .drinkCell {
            self.updateDrinkCart(drink: item.drink, barId: item.barId, shouldAdd: false)
        } else if let item = viewModelItem as? AllSearchFoodModel, item.type == .foodCell {
            self.updateFoodCart(food: item.food, barId: item.barId, shouldAdd: false)
        }
    }
    
    func foodMenuCell(cell: FoodMenuCell, addToCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.item]
        
        if let item = viewModelItem as? AllSearchDrinkModel, item.type == .drinkCell {
            self.updateDrinkCart(drink: item.drink, barId: item.barId, shouldAdd: true)
        } else if let item = viewModelItem as? AllSearchFoodModel, item.type == .foodCell {
            self.updateFoodCart(food: item.food, barId: item.barId, shouldAdd: true)
        }
    }
}

//MARK: AllSearchViewMoreCellDelegate
extension AllSearchViewController: AllSearchViewMoreCellDelegate {
    func allSearchViewMoreCell(cell: AllSearchViewMoreCell, viewMoreButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let itemType = self.viewModels[indexPath.section].type
        self.allSearchDelegate.allSearchViewController(controller: self, viewMoreButtonTapped: itemType)
    }
}

//MARK: AllSearchFooterCellDelegate
extension AllSearchViewController: AllSearchFooterCellDelegate {
    
    func allSearchFooterCell(cell: AllSearchFooterCell, expandButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        guard let viewModel = self.viewModels[indexPath.section] as? AllSearchViewModel,
            let viewModelItem = viewModel.items[indexPath.row] as? AllSearchExpandModel else {
                debugPrint("Unsupported type")
                return
        }
        
        if viewModelItem.isExpanded {
            viewModel.items.removeAll { (item) -> Bool in
                return viewModelItem.expandableItems.contains(where: { (expandableItem) -> Bool in
                    return expandableItem === item
                })
            }
            viewModelItem.isExpanded = false
        } else {
            viewModel.items.insert(contentsOf: viewModelItem.expandableItems, at: indexPath.row)
            viewModelItem.isExpanded = true
        }

        self.statefulTableView.innerTable.reloadData()
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
        if let viewModelItem = viewModel.items[tableCellIndexPath.row] as? AllSearchBarModel {
            self.moveToBarDetails(barId: viewModelItem.bar.id.value, scopeType: .bar)
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
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.row]
        
        if let barModel = viewModelItem as? AllSearchBarModel {
            markFavourite(bar: barModel.bar, cell: cell)
        }
    }
    
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.row]
        
        if let barModel = viewModelItem as? AllSearchBarModel {
            self.showDirection(bar: barModel.bar)
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
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.row]
        
        if let barModel = viewModelItem as? AllSearchBarModel {
            self.showDirection(bar: barModel.bar)
        }
    }
    
    func dealTableViewCell(cell: DealTableViewCell, bookmarkButtonTapped sender: UIButton) {
        
    }
    
    func dealTableViewCell(cell: DealTableViewCell, shareButtonTapped sender: UIButton) {
        
    }
}

//MARK: EventCellDelegate
extension AllSearchViewController: EventCellDelegate {
    func eventCell(cell: EventCell, bookmarkButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.row]
        
        if let eventViewModel = viewModelItem as? AllSearchEventModel {
            let event = eventViewModel.event
            self.updateBookmarkStatus(event: event, isBookmarked: !event.isBookmarked.value)
        }
    }
    
    func eventCell(cell: EventCell, shareButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        let viewModel = self.viewModels[indexPath.section]
        let viewModelItem = viewModel.items[indexPath.row]
        
        if let eventViewModel = viewModelItem as? AllSearchEventModel {
            let event = eventViewModel.event
            event.showSharingLoader = true
            self.statefulTableView.innerTable.reloadData()
            
            Utility.shared.generateAndShareDynamicLink(event: event, controller: self, presentationCompletion: {
                event.showSharingLoader = false
                self.statefulTableView.innerTable.reloadData()
                self.loadingShareController = false
            }) {
                
            }
            
        }
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
        
        let viewModel = self.viewModels[indexPath.section]
        if let viewModelItem = viewModel.items[indexPath.row] as? AllSearchBarModel {
            self.showDirection(bar: viewModelItem.bar)
        }
    }
}

//MARK: Webservices Methods
extension AllSearchViewController {
    
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.dataRequest?.cancel()
        
        var params:[String : Any] =  ["pagination" : false,
                                      "is_for_map" : false,
                                      "keyword" : self.keyword]
        
        if self.selectedPreferences.count > 0 {
            let ids = self.selectedPreferences.map({$0.id.value})
            params["interest_ids"] = ids
        }
        
        if self.selectedStandardOffers.count > 0 {
            let ids = self.selectedStandardOffers.map({$0.id.value})
            params["tier_ids"] = ids
        }
        
        if let _ = self.selectedDeliveryFilter {
            params["is_delivering"] = true
        }
        
        if let selectedRedeemingType = self.selectedRedeemingType {
            if selectedRedeemingType.type == .unlimited {
                params["is_unlimited_redemption"] = true
            } else if selectedRedeemingType.type == .limited {
                params["is_unlimited_redemption"] = false
            }
        }
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathSearchAll, method: .get) { (response, serverError, error) in
            
            defer {
                self.statefulTableView.innerTable.reloadData()
            }
            self.viewModels.removeAll()
            
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
                    
//                    let title = responseDict["title"] as? String ?? ""
                    let type = "\(responseDict["type"]!)"
                    let results = responseDict["results"] as? [[String : Any]] ?? []
                    let isResultsComplete = responseDict["is_results_complete"] as? Bool ?? true
                    let hasMore = !isResultsComplete
                    if type == "1" {
                        let bars = self.mapBars(results: results, mappingType: .bars)

                        let scopeItem = SearchScope.bar.item()
                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
                        var items: [AllSearchSectionViewModelItem] = [headerItem]
                        
                        let searchBarModels = bars.map({ AllSearchBarModel(type: .barCell, bar: $0) })
                        items.append(contentsOf: searchBarModels)
                        
                        if hasMore {
                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeBarsColor())
                            items.append(viewMoreModel)
                        }
                        
                        let viewModel = AllSearchViewModel(type: .bar,
                                                           sectionTitle: scopeItem.title,
                                                           items: items,
                                                           headerStrokeColor: .appSearchScopeBarsColor())
                        self.viewModels.append(viewModel)
                        
                    } else if type == "2" {
                        let bars = self.mapBars(results: results, mappingType: .bars)

                        let scopeItem = SearchScope.delivery.item()
                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
                        var items: [AllSearchSectionViewModelItem] = [headerItem]
                        
                        
                        
                        let searchBarModels = bars.map({ AllSearchBarModel(type: .deliveryBarCell, bar: $0) })
                        items.append(contentsOf: searchBarModels)
                        
                        if hasMore {
                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeDeliveryColor())
                            items.append(viewMoreModel)
                        }
                        
                        let viewModel = AllSearchViewModel(type: .deliveryBars,
                                                           sectionTitle: scopeItem.title,
                                                           items: items,
                                                           headerStrokeColor: .appSearchScopeDeliveryColor())
                        self.viewModels.append(viewModel)
                        
                    } else if type == "3" {
                        let bars = self.mapBars(results: results, mappingType: .deals)
                        
                        let scopeItem = SearchScope.deal.item()
                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
                        var items: [AllSearchSectionViewModelItem] = [headerItem]
                        
                        let searchBarModels = bars.map({ AllSearchBarModel(type: .dealCell, bar: $0) })
                        items.append(contentsOf: searchBarModels)
                        
                        if hasMore {
                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeDealsColor())
                            items.append(viewMoreModel)
                        }
                        
                        let viewModel = AllSearchViewModel(type: .deal,
                                                           sectionTitle: scopeItem.title,
                                                           items: items,
                                                           headerStrokeColor: .appSearchScopeDealsColor())
                        self.viewModels.append(viewModel)
                        
                    }
//                    else if type == "4" {
//                        let bars = self.mapBars(results: results, mappingType: .liveOffers)
//
//                        let scopeItem = SearchScope.liveOffer.item()
//                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
//                        var items: [AllSearchSectionViewModelItem] = [headerItem]
//
//                        let searchBarModels = bars.map({ AllSearchBarModel(type: .liveOfferCell, bar: $0) })
//                        items.append(contentsOf: searchBarModels)
//
//                        if hasMore {
//                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeLiveOffersColor())
//                            items.append(viewMoreModel)
//                        }
//
//                        let viewModel = AllSearchViewModel(type: .liveOffer,
//                                                           sectionTitle: scopeItem.title,
//                                                           items: items,
//                                                           headerStrokeColor: .appSearchScopeLiveOffersColor())
//                        self.viewModels.append(viewModel)
//
//
//                    }
                    else if type == "4" {
                        let scopeItem = SearchScope.food.item()
                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
                        var items: [AllSearchSectionViewModelItem] = [headerItem]
                        
                        for result in results {
                            
                            var bar: Bar!
                            var foods: [Food] = []
                            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                                
                                var mutableBarDict = result
                                mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                                bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                                
                                let foodsArray = result["menus"] as? [[String : Any]] ?? []
                                foods = try! transaction.importUniqueObjects(Into<Food>(), sourceArray: foodsArray)
                            })
                            
                            let fetchedBar = Utility.barCodeDataStack.fetchExisting(bar)!
                            
                            let barModel = AllSearchBarModel(type: .foodBarCell, bar: fetchedBar)
                            items.append(barModel)
                            
                            var fetchedFoods: [Food] = []
                            for food in foods {
                                let fetchedFood  = Utility.barCodeDataStack.fetchExisting(food)
                                fetchedFoods.append(fetchedFood!)
                            }
                            
                            let foodItems = fetchedFoods.map({ AllSearchFoodModel(type: .foodCell,
                                                                                  food: $0,
                                                                                  isInAppPaymentOn: fetchedBar.isInAppPaymentOn.value,
                                                                                  barId: fetchedBar.id.value) })
                            
                            var expandableItems: [AllSearchSectionViewModelItem] = []
                            for (index, foodItem) in foodItems.enumerated() {
                                if index > 2 {
                                    expandableItems.append(foodItem)
                                } else {
                                    items.append(foodItem)
                                }
                            }
                            
                            if expandableItems.count > 0 {
                                let expandModelItem = AllSearchExpandModel(type: .footerCell,
                                                                           isExpanded: false,
                                                                           expandableItems: expandableItems)
                                items.append(expandModelItem)
                            }
                        }
                        
                        if hasMore {
                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeFoodsColor())
                            items.append(viewMoreModel)
                        }
                        
                        let viewModel = AllSearchViewModel(type: .food,
                                                           sectionTitle: scopeItem.title,
                                                           items: items,
                                                           headerStrokeColor: .appSearchScopeFoodsColor())
                        self.viewModels.append(viewModel)
                        
                    } else if type == "5" {
                        
                        let scopeItem = SearchScope.drink.item()
                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
                        var items: [AllSearchSectionViewModelItem] = [headerItem]
                        
                        for result in results {
                            
                            var bar: Bar!
                            var drinks: [Drink] = []
                            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                                
                                var mutableBarDict = result
                                mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                                bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                                
                                let drinksArray = result["menus"] as? [[String : Any]] ?? []
                                drinks = try! transaction.importUniqueObjects(Into<Drink>(), sourceArray: drinksArray)
                            })
                            
                            let fetchedBar = Utility.barCodeDataStack.fetchExisting(bar)!
                            let barModel = AllSearchBarModel(type: .drinkBarCell, bar: fetchedBar)
                            items.append(barModel)
                            
                            var fetchedDrinks: [Drink] = []
                            for drink in drinks {
                                let fetchedDrink  = Utility.barCodeDataStack.fetchExisting(drink)
                                fetchedDrinks.append(fetchedDrink!)
                            }
                            
                            let drinkItems = fetchedDrinks.map({ AllSearchDrinkModel(type: .drinkCell,
                                                                                     drink: $0,
                                                                                     isInAppPaymentOn: fetchedBar.isInAppPaymentOn.value,
                                                                                     barId: fetchedBar.id.value)})
                            
                            var expandableItems: [AllSearchSectionViewModelItem] = []
                            for (index, drinkItem) in drinkItems.enumerated() {
                                if index > 2 {
                                    expandableItems.append(drinkItem)
                                } else {
                                    items.append(drinkItem)
                                }
                            }
                            
                            if expandableItems.count > 0 {
                                let expandModelItem = AllSearchExpandModel(type: .footerCell,
                                                                           isExpanded: false,
                                                                           expandableItems: expandableItems)
                                items.append(expandModelItem)
                            }
                        }
                        
                        if hasMore {
                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeDrinksColor())
                            items.append(viewMoreModel)
                        }
                        
                        let viewModel = AllSearchViewModel(type: .drink,
                                                           sectionTitle: scopeItem.title,
                                                           items: items,
                                                           headerStrokeColor: .appSearchScopeDrinksColor())
                        self.viewModels.append(viewModel)
                        
                    } else if type == "6" {
                        
                        var importedObjects: [Event] = []
                        try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                            let objects = try! transaction.importUniqueObjects(Into<Event>(), sourceArray: results)
                            importedObjects.append(contentsOf: objects)
                        })
                        
                        var fetchedEvents: [Event] = []
                        for object in importedObjects {
                            let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                            fetchedEvents.append(fetchedObject!)
                        }
                        
                        let scopeItem = SearchScope.event.item()
                        let headerItem = AllSearchHeaderModel(title: scopeItem.title)
                        var items: [AllSearchSectionViewModelItem] = [headerItem]
                        
                        let allSearchEvents = fetchedEvents.map({ AllSearchEventModel(event: $0, type: .eventCell) })
                        items.append(contentsOf: allSearchEvents)
                        
                        if hasMore {
                            let viewMoreModel = AllSearchViewMoreModel(footerStrokeColor: .appSearchScopeEventsColor())
                            items.append(viewMoreModel)
                        }
                        
                        let viewModel = AllSearchViewModel(type: .event,
                                                           sectionTitle: scopeItem.title,
                                                           items: items,
                                                           headerStrokeColor: .appSearchScopeEventsColor())
                        self.viewModels.append(viewModel)
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
        
        if let _ = self.selectedDeliveryFilter {
            params["is_delivering"] = true
        }
        
        if let selectedRedeemingType = self.selectedRedeemingType {
            if selectedRedeemingType.type == .unlimited {
                params["is_unlimited_redemption"] = true
            } else if selectedRedeemingType.type == .limited {
                params["is_unlimited_redemption"] = false
            }
        }
        
        self.mapDataRequest?.cancel()
        self.mapApiState.isLoading = true
        
        self.mapDataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathSearchAll, method: .get) { (response, serverError, error) in
            
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
                
                let initialResults: [MapBasicBar] = []
                let uniqueMapBars = mapBars.reduce(initialResults, { (results: [MapBasicBar], mapBasicBar: MapBasicBar) -> [MapBasicBar] in
                    return results.contains(where: { (mapBar: MapBasicBar) -> Bool in
                        return mapBar.barId == mapBasicBar.barId
                    }) ? results : results + [mapBasicBar]
                })
                
                
                self.mapBars.append(contentsOf: uniqueMapBars)
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
        
        try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
            let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value))
            for bar in bars {
                bar.isUserFavourite.value = !bar.isUserFavourite.value
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
    
    func updateBookmarkStatus(event: Event, isBookmarked: Bool) {
        
        guard !event.savingBookmarkStatus else {
            debugPrint("Already saving bookmark status")
            return
        }
        
        event.savingBookmarkStatus = true
        self.statefulTableView.innerTable.reloadData()
        
        let eventId: String = event.id.value
        
        let params: [String : Any] = ["event_id" : eventId,
                                      "is_favorite" : isBookmarked]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddRemoveBookmarkedEvents, method: .put) { (response, serverError, error) in
            
            event.savingBookmarkStatus = false
            
            guard error == nil else {
                self.statefulTableView.innerTable.reloadData()
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while saving bookmark offer status: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                self.statefulTableView.innerTable.reloadData()
                debugPrint("Server error while saving bookmark offer status: \(serverError!.errorMessages())")
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let edittedEvent = transaction.edit(event)
                edittedEvent?.isBookmarked.value = isBookmarked
            })
            
            self.statefulTableView.innerTable.reloadData()
            
            if isBookmarked {
                NotificationCenter.default.post(name: notificationNameEventBookmarked, object: event)
            } else {
                NotificationCenter.default.post(name: notificationNameBookmarkedEventRemoved, object: event)
            }
        }
    }
    
    func updateFoodCart(food: Food, barId: String, shouldAdd: Bool) {
        
        var params: [String : Any] = ["id" : food.id.value,
                                      "establishment_id" : barId]
        if shouldAdd {
            food.isAddingToCart = true
            params["quantity"] = food.quantity.value + 1
        } else {
            food.isRemovingFromCart = true
            params["quantity"] = 0
        }
        
        self.statefulTableView.innerTable.reloadData()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post) { (response, serverError, error) in
            
            let previousQuantity = food.quantity.value
            
            defer {
                food.isAddingToCart = false
                food.isRemovingFromCart = false

                let foodCartInfo: FoodCartUpdatedObject = (food: food, previousQuantity: previousQuantity, barId: barId)
                NotificationCenter.default.post(name: notificationNameFoodCartUpdated, object: foodCartInfo)
            }
            
            guard error == nil else {
                KVNProgress.showError(withStatus: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                KVNProgress.showError(withStatus: serverError!.detail)
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let editedFood = transaction.edit(food)
                editedFood?.quantity.value = shouldAdd ? food.quantity.value + 1 : 0
            })
        }
    }
    
    func updateDrinkCart(drink: Drink, barId: String, shouldAdd: Bool) {
        
        var params: [String : Any] = ["id" : drink.id.value,
                                      "establishment_id" : barId]
        if shouldAdd {
            drink.isAddingToCart = true
            params["quantity"] = drink.quantity.value + 1
        } else {
            drink.isRemovingFromCart = true
            params["quantity"] = 0
        }
        
        self.statefulTableView.innerTable.reloadData()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post) { (response, serverError, error) in
            
            let previousQuantity = drink.quantity.value
            
            defer {
                drink.isAddingToCart = false
                drink.isRemovingFromCart = false

                let drinkCartInfo: DrinkCartUpdatedObject = (drink: drink, previousQuantity: previousQuantity, barId: barId)
                NotificationCenter.default.post(name: notificationNameDrinkCartUpdated, object: drinkCartInfo)
            }
            
            guard error == nil else {
                KVNProgress.showError(withStatus: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                KVNProgress.showError(withStatus: serverError!.detail)
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let editedDrink = transaction.edit(drink)
                editedDrink?.quantity.value = shouldAdd ? drink.quantity.value + 1 : 0
            })
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
        self.setUpMapViewForLocations()
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

//MARK: Notification Methods
extension AllSearchViewController {
    @objc func foodCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
    
    @objc func drinkCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
}
