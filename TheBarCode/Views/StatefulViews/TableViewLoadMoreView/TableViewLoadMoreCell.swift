//
//  TableViewLoadMoreCell.swift
//  DramaSlayer
//
//  Created by Mac OS X on 16/01/2018.
//  Copyright © 2018 Muhammad Zeeshan. All rights reserved.
//

import UIKit
import Reusable

protocol TableViewLoadMoreCellDelegate: class {
    func replyLoadMoreButtonTapped(sender: UIButton, cell: TableViewLoadMoreCell)
}

class TableViewLoadMoreCell: UITableViewCell, NibReusable {

    var loadingView: LoadingAndErrorView!
    
    weak var delegate: TableViewLoadMoreCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        loadingView = LoadingAndErrorView.loadFromNib()
        loadingView.backgroundColor = .clear
        loadingView.retryButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        addSubview(loadingView)
        
        loadingView.autoPinEdgesToSuperviewEdges()
    }
    
    func setUpFeedLoadMoreView(loadMore: LoadMore) {
        if loadMore.isLoading {
            loadingView.showLoading()
        } else if let error = loadMore.error {
            loadingView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to refresh")
        } else {
            loadingView.showNothing()
            loadingView.retryButton.setTitle("Load more", for: .normal)
            loadingView.retryButton.isHidden = !loadMore.canLoadMore
        }
        
        loadingView.retryHandler = { sender in
            self.delegate.replyLoadMoreButtonTapped(sender: sender, cell: self)
        }
    }
}
