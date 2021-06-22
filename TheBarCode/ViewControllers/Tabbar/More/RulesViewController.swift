//
//  RulesViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class RulesViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 20)
        Analytics.logEvent(viewRedemptionRulesScreen, parameters: nil)
        
        let headingAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appBlueColor(),
                                 NSAttributedString.Key.font : UIFont.appBoldFontOf(size: 16.0)]
        let attribtuedHeading = NSAttributedString(string: "\n\n\tRedemption & Reload Rules\n", attributes: headingAttributes)
        
        let roundCap = String(format: "%.2f", (Double(Utility.shared.regionalInfo.round) ?? 0.0) / 4)
        
        let rules =
        
        """
        
            •   You sign up to The Barcode you are entitled to a ‘Members Discount’ in all our partner venues. This is a percentage off your first round. These ‘members discount’ are either 10%, 15% or 25%  and are signposted by the colour of the pins on our map view. Check out who’s offering what and where.  
            •    When you sign up to The Barcode you can receive a Barcode Members Discount in all our featured venues. 
            •    The members discount can be used on any day, at any time and on any order you wish as long as you have not already used it during your current access period. 
            •    The members discount applies to any order up to a value of \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.round). If the value of the round comes to greater than \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.round), then the discount is capped at \(Utility.shared.regionalInfo.currencySymbol)\(roundCap) thereafter. 
            •    You can redeem any offer once (either a Trending, Exclusive or The Members Discount) in each venue, every 7 days. When the clock hits 0:00:00:00 at the end of 7 days, you can ‘Reload’ and regain access to all offers, at any previously visited venues, for just \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.reload). 
            •    You can redeem more offers during your access period by applying credits against either unique venue offers or the members discount offer.  
            •    You can redeem a maximum of 2 offers per venue per night.  
            •    When you download the app you have full access to all offers at all our featured venues. When you redeem your first offer, the countdown timer starts and your 7 day access period begins.  
            •    When the countdown timer reaches zero you can pay \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.reload) to ‘Reload.’ This will give you full access to all the offers at venues you have previously visited and allow you to regain access to your credits. 
            •    When the timer hits zero you do not have to ‘Reload,’ you can still use offers at venues where you have not previously redeemed. Until you Reload though, you will not be able to access your credits or redeem offers where you have previously redeemed. 
            •    If you share a Trending offer with friends you will receive credits when they redeem those offers. 1 shared offer redeemed = 1 credit. 
        """
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15.0, options: [:])]
        paragraphStyle.defaultTabInterval = 15
        paragraphStyle.firstLineHeadIndent = 15
        paragraphStyle.headIndent = 50
        
        let attributedRules = NSAttributedString(string: rules, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                             NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                                                             NSAttributedString.Key.paragraphStyle : paragraphStyle])
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(attribtuedHeading)
        finalAttributedString.append(attributedRules)
        
        self.textView.attributedText = finalAttributedString
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
