//
//  FaqsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class FaqsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var faqSections: [FAQSection] = []
    
    var expandedSection = NSMutableIndexSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let section1 = FAQSection(title: "How much discount do we receive?", faqs: [FAQ(text: "You simply order your drinks and tell the bar tender you intend to use The Barcode discount, when it’s time to pay. You then show him them your screen with the offer page opened up and they press redeem. They then apply the discount to your bill and the offer is redeemed and can then be reloaded next time you decide to either apply a credit or pay for your reload.")])
        self.faqSections.append(section1)
        
        let section2 = FAQSection(title: "How often can I claim my discount?", faqs: [FAQ(text: "You simply order your drinks and tell the bar tender you intend to use The Barcode discount, when it’s time to pay. You then show him them your screen with the offer page opened up and they press redeem. They then apply the discount to your bill and the offer is redeemed and can then be reloaded next time you decide to either apply a credit or pay for your reload.")])
        self.faqSections.append(section2)
        
        let section3 = FAQSection(title: "How often can I reload?", faqs: [FAQ(text: "You simply order your drinks and tell the bar tender you intend to use The Barcode discount, when it’s time to pay. You then show him them your screen with the offer page opened up and they press redeem. They then apply the discount to your bill and the offer is redeemed and can then be reloaded next time you decide to either apply a credit or pay for your reload.")])
        self.faqSections.append(section3)
        
        let section4 = FAQSection(title: "Do I have to reload?", faqs: [FAQ(text: "You simply order your drinks and tell the bar tender you intend to use The Barcode discount, when it’s time to pay. You then show him them your screen with the offer page opened up and they press redeem. They then apply the discount to your bill and the offer is redeemed and can then be reloaded next time you decide to either apply a credit or pay for your reload.")])
        self.faqSections.append(section4)
        
        let section5 = FAQSection(title: "How much does it cost to reload?", faqs: [FAQ(text: "You simply order your drinks and tell the bar tender you intend to use The Barcode discount, when it’s time to pay. You then show him them your screen with the offer page opened up and they press redeem. They then apply the discount to your bill and the offer is redeemed and can then be reloaded next time you decide to either apply a credit or pay for your reload.")])
        self.faqSections.append(section5)
        
        let section6 = FAQSection(title: "Do the same rules apply to all bars?", faqs: [FAQ(text: "You simply order your drinks and tell the bar tender you intend to use The Barcode discount, when it’s time to pay. You then show him them your screen with the offer page opened up and they press redeem. They then apply the discount to your bill and the offer is redeemed and can then be reloaded next time you decide to either apply a credit or pay for your reload.")])
        self.faqSections.append(section6)
        
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
        headerView?.setUpHeaderView(faqSection: self.faqSections[section])
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

    }
}
