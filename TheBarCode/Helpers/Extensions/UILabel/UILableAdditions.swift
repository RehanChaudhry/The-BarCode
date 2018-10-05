//
//  UILableAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

extension UILabel {
    
    var isTruncated: Bool {
        
        guard let labelText = text else {
            return false
        }
        
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
        
        return labelTextSize.height > bounds.size.height
    }
}
