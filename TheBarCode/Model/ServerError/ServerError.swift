//
//  ServerError.swift
//  OAuth
//
//  Created by Mac OS X on 16/05/2017.
//  Copyright © 2017 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

class ServerError: Mappable {
    
    var detail: String = ""
    var type: String = ""
    var title: String = ""
    var messages: [String] = []
    
    var errors: [ErrorObject] = []
    
    var statusCode: Int = 0
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        
        self.detail <- map["message"]
        if let errorDict = map.JSON["errors"] as? [String : Any] {
            for (key, value) in errorDict {
                
                if let messages = value as? [String] {
                    let errorObject = ErrorObject(type: key, messages: messages)
                    self.errors.append(errorObject)
                } else {
                    debugPrint("Unable to map error")
                }
            }
        } else {
            debugPrint("No error info found")
        }
    }
    
    func errorMessages() -> String {
        var singleErrorMessage: String = ""
        for error in errors {
            for message in error.messages {
                singleErrorMessage.append(message)
                
                if message != error.messages.last! {
                    singleErrorMessage += "\n"
                }
            }
            
            if error != errors.last! {
                singleErrorMessage += "\n"
            }
        }
        
        return singleErrorMessage
    }
    
    func nsError() -> NSError {
        //TODO
        let error = NSError(domain: "ServerError", code: 200, userInfo: [NSLocalizedDescriptionKey : self.errorMessages()])
        return error
    }
    
}

class ErrorObject: NSObject {
    
    var type: String = ""
    var messages: [String] = []
    
    init(type: String, messages: [String]) {
        self.type = type
        self.messages = messages
    }
}
