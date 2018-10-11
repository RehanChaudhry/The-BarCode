//
//  User.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class User: CoreStoreObject {
    
    var userId = Value.Required<String>("user_id", initial: "")
    var fullName = Value.Required<String>("fullname", initial: "")
    var email = Value.Required<String>("email_id", initial: "")
    var accessToken = Value.Required<String>("access_token", initial: "")
    var refreshToken = Value.Required<String>("refresh_token", initial: "")
    var dobString = Value.Required<String>("date_of_birth", initial: "")
    var genderString = Value.Required<String>("gender", initial: "")
}


extension User: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \User.userId)
    }
    
    var uniqueIDValue: String {
        get { return self.userId.value }
        set { self.userId.value = newValue }
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        return source["user_id"] as? String
    }
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.fullName.value = source["fullname"] as! String
        self.email.value = source["email"] as! String
        self.dobString.value = source["dob"] as! String
        self.genderString.value = source["gender"] as! String
        self.accessToken.value = source["access_token"] as! String
        self.refreshToken.value = source["refresh_token"] as! String
    }
}
