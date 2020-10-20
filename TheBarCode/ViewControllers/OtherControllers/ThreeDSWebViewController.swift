//
//  ThreeDSWebViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 07/10/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

protocol ThreeDSWebViewControllerDelegate: class {
    func threeDSWebViewController(controller: ThreeDSWebViewController, didCompleted3DSAuthentication secureCode: String, model: ThreeDSModel)
}

class ThreeDSWebViewController: UIViewController {
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    var webView: WKWebView!
    
    var statefulView: LoadingAndErrorView!
    
    var threedsModel: ThreeDSModel!
    
    weak var delegate: ThreeDSWebViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        self.webView = WKWebView()
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

        self.loadTermUrlContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadTermUrlContent() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let url = URL(string: self.threedsModel.redirectUrl)!
        
        let termUrl = worldPayTermBaseUrl
        let paReq = self.threedsModel.secureRequest
            
        let params: [String : Any] = ["TermUrl" : termUrl, "PaReq" : paReq]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: nil).responseData { (response) in
            guard response.error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: response.error!.localizedDescription, reloadMessage: "Tap to reload")
                return
            }
            
            guard let responseData = response.data, let html = String(data: responseData, encoding: .utf8) else {
                self.statefulView.showErrorViewWithRetry(errorMessage: APIHelper.shared.getGenericError().localizedDescription, reloadMessage: "Tap to reload")
                return
            }
            
            self.webView.loadHTMLString(html, baseURL: url)
        }
    }

}

//MARK: WKNavigationDelegate
extension ThreeDSWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let urlString = webView.url?.absoluteString
        let scheme = webView.url?.scheme
        
        if let scheme = scheme, scheme == worldPayScheme,
            let urlString = urlString,
            let components = URLComponents(string: urlString),
            let queryItems = components.queryItems,
            let secureCode = queryItems.first(where: {$0.name == "PaRes"})?.value {
            
            self.delegate.threeDSWebViewController(controller: self, didCompleted3DSAuthentication: secureCode, model: self.threedsModel)
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
