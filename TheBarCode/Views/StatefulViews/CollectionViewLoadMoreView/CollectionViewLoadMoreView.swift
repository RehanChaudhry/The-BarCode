//
//  CollectionViewLoadMoreView.swift
//  Tree
//
//  Created by Mac OS X on 07/03/2017.
//  Copyright © 2017 abc. All rights reserved.
//

import UIKit
import Reusable
import PureLayout

class CollectionViewLoadMoreView: UICollectionReusableView, NibReusable {

    var loadingView: LoadingAndErrorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        loadingView = LoadingAndErrorView.loadFromNib()
        loadingView.backgroundColor = .clear
        addSubview(loadingView)
        
        loadingView.autoPinEdgesToSuperviewEdges()
    }
    
    func setUpFeedLoadMoreView(loadMore: LoadMore) {
        if loadMore.isLoading {
            loadingView.showLoading()
        } else if let error = loadMore.error {
            loadingView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to Refresh")
        } else {
            loadingView.showNothing()
        }
    }
}
