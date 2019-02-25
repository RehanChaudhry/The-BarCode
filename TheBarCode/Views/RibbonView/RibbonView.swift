//
//  RibbonView.swift
//  TheBarCode
//
//  Created by Mac OS X on 22/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class RibbonView: RibbonBaseView {
    
    let gradientLayer = CAGradientLayer()
    
    let pathLayer = CAShapeLayer()
    
    var gradientColors = [UIColor.appGreenColor().cgColor, UIColor.appBlueColor().cgColor] {
        didSet {
            self.updateMask()
        }
    }
    
    /// The corner radius of the `ShadowView`, inspectable in Interface Builder
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.updateMask()
        }
    }
    /// The shadow color of the `ShadowView`, inspectable in Interface Builder
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.updateMask()
        }
    }
    /// The shadow offset of the `ShadowView`, inspectable in Interface Builder
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0.0, height: 2) {
        didSet {
            self.updateMask()
        }
    }
    /// The shadow radius of the `ShadowView`, inspectable in Interface Builder
    @IBInspectable var shadowRadius: CGFloat = 4.0 {
        didSet {
            self.updateMask()
        }
    }
    /// The shadow opacity of the `ShadowView`, inspectable in Interface Builder
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.updateMask()
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
    
    override func updateMask() {
        super.updateMask()
        
        self.pathLayer.frame = CGRect(origin: CGPoint.zero, size: self.layer.bounds.size)
        
        let path = self.getRibbonPath()

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.pathLayer.frame
        shapeLayer.path = path.cgPath
        self.pathLayer.mask = shapeLayer
        if self.pathLayer.superlayer == nil {
            self.layer.insertSublayer(self.pathLayer, at: 0)
        }
        
        self.gradientLayer.frame = path.bounds
        self.gradientLayer.colors = gradientColors

        if self.gradientLayer.superlayer == nil {
            self.pathLayer.insertSublayer(self.gradientLayer, at: 0)
        }
        
        self.layer.cornerRadius = self.cornerRadius
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOffset = self.shadowOffset
        self.layer.shadowRadius = self.shadowRadius
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowPath = path.cgPath
    }
}
