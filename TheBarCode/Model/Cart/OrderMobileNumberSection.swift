//
//  OrderMobileNumberSection.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderMobileNumber {
    
    var text: String = ""
    var placeholder: String = "Enter you mobile number"
    
    lazy var note: NSAttributedString = {
        return self.getAttributedNote()
    }()
    
    var defaultInfo: String = "*By making default it will be prefilled for upcoming orders."
    
    var isDefault: Bool = false
    
    var allowedCharacters: CharacterSet? = CharacterSet(charactersIn: "0123456789+-")
    
    func getAttributedNote() -> NSAttributedString {
        let normalNoteAttribute = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                   NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 12.0)]
        let boldNoteAttribute = [NSAttributedString.Key.foregroundColor : UIColor.appBlueColor(),
                                 NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 12.0)]
        let notePrefix = NSAttributedString(string: "*Required for ", attributes: normalNoteAttribute)
        let noteType1 = NSAttributedString(string: "Takeaway", attributes: boldNoteAttribute)
        let noteAnd = NSAttributedString(string: " and ", attributes: normalNoteAttribute)
        let noteType2 = NSAttributedString(string: "Delivery", attributes: boldNoteAttribute)
        let noteSuffix = NSAttributedString(string: " only.", attributes: normalNoteAttribute)
        
        let attributedNote = NSMutableAttributedString()
        attributedNote.append(notePrefix)
        attributedNote.append(noteType1)
        attributedNote.append(noteAnd)
        attributedNote.append(noteType2)
        attributedNote.append(noteSuffix)
        
        return attributedNote
    }
}

class OrderMobileNumberSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .mobileNumber
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderMobileNumber]

    init(items: [OrderMobileNumber]) {
        self.items = items
    }
}
