//
//  OrderPrivacyPolicy.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 03/09/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import Foundation

//
//  OrderPrivacyPolicySection.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderPrivacyPolicy {
    
    //var text: String = ""
    
    lazy var note: NSAttributedString = {
        return self.getAttributedNote()
    }()
    
//    var defaultInfo: String = "*By making default it will be prefilled for upcoming orders."
    
    var isDefault: Bool = false
    
//    var allowedCharacters: CharacterSet? = CharacterSet(charactersIn: "0123456789+-")
    
    func getAttributedNote() -> NSAttributedString {
        let normalNoteAttribute = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                   NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 12.0)]
        let boldNoteAttribute = [NSAttributedString.Key.foregroundColor : UIColor.appBlueColor(),
                                 NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 12.0)]
        let notePrefix = NSAttributedString(string: "Please accept the ", attributes: normalNoteAttribute)
        let noteType1 = NSAttributedString(string: "terms and conditions ", attributes: boldNoteAttribute)
        let noteAnd = NSAttributedString(string: "to continue. ", attributes: normalNoteAttribute)
        
        let attributedNote = NSMutableAttributedString()
        attributedNote.append(notePrefix)
        attributedNote.append(noteType1)
        attributedNote.append(noteAnd)
        
        return attributedNote
    }
}

class OrderPrivacyPolicySection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .orderPrivacyPolicy
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderPrivacyPolicy]

    init(items: [OrderPrivacyPolicy]) {
        self.items = items
    }
}
