//
//  AsyncImageView.swift
//  Tree
//
//  Created by Mac OS X on 22/02/2017.
//  Copyright © 2017 abc. All rights reserved.
//

import UIKit
import SDWebImage
import PureLayout

class AsyncImageView: UIImageView {

    var activityIndicatorView: UIActivityIndicatorView!
    var progressView: UIProgressView!
    var retryButton: UIButton!
    
    var showRetry = true
    var showProgress = false
    var showActivityIndicator = true
    
    var placeHolderImage: UIImage?
    
    var completionHandler: SDExternalCompletionBlock? = nil

    convenience init() {
        self.init()
        
        setUpAsyncImageView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpAsyncImageView()
    }
    
    //My Methods
    
    func setUpAsyncImageView() {
        
        backgroundColor = UIColor.appGrayColor()
        
        isUserInteractionEnabled = true
        clipsToBounds = true
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
        
        activityIndicatorView.autoCenterInSuperview()
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.isHidden = true
        progressView.progress = 0.0
        addSubview(progressView)
        
        progressView.autoPinEdge(toSuperviewEdge: .top)
        progressView.autoPinEdge(toSuperviewEdge: .leading)
        progressView.autoPinEdge(toSuperviewEdge: .trailing)
        
        retryButton = UIButton(type: .system)
        retryButton.isHidden = true
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped(sender:)), for: .touchUpInside)
        addSubview(retryButton)
        
        retryButton.autoPinEdgesToSuperviewEdges()
    }
    
    @objc func retryButtonTapped(sender: UIButton) {
        setImageWith(url: sd_imageURL(), showRetryButton: showRetry, placeHolder: placeHolderImage, shouldShowAcitivityIndicator: showActivityIndicator, shouldShowProgress: showProgress, completion: completionHandler)
    }
    
    func setImageWith(url: URL?, showRetryButton show: Bool) {
        setImageWith(url: url, showRetryButton: show, placeHolder: nil, shouldShowAcitivityIndicator: true, shouldShowProgress: false, completion: nil)
    }
    
    func setImageWith(url: URL?, showRetryButton show: Bool, shouldShowActivityIndicator: Bool) {
        setImageWith(url: url, showRetryButton: show, placeHolder: nil, shouldShowAcitivityIndicator: shouldShowActivityIndicator, shouldShowProgress: false)
    }
    
    func setImageWith(url: URL?, showRetryButton show: Bool, placeHolder: UIImage?) {
        setImageWith(url: url, showRetryButton: show, placeHolder: placeHolder, shouldShowAcitivityIndicator: true, shouldShowProgress: false, completion: nil)
    }
    
    func setImageWith(url: URL?, showRetryButton show: Bool, placeHolder: UIImage?, shouldShowProgress: Bool) {
        setImageWith(url: url, showRetryButton: show, placeHolder: placeHolder, shouldShowAcitivityIndicator: true, shouldShowProgress: shouldShowProgress, completion: nil)
    }
    
    func setImageWith(url: URL?, showRetryButton show: Bool, placeHolder: UIImage?,shouldShowAcitivityIndicator: Bool, shouldShowProgress: Bool) {
        setImageWith(url: url, showRetryButton: show, placeHolder: placeHolder, shouldShowAcitivityIndicator: shouldShowAcitivityIndicator, shouldShowProgress: shouldShowProgress, completion: nil)
    }
    
    func setImageWith(url: URL?, showRetryButton show: Bool, placeHolder: UIImage?,shouldShowAcitivityIndicator: Bool, shouldShowProgress: Bool, completion: SDExternalCompletionBlock?) {
        
        showActivityIndicator = shouldShowAcitivityIndicator
        showProgress = shouldShowProgress
        placeHolderImage = placeHolder
        completionHandler = completion
        
        retryButton.isHidden = true
        
        if showActivityIndicator {
            activityIndicatorView.startAnimating()
        }
        
        sd_setImage(with: url, placeholderImage: placeHolder, options: .retryFailed, progress: { (receivedSize: Int, expectedSize: Int, url: URL?) in
            
            DispatchQueue.main.async {
                if expectedSize > 0 && receivedSize > 0 {
                    var progress = CGFloat(receivedSize) / CGFloat(expectedSize)
                    progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
                    
                    self.progressView.isHidden = !self.showProgress
                    self.progressView.progress = Float(progress)
                }
            }
            
        }) { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
            
            self.activityIndicatorView.stopAnimating()
            
            if let _ = image {
                self.progressView.isHidden = true
            } else {
                self.retryButton.isHidden = !show
            }
            
            completion?(image, error, cacheType, url)
        }
    }
}
