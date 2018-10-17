//
//  ServerMessage.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerMessage: Mappable {
    
    var message: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        if let message = map.JSON["message"] as? String {
            self.message = message
        } else if let response = map.JSON["response"] as? [String : Any], let message = response["message"] as? String {
            self.message = message
        } else {
            debugPrint("Unable to get server success message")
        }
    }
    
    
}
