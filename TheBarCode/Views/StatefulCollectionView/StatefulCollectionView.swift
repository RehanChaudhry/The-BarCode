//
//  StatefulCollectionView.swift
//  Demo
//
//  Created by Tim on 12/05/2016.
//  Copyright © 2016 timominous. All rights reserved.
//

import UIKit
import PureLayout

/**
 Drop-i@objc @objc n replacement for `UITableView` that supports pull-to-refresh, load-more, initial load, and empty states.
 */
public final class StatefulCollectionView: UIView {
  internal enum State {
    case idle
    case initialLoading
    case initialLoadingTableView
    case emptyOrInitialLoadError
    case loadingFromPullToRefresh
    case loadingMore

    var isLoading: Bool {
      switch self {
      case .initialLoading: fallthrough
      case .initialLoadingTableView: fallthrough
      case .loadingFromPullToRefresh: fallthrough
      case .loadingMore:
        return true
      default: return false
      }
    }

    var isInitialLoading: Bool {
      switch self {
      case .initialLoading: fallthrough
      case .initialLoadingTableView:
        return true
      default: return false
      }
    }
  }

  internal enum ViewMode {
    case table
    case `static`
  }

  /**
   Returns an object initialized from data in a given unarchiver.

   - Parameter aDecoder: An unarchiver object.

   - Returns: An initialized StatefulCollectionView object.
   */
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  /**
   Initializes and returns a newly allocatied view object with the specified frame rectangle.

   - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. this method uses the frame rectangle to set the center and bounds properties accordingly.

   - Returns: An initialized StatefulCollectionView object.
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  func commonInit() {
    setUpCollectionViewWithLayout(frame: bounds, layout: nil)
    addSubview(collectionView)
    addSubview(dynamicContentView)
    
    collectionView.autoPinEdgesToSuperviewEdges()

    refreshControl.addTarget(self,
      action: #selector(refreshControlValueChanged), for: .valueChanged)
    collectionView.addSubview(refreshControl)
  }

  /**
   Lays out subviews.
   */
  override public func layoutSubviews() {
    super.layoutSubviews()
    collectionView.frame = bounds
    dynamicContentView.frame = bounds
  }

    
    var collectionView: UICollectionView!
    func setUpCollectionViewWithLayout(frame: CGRect, layout: UICollectionViewFlowLayout?) {
        if let layout = layout {
            collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        } else {
            collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        }
    }

  /**
   An accessor to the contained `UITableView`.
   */
  public var innerCollection: UICollectionView {
    return collectionView
  }

  internal lazy var dynamicContentView: UIView = { [unowned self] in
    let view = UIView(frame: self.bounds)
    view.backgroundColor = .white
    view.isHidden = true
    return view
  }()

  internal lazy var refreshControl = UIRefreshControl()

  // MARK: - Properties

  /**
   Enables the user to pull down on the tableView to initiate a refresh
   */
  public var canPullToRefresh = false

  /**
   Enables the user to control whether to trigger loading of more objects or not
   */
  public var canLoadMore = false

  /**
   Distance from the bottom  of the tableView's vertical content offset where load more will be triggered
   */
  public var loadMoreTriggerThreshold: CGFloat = 64

  internal var loadMoreViewIsErrorView = false
  internal var lastLoadMoreError: NSError?
  internal var watchForLoadMore = false

  internal var state: State = .idle

  internal var viewMode: ViewMode = .table {
    didSet {
      let hidden = viewMode == .table

      guard dynamicContentView.isHidden != hidden else { return }
      dynamicContentView.isHidden = hidden
    }
  }

  // MARK: - Stateful Delegate

  /**
   The object that acts as the stateful delegate of the table view.

   - Discussion: The stateful delegate must adopt the `StatefulCollectionDelegate` protocol. The stateful delegate is not retained.
   */
  weak public var statefulDelegate: StatefulCollectionDelegate?
    
    var loadMoreView: UIView? = nil
}
