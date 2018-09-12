//
//  LoadMore.swift
//  Manga
//
//  Created by Muhammad Zeeshan on 21/05/2017.
//  Copyright © 2017 Muhammad Zeeshan. All rights reserved.
//

import UIKit
import Foundation

class LoadMore: NSObject {
    var isLoading = false
    var canLoadMore = false
    var error: NSError?
    
    var offSet: Int = 0
    var limit: Int = 20
    
    convenience init(isLoading: Bool, canLoadMore: Bool, error: NSError?) {
        self.init()
        
        self.isLoading = isLoading
        self.canLoadMore = canLoadMore
        self.error = error
    }
    
    convenience init(offSet: Int, limit: Int, isLoading: Bool, canLoadMore: Bool, error: NSError?) {
        self.init(isLoading: isLoading, canLoadMore: canLoadMore, error: error)
        
        self.offSet = offSet
        self.limit = limit
    }
}

