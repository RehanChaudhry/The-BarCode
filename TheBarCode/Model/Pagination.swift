//
//  Pagination.swift
//  TheBarCode
//
//  Created by Aasna Islam on 16/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import Foundation
import ObjectMapper

class Pagination: Mappable {
    
    var total: Int = 0
    var current: Int = 0
    var last: Int = 0
    var next: Int = 1
    
    var isLoading = false
    
    var error: NSError?
    
    required convenience init?( map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        total <- map["total"]
        current <- map["current"]
        last <- map["last"]
        next <- map["next"]
    }
    
    func canLoadMore() -> Bool {
        return self.current < self.last
    }
    
}
