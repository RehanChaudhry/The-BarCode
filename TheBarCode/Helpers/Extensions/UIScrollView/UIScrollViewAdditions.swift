//
//  UIScrollViewAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollRectToVisible(frame, animated: animated)
    }
}
