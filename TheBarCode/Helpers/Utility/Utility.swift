//
//  Utility.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import KeychainAccess
import CoreStore

let bundleId = Bundle.main.bundleIdentifier!

let deviceIdKey = "deviceIdKey"

let genericErrorMessage = "Opps! Something went wrong"

class Utility: NSObject {
    
    static let shared = Utility()
    
    lazy var deviceId: String = {
        
        let keyChainServiceName = bundleId + ".keychainservice"
        let keychainService = Keychain(service: keyChainServiceName)
        func setDeviceIdInKeychain() -> String {
            let deviceId = UUID().uuidString
            do {
                try keychainService.set(deviceId, key: deviceIdKey)
            } catch {
                debugPrint("Unable to set the device id in keychain")
            }
            
            return deviceId
        }
        
        do {
            
            guard let deviceId = try keychainService.getString(deviceIdKey) else {
                debugPrint("Unable to get the device id from keychain")
                return setDeviceIdInKeychain()
            }
            
            return deviceId
        } catch {
            debugPrint("Unable to get the device id from keychain")
            return setDeviceIdInKeychain()
        }
        
    }()
    
    func saveCurrentUser(userDict: [String : Any]) -> User {
        var user: User!
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            user = try! transaction.importUniqueObject(Into<User>(), source: userDict)
        })
        return user
    }
    
    func getCurrentUser() -> User? {
        let user = CoreStore.fetchOne(From<User>())
        return user
    }
    
    func removeUser() {
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            transaction.deleteAll(From<User>())
        })
        
        debugPrint("cleared user info from local db")
    }
    
    func serverDateFormattedString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
