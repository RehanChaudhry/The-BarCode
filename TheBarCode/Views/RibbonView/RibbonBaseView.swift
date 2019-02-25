//
//  RibbonBaseView.swift
//  TheBarCode
//
//  Created by Mac OS X on 22/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class RibbonBaseView: UIView {
    
    @IBInspectable
    var ribbonWidth: CGFloat = 15.0 {
        didSet {
            updateMask()
        }
    }
    
    @IBInspectable
    var distanceFromRight: CGFloat = 50.0 {
        didSet {
            updateMask()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateMask()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateMask()
    }
    
    func updateMask() {
        
    }
    
    func getRibbonPath() -> UIBezierPath {
        
        let path = UIBezierPath()
        
        var firstStartPoint = CGPoint(x: self.bounds.size.width - distanceFromRight, y: 0.0)
        path.move(to: firstStartPoint)
        
        var secondStartPoint = CGPoint(x: self.bounds.size.width, y: distanceFromRight)
        path.addLine(to: secondStartPoint)
        
        secondStartPoint.y += self.ribbonWidth
        path.addLine(to: secondStartPoint)
        
        firstStartPoint.x -= self.ribbonWidth
        path.addLine(to: firstStartPoint)
        
        path.close()
        
        return path
    }
}
