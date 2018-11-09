//
//  Contact.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Contacts

class Contact: NSObject {
    
    var id: String = ""
    var fullName: String = ""
    var email: String = ""
    
    var isSelected: Bool = false
    
    convenience init(contact: CNContact) {
        
        self.init()
        
        self.id = contact.identifier
        
        if contact.givenName.count == 0 && contact.familyName.count == 0 {
            self.fullName = contact.emailAddresses.first?.value as String? ?? ""
        } else {
            self.fullName = contact.givenName + " " + contact.familyName
        }
        
        self.email = contact.emailAddresses.first?.value as String? ?? ""
    }
    
    convenience init(id: String, fullName: String, email: String) {
        self.init()
        
        self.id = id
        self.fullName = fullName
        self.email = email
    }
    
}
