//
//  StatefulCollectionView+InitialLoad.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulCollectionView {
  // MARK: - Initial load

  /**
   Triggers initial load of data programatically. Defaults to hiding the tableView.

   - returns: Boolean for success status.
   */
  @discardableResult public func triggerInitialLoad() -> Bool {
    return triggerInitialLoad(false)
  }

  /**
   Triggers initial load of data programatically.

   - parameter shouldShowTableView: Control if the container should show the tableView or not.

   - returns: Boolean for success status.
   */
  @discardableResult @objc public func triggerInitialLoad(_ shouldShowTableView: Bool) -> Bool {
    guard !state.isLoading else { return false }

    if shouldShowTableView {
      self.setState(.initialLoadingTableView)
    } else {
      self.setState(.initialLoading)
    }

    if let delegate = statefulDelegate {
      delegate.statefulCollectionViewWillBeginInitialLoad(cvc: self, handler: { [weak self](tableIsEmpty, errorOrNil) in
        DispatchQueue.main.async(execute: {
          self?.setHasFinishedInitialLoad(tableIsEmpty, error: errorOrNil)
        })
      })
    }

    return true
  }

  fileprivate func setHasFinishedInitialLoad(_ tableIsEmpty: Bool, error: NSError?) {
    guard state.isInitialLoading else { return }

    if tableIsEmpty {
      self.setState(.emptyOrInitialLoadError, updateView: true, error: error)
    } else {
      self.setState(.idle)
    }
  }
}
