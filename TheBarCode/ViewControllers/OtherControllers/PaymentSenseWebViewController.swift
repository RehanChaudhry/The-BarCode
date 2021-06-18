//
//  PaymentSenseWebViewController.swift
//  TheBarCode
//
//  Created by Zeeshan on 08/06/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

protocol PaymentSenseWebViewControllerDelegate: class {
    func paymentSenseWebViewController(controller: PaymentSenseWebViewController, didPaidSuccessfully order: Order)
}

class PaymentSenseWebViewController: UIViewController {
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    var webView: WKWebView!
    
    var statefulView: LoadingAndErrorView!
        
    weak var delegate: PaymentSenseWebViewControllerDelegate!
    
    var order: Order!
    
    let interfaceName: String = "MobileJSInterface"
    
    var selectedVoucher: OrderDiscount?
    var selectedOffer: OrderDiscount?
    
    var useCredit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Add Card"
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        let webConfiguration = WKWebViewConfiguration()
        
        let accessToken = Utility.shared.getCurrentUser()!.accessToken.value
        
        let scriptString =
            """
            var \(interfaceName) = {
                getData: function(key) {
                    if (key === "accessToken") {
                        return "\(accessToken)";
                    } else {
                        return null;
                    }
                }
            };
            """
        let script = WKUserScript(source: scriptString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webConfiguration.userContentController.addUserScript(script)
        
        self.webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        
        self.webView.autoPinEdgesToSuperviewSafeArea()
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.isHidden = true
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.webView.reload()
        }
        
        self.statefulView.autoPinEdgesToSuperviewSafeArea()

        self.loadUrl()
        
//        let reloadBarButton = UIBarButtonItem(title: "Relaod", style: .plain, target: self, action: #selector(reload))
//        self.navigationItem.rightBarButtonItem = reloadBarButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reload() {
        self.webView.reload()
    }
    
    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadUrl() {
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "orderId", value: "\(self.order.orderNo)"),
            URLQueryItem(name: "source", value: "mobile")
        ]
        
        if let split = order.splitPaymentInfo, split.type != .none {
            queryItems.append(URLQueryItem(name: "splitType", value: split.type.rawValue))
            queryItems.append(URLQueryItem(name: "value", value: "\(split.value)"))
        }
        
        if let voucher = self.selectedVoucher {
            queryItems.append(URLQueryItem(name: "voucherId", value: voucher.id))
        }
        
        if let offer = self.selectedOffer {
            queryItems.append(URLQueryItem(name: "offerId", value: offer.id))
            queryItems.append(URLQueryItem(name: "offerType", value: offer.typeRaw))
            
            if self.useCredit {
                queryItems.append(URLQueryItem(name: "useCredit", value: "\(self.useCredit)"))
            }
        }
        
        var components = URLComponents(string: theBarCodeAPIDomain)!
        components.path = "/" + apiPathPaymentSense
        components.queryItems = queryItems
        
        guard let url = components.url else {
            self.showAlertController(title: "", msg: "Invalid url")
            return
        }
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let request = URLRequest(url: url)
        self.webView.load(request)
    }

}

//MARK: WKNavigationDelegate
extension PaymentSenseWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let urlString = navigationAction.request.url?.absoluteString
        
        if let urlString = urlString,
           let components = URLComponents(string: urlString),
           components.path.lowercased().contains(apiPathPaymentSense),
           components.path.lowercased().contains("success") {
            self.delegate.paymentSenseWebViewController(controller: self, didPaidSuccessfully: self.order)
            self.dismiss(animated: true, completion: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
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
