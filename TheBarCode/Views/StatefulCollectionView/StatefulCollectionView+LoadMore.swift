//
//  StatefulCollectionView+LoadMore.swift
//  Pods
//
//  Created by Tim on 23/06/2016.
//
//

import UIKit

extension StatefulCollectionView {
  // MARK: - Load more

  /**
   Tiggers loading more of data. Also called when the scroll content offset reaches the `loadMoreTriggerThreshold`.
   */
  public func triggerLoadMore() {
    guard !state.isLoading else { return }

    loadMoreViewIsErrorView = false
    lastLoadMoreError = nil
    updateLoadMoreView()

    setState(.loadingMore)

    if let delegate = statefulDelegate {
      delegate.statefulCollectionViewWillBeginLoadingMore(cvc: self, handler: { [weak self](canLoadMore, errorOrNil, showErrorView) in
        DispatchQueue.main.async(execute: {
          self?.setHasFinishedLoadingMore(canLoadMore, error: errorOrNil, showErrorView: showErrorView)
        })
      })
    }
  }

  internal func updateLoadMoreView() {
    if watchForLoadMore || lastLoadMoreError != nil {
        let _ = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
//      tableView.tableFooterView = viewForLoadingMore(withError: (loadMoreViewIsErrorView ? lastLoadMoreError : nil))
    } else {
        statefulDelegate?.statefulCollectionViewRemoveLoadMoreView(cvc: self)
//      tableView.tableFooterView = UIView()
    }
  }

  internal func viewForLoadingMore(withError error: NSError?) -> UIView? {
    if let delegateMethod = statefulDelegate?.statefulCollectionViewLoadMoreErrorView, error != nil {
      return delegateMethod(self, error)
    }

    let container = UIView(frame: CGRect(origin: .zero, size: CGSize(width: collectionView.bounds.width, height: 44)))

    let sub: UIView

    if let error = error {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      label.text = error.localizedDescription
      label.font = UIFont.systemFont(ofSize: 12)
      label.textAlignment = .center
      sub = label
    } else {
      let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)

      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.startAnimating()
      sub = activityIndicator
    }

    container.addSubview(sub)
    centerView(sub, inContainer: container)

    return container
  }

  internal func setHasFinishedLoadingMore(_ canLoadMore: Bool, error: NSError?, showErrorView: Bool) {
    guard state == .loadingMore else { return }

    self.canLoadMore = canLoadMore
    loadMoreViewIsErrorView = (error != nil) && showErrorView
    lastLoadMoreError = error

    setState(.idle)
  }

  internal func watchForLoadMoreIfApplicable(_ watch: Bool) {
    var watch = watch

    if (watch && !canLoadMore) {
      watch = false
    }
    watchForLoadMore = watch
    updateLoadMoreView()

    triggerLoadMoreIfApplicable(collectionView)
  }

  /**
   Should be called when scrolling the collectionView. This determines when to call `triggerLoadMore`

   - parameter scrollView: The scrolling view.
   */
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    triggerLoadMoreIfApplicable(scrollView)
  }

  internal func triggerLoadMoreIfApplicable(_ scrollView: UIScrollView) {
    guard watchForLoadMore && !loadMoreViewIsErrorView else { return }

    let scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y
    if scrollPosition < loadMoreTriggerThreshold {
      triggerLoadMore()
    }
  }
}
