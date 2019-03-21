//
//  StringAdditions.swift
//  Manga
//
//  Created by Muhammad Zeeshan on 05/07/2017.
//  Copyright © 2017 Muhammad Zeeshan. All rights reserved.
//

import UIKit
import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func trimWhiteSpaces() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func getFormattedEventName() -> String {
        let underscoreString = self.replacingOccurrences(of: " ", with: "_")
        return underscoreString.lowercased()
    }
}
