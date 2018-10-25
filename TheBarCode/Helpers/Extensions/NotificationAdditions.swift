//
//  NotificationAdditions.swift
//  TheBarCode
//
//  Created by Aasna Islam on 24/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let checkReloadStatusNotification = Notification.Name(
        rawValue: "CheckReloadStatusNotification")
    
    static let checkReloadStatusAndRefreshNotification = Notification.Name(
        rawValue: "checkReloadStatusAndRefreshNotification")
    
}
