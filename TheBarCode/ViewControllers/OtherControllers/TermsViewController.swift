//
//  TermsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController {
    
    var webView: WKWebView!
    
    var statefulView: LoadingAndErrorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        
        self.webView.autoPinEdgesToSuperviewSafeArea()
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.webView.reload()
        }
        
        self.statefulView.autoPinEdgesToSuperviewSafeArea()

        let url = URL(string: barCodeDomainURLString + "terms-conditions")
        let request = URLRequest(url: url!)
        self.webView.load(request)
        
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

//MARK: WKNavigationDelegate
extension TermsViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.statefulView.isHidden = true
        self.statefulView.showNothing()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.statefulView.isHidden = false
        self.statefulView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to reload")
    }
}
