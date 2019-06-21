//
//  InstagramLoginViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/06/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import WebKit
import PureLayout

struct INSTAGRAM_IDS {
    
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    
    static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
    
    static let INSTAGRAM_CLIENT_ID  = "1576874e9f4b4f5f8708ad6749d9ad0d"
    
    static let INSTAGRAM_CLIENTSERCRET = " 6c93f8e9444149f5ab70af3d1d7ad103"
    
    static let INSTAGRAM_REDIRECT_URI = "https://thebarcode.co/"
    
    static let INSTAGRAM_ACCESS_TOKEN =  "access_token"
    
    static let INSTAGRAM_SCOPE = "basic"
    
}

protocol InstagramLoginViewControllerDelegate: class {
    func instagramLoginViewController(controller: InstagramLoginViewController, loggedInSuccessfully accessToke: String)
}

class InstagramLoginViewController: UIViewController {

    var webView: WKWebView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var isSigningUp: Bool = false
    
    weak var delegate: InstagramLoginViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.isSigningUp {
            self.title = "Sign up with Instagram"
        } else {
            self.title = "Sign in with Instagram"
        }
        
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        
        self.webView.autoPinEdgesToSuperviewSafeArea()
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        
        self.loadLoginPage()
    }
    
    //MARK: My Methods
    func loadLoginPage() {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        self.webView.load(urlRequest)
    }
    
    //MARK: My IBActions
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: WKNavigationDelegate
extension InstagramLoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        debugPrint("webview---url: \(webView.url!)")
        
        let requestURLString = webView.url?.absoluteString ?? ""
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI),
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=") {
            let accessToken = String(requestURLString[range.upperBound...])
            self.dismiss(animated: true) {
                self.delegate.instagramLoginViewController(controller: self, loggedInSuccessfully: accessToken)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
        
        self.showAlertController(title: "", msg: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}
