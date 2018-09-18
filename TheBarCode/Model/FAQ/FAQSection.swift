//
//  FAQSection.swift
//  TheBarCode
//
//  Created by Mac OS X on 14/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class FAQSection {
    
    var title: String = ""
    var faqs: [FAQ] = []
    
    init(title: String, faqs: [FAQ]) {
        
        self.title = title
        self.faqs = faqs
    }
    
}
