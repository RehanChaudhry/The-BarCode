//
//  FaqsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class FaqsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    var faqSections: [FAQSection] = []
    
    var expandedSection = NSMutableIndexSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        Analytics.logEvent(viewFaqsScreen, parameters: nil)
        
        let section1 = FAQSection(title: "How much discount do we receive?", faqs: [FAQ(text: "The members discount ranges from a minimum of 10% up to 25% off your first round. Keep your eye out though, venues provide plenty of varied offers that are greater than the members discount at different times and for different events.")])
        self.faqSections.append(section1)
        
        let section2 = FAQSection(title: "What constitutes a round?", faqs: [FAQ(text: "A Barcode round is \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.round).")])
        self.faqSections.append(section2)
        
        let section3 = FAQSection(title: "How do I claim my discount?", faqs: [FAQ(text: "You simply order your drinks and tell the bartender that you are using The Barcode. For offer redemption you must be in the vicinty of the venue and when it is time to pay, press \"Redeem\", the offer will be redeemed and the discount will be applied to your bill. Simple!")])
        self.faqSections.append(section3)
        
        let section4 = FAQSection(title: "How often can I reload?", faqs: [FAQ(text: "You can reload a maximum of once every 7 days but can reload anytime after 7 days from the previous reload. The timer at the top of the screen will let you know how long to wait until you can next Reload. Your 7 day timer starts after you first Redeem one of our many great offers.")])
        self.faqSections.append(section4)
        
        let section5 = FAQSection(title: "Do I have to Reload?", faqs: [FAQ(text: "No. The Barcode is not a subscription and you can choose to use it as often or as little as you like. You can use The Barcode as a directory of great independent venues and take advantage of the offers that are on there from when you sign up. However, Reloading is the best way to make the most of all of the features on 'The Barcode' app, and remember, you only pay to save.")])
        self.faqSections.append(section5)
        
        let section6 = FAQSection(title: "How much does it cost to reload?", faqs: [FAQ(text: "\(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.reload)")])
        self.faqSections.append(section6)
        
        
        let section7 = FAQSection(title: "Do the same rules apply to all venues?", faqs: [FAQ(text: "Yes, all venues have to honour a minimum discount of 10% off a round to the value of \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.round) at all times. However this can vary from 10%, 15% and 25% at different venues and at different times. You can see the value of the discount at the banner at the bottom of each venue page.")])
        self.faqSections.append(section7)
        
        let section8 = FAQSection(title: "What is the minimum discount that any venue can offer?", faqs: [FAQ(text: "10% off the first round up to a value of \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.round), on any day of the week and at any time.")])
        self.faqSections.append(section8)
        
        let section9 = FAQSection(title: "What is the maximum discount any venue can offer?", faqs: [FAQ(text: "It is open ended and depends entirely on the individual venue and what they wish to do.")])
        self.faqSections.append(section9)
        
        let section10 = FAQSection(title: "Is there any time I can’t claim my discount?", faqs: [FAQ(text: "Only when you have already used your discounts and have not applied either credits or reloaded.")])
        self.faqSections.append(section10)
        
        let section11 = FAQSection(title: "Can I claim my discount at any venue that is on the app?", faqs: [FAQ(text: "Yes.")])
        self.faqSections.append(section11)
        
        let section12 = FAQSection(title: "Are all offers exclusive to The Barcode?", faqs: [FAQ(text: "Any offer that has a redemption button attached will be an exclusive Barcode offer, so you don't need to worry about wasting money or credits on regular offers. Venues are also able to promote regular deals on The Barcode but these are purely informational and can't be redeemed. The 25% off deal is a unique Barcode offer and is available at all of our partner venues.")])
        self.faqSections.append(section12)
        
        
        let section13 = FAQSection(title: "Does the discount apply to food as well as drinks?", faqs: [FAQ(text: "Yes – Users can claim their minimum discounts off any order for any items upto the value of \(Utility.shared.regionalInfo.currencySymbol)\(Utility.shared.regionalInfo.round).")])
        self.faqSections.append(section13)
        
        let section14 = FAQSection(title: "What do I get for a referral?", faqs: [FAQ(text: "For each referral you make to 'The Barcode' you receive 1 free credit on us. Just go to the invite friends tab and invite as many friends as you want. When they have downloaded the app and redeemed their first offer you will get a credit. ")])
        self.faqSections.append(section14)
        
        let section15 = FAQSection(title: "How much is a credit worth?", faqs: [FAQ(text: "A credit can be used to activate any offer you like. This could be a members discount of 25% that you want to re-use or one of the many other offers on the app that you want to redeem again.")])
        self.faqSections.append(section15)
        
        let section16 = FAQSection(title: "How do I get more credits?", faqs: [FAQ(text: "You can get credits by inviting friends to join the app or sharing offers with your friends. The Credits will drop into your account as soon they have either downloaded the app using your code and redeemed their first offer, or redeemed the offer you shared.")])
        self.faqSections.append(section16)
        
        
