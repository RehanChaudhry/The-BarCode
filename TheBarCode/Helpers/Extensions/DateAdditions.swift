//
//  DateAdditions.swift
//  TheBarCode
//
//  Created by Aasna Islam on 17/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func isDate (inRange fromDate: Date, toDate: Date, inclusive: Bool) -> Bool {
        if inclusive {
            return !(self.compare (fromDate) == .orderedAscending) && !(self.compare (toDate) == .orderedDescending)
        } else {
            return self.compare (fromDate) == .orderedDescending && self.compare (toDate) == .orderedAscending
        }
        
    }
}


extension Date {
    
    func timeAgoSinceDate(numericDates:Bool) -> String {
      
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -8, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
           
            if (diff >= 2) {
                return "\(diff) seconds ago"
            } else if (diff < 2) {
                return "1 second ago"
            }
            
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
               
            if (diff >= 2) {
                return "\(diff) minutes ago"
            } else if (diff < 2) {
                return "1 minute ago"
            }
                
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
                
            if (diff >= 2) {
                return "\(diff) hours ago"
            } else if (diff < 2) {
                return  "1 hour ago"
            }
                
        } else if weekAgo < self {
                
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            if (diff >= 2) {
                return "\(diff) days ago"
            } else if (diff < 2) {
                return  "Yesterday"
            }
        }

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        return dateFormatterPrint.string(from: self)
    }
}
