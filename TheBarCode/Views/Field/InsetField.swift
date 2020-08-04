//
//  InsetField.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 30/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class InsetField: UITextField {
    
    var canPaste: Bool = true
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12.0, dy: 12.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12.0, dy: 12.0)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return canPaste
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}
