//
//  InitialLoadErrorView.swift
//  Tree
//
//  Created by Mac OS X on 07/03/2017.
//  Copyright © 2017 abc. All rights reserved.
//

import UIKit
import Reusable

class LoadingAndErrorView: UIView, NibLoadable {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var retryButton: UIButton!
    
    var retryHandler: ((_ sender: UIButton) -> Void)?
    
    func setMessage(attributedText: NSAttributedString, canRetry: Bool) {
        retryButton.isEnabled = canRetry
        textLabel.attributedText = attributedText
    }
    
    //My Methods
    
    func showLoading() {
        retryButton.isEnabled = false
        textLabel.isHidden = true
        
        activityIndicator.startAnimating()
    }
    
    func showErrorView(canRetry: Bool) {
        activityIndicator.stopAnimating()
        
        retryButton.isEnabled = canRetry
        textLabel.isHidden = false
    }
    
    func showNothing() {
        activityIndicator.stopAnimating()
        retryButton.isHidden = true
        textLabel.isHidden = true
    }
    
    func showErrorViewWithRetry(errorMessage: String, reloadMessage: String) {
        
        let errorAttributes = [NSAttributedStringKey.foregroundColor : UIColor.appBlackColor(),
                               NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17.0)]
        let attributedError = NSMutableAttributedString(string: errorMessage, attributes: errorAttributes)
        
        
        let reloadAttributes = [NSAttributedStringKey.foregroundColor : UIColor.appBlackColor(),
                                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0)]
        let attributedReload = NSMutableAttributedString(string: reloadMessage, attributes: reloadAttributes)
        
        let lineBreak = "\n"
        let attributedLineBreak = NSMutableAttributedString(string: lineBreak, attributes: reloadAttributes)
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(attributedError)
        finalAttributedString.append(attributedLineBreak)
        finalAttributedString.append(attributedReload)
        
        showErrorView(canRetry: true)
        setMessage(attributedText: finalAttributedString, canRetry: true)
    }
    
    //MARK: My IBActions
    
    @IBAction func retryButtonTapped(sender: UIButton) {
        retryHandler?(sender)
    }
}
