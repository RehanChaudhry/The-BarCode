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
    static func getFormattedDate(string: String , formatter:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        
        let date = dateFormatterGet.date(from: string)
        return dateFormatter.string(from: date!);
    }
}