//        let section17 = FAQSection(title: "Can I Share my Credits?", faqs: [FAQ(text: "Yes, if you are feeling super generous!! By using our 'Share Credits' feature you can pass on credits to friends who may be in need. Just type in your friends unique code and they will receive one of your credits. You can do this as many times as you like.")])
//        self.faqSections.append(section17)
        
        let section18 = FAQSection(title: "How often can I use credits?", faqs: [FAQ(text: "You can use credits as often as you like. For them to be valid though you need to have Reloaded within the previous 7 days. If you haven't, no problem, just hit the Reload button and reactivate all the offers that you have previously Redeemed.")])
        self.faqSections.append(section18)
        
        let section19 = FAQSection(title: "How many credits can I use in a night?", faqs: [FAQ(text: "You can use as many credits in a night as you have available. You can Redeem 2 offers per night per venue but how many venues you go and Redeem in is up to you.")])
        self.faqSections.append(section19)
        
        let section20 = FAQSection(title: "Can I save credits?", faqs: [FAQ(text: "Yes. They have no expiry date so feel free to bank them for a rainy day.")])
        self.faqSections.append(section20)
        
        let section21 = FAQSection(title: "Can I use credits if I haven’t reloaded?", faqs: [FAQ(text: "From the moment you have downloaded the app you can use as many credits as you earn in the next 7 days. After that, you can only apply credits when you have reloaded within any 7 day period. You can however still earn credits by referring friends and sharing deals, they are then saved in your account for the next time you decide to reload. ")])
        self.faqSections.append(section21)
        
        
//        let section22 = FAQSection(title: "What are live offers?", faqs: [FAQ(text: "Live offers are last minute promotions that bars send out to grab your attention . You will receive a notification if you are within 500m of the bar or if you have favourited that bar. The notification flare will be active for 1 hour but the offer length can vary according to the deal. You can check what live offers are on by checking your 'Live' tab.")])
//        self.faqSections.append(section22)
        
        
        let section23 = FAQSection(title: "Am I able to claim offers if I haven’t reloaded?", faqs: [FAQ(text: "Yes, unless the offer that is sent out is conditional on you redeeming your offer and you have already redeemed previously in that venue since your last reload period.")])
        self.faqSections.append(section23)
        
        let section24 = FAQSection(title: "What defines which offers I receive in my Trending feed?", faqs: [FAQ(text: "Trending offers are designed to show you the most relevant offers and events on any given day. Based on any available data on user history, preference settings and geographical location we match you with the most relevant offers and events appearing in the app each day. You can adjust which offers you receive by altering your user preferences, adding information to your profile or by favouriting specific venues.")])
        self.faqSections.append(section24)
        
        let section25 = FAQSection(title: "Can I take advantage of offers that have not appeared in my ‘Trending.’?", faqs: [FAQ(text: "Yes. The Trending deals are just a neat way of you receiving the most relevant offers whilst avoiding being spammed. There are of course though loads of other offers and promotions for you to peruse and use at your leisure.")])
        self.faqSections.append(section25)
        
//        let section26 = FAQSection(title: "Can I get notified of ‘Live Offers’ even if I am not within a 500m radius of the bar?", faqs: [FAQ(text: "Yes. You will receive 'Live Offers' from any of the Bars that you have 'Favourited'.You can 'Favourite' as many bars as you like to receive more great offers. Also, watch out for offers sent through from your friends, they can forward on any 'Live Offers' that they receive if they think you'll like them. You can also simply browse the Live Offers Tab within the app to see what’s happening right now.")])
//        self.faqSections.append(section26)
        
        self.tableView.register(headerFooterViewType: FAQHeaderView.self)
        self.tableView.register(cellType: FAQTableViewCell.self)
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

extension FaqsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.faqSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expandedSection.contains(section) {
            return self.faqSections[section].faqs.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(FAQHeaderView.self)
        headerView?.section = section
        headerView?.delegate = self
        headerView?.setUpHeaderView(faqSection: self.faqSections[section], isOpen: self.expandedSection.contains(section))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: FAQTableViewCell.self)
        cell.setUpCell(faq: self.faqSections[indexPath.section].faqs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

extension FaqsViewController: FAQHeaderViewDelegate {
    func faqHeaderView(headerView: FAQHeaderView, didSelectAtSection section: Int) {
        
        let isExpanded = self.expandedSection.contains(section)
        
        let rows = self.faqSections[section].faqs.count
        var indexPaths: [IndexPath] = []
        for row in 0..<rows {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        if isExpanded {
            self.expandedSection.remove(section)
            self.tableView.deleteRows(at: indexPaths, with: .automatic)
        } else {
            self.expandedSection.add(section)
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }

        if let headerView = self.tableView.headerView(forSection: section) as? FAQHeaderView {
            let faqSection = self.faqSections[section]
            
            UIView.animate(withDuration: 0.3) {
                headerView.setUpHeaderView(faqSection: faqSection, isOpen: self.expandedSection.contains(section))
            }
        }
    }
}
