//
//  StepperView.swift
//  stashcustomer
//
//  Created by Mac OS X on 15/10/2019.
//  Copyright © 2019 Muhammad Zeeshan. All rights reserved.
//

import UIKit

protocol StepperViewDelegate: class {
    func stepperView(stepperView: StepperView, valueChanged value: Int)
}

@IBDesignable
class StepperView: UIView {

    var textLabel: UILabel = UILabel(frame: .zero)
    
    var incrementButton: UIButton = UIButton(type: .system)
    var decrementButton: UIButton = UIButton(type: .system)
    
    @IBInspectable var value: Int = 1 {
        didSet  {
            self.updateTextLabel()
            self.enableIncrementDecrementIfNeeded()
        }
    }
    
    @IBInspectable var stepCount: Int = 1
    
    @IBInspectable var minValue: Int = 1
    @IBInspectable var maxValue: Int = 30
    
    @IBInspectable var buttonBackgroundColor: UIColor = UIColor.appGrayColor().withAlphaComponent(0.5) {
        didSet {
            self.updateAttributes()
        }
    }
    
    weak var delegate: StepperViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupChildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupChildViews()
    }

    func setupChildViews() {

        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
        
        self.textLabel.textColor = UIColor.white
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.textAlignment = .center
        self.textLabel.font = UIFont.appRegularFontOf(size: 14.0)
        self.updateTextLabel()
        self.addSubview(self.textLabel)
        self.textLabel.backgroundColor = UIColor.appCartUnSelectedColor()
        
        self.incrementButton.clipsToBounds = true
        self.incrementButton.addTarget(self, action: #selector(self.incrementButtonTapped(sender:)), for: .touchUpInside)
        self.incrementButton.titleLabel?.font = UIFont.appRegularFontOf(size: 14.0)
        self.incrementButton.tintColor = UIColor.white//appGrayColor()
        self.incrementButton.setImage(UIImage(named: "icon_stepper_plus"), for: .normal)
        self.addSubview(self.incrementButton)
        
        self.decrementButton.clipsToBounds = true
        self.decrementButton.addTarget(self, action: #selector(self.decrementButtonTapped(sender:)), for: .touchUpInside)
        self.decrementButton.titleLabel?.font = UIFont.appRegularFontOf(size: 14.0)
        self.decrementButton.tintColor = UIColor.white//appGrayColor()
        self.decrementButton.setImage(UIImage(named: "icon_stepper_minus"), for: .normal)
        self.addSubview(self.decrementButton)
        
        self.updateAttributes()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonSize = CGSize(width: 30.0, height: 30.0)
        self.decrementButton.frame = CGRect(origin: CGPoint(x: 0.0, y: (self.bounds.size.height / 2.0) - (buttonSize.height / 2.0)), size: buttonSize)
        self.incrementButton.frame = CGRect(origin: CGPoint(x: self.bounds.size.width - buttonSize.width, y: (self.bounds.size.height / 2.0) - (buttonSize.height / 2.0)), size: buttonSize)
        
     //   self.decrementButton.layer.cornerRadius = buttonSize.height / 2.0
       // self.incrementButton.layer.cornerRadius = buttonSize.height / 2.0
        
        self.textLabel.frame = CGRect(origin: CGPoint(x: self.decrementButton.frame.origin.x + buttonSize.width, y: 0.0), size: CGSize(width: self.incrementButton.frame.origin.x - self.incrementButton.frame.origin.y - buttonSize.width, height: self.bounds.size.height))
        
    }
    
    //MARK: My Methods
    func enableIncrementDecrementIfNeeded() {
        self.incrementButton.isEnabled = self.value < self.maxValue
        self.decrementButton.isEnabled = self.value > self.minValue
    }
    
    @objc func incrementButtonTapped(sender: UIButton) {
        self.value += self.stepCount
        self.updateTextLabel()
        self.delegate.stepperView(stepperView: self, valueChanged: self.value)
    }
    
    @objc func decrementButtonTapped(sender: UIButton) {
        self.value -= self.stepCount
        self.updateTextLabel()
        self.delegate.stepperView(stepperView: self, valueChanged: self.value)
    }
    
    func updateTextLabel() {
        self.textLabel.text = "\(self.value)"
    }
    
    func updateAttributes() {
        self.incrementButton.backgroundColor = self.buttonBackgroundColor
        self.decrementButton.backgroundColor = self.buttonBackgroundColor
    }
}
