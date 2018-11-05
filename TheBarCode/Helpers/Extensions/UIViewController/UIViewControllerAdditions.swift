//
//  UIViewControllerAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addBackButton() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
    
    func updateNavigationBarAppearance() {
        if self is LoginOptionsViewController || self is SplashViewController || self is ExploreViewController {
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController!.navigationBar.backgroundColor = UIColor.clear
        } else {
            let scale = UIScreen.main.scale
            
            var navigationBarSize = self.navigationController!.navigationBar.frame.size
            navigationBarSize.width = navigationBarSize.width * scale
            navigationBarSize.height = navigationBarSize.height * scale
            
            let image = UIImage.from(color: UIColor.appNavBarGrayColor(), size: navigationBarSize)
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        }
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.view.backgroundColor = UIColor.appBgGrayColor()
    }
    
    func showAlertController(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    @objc func topMostViewController() -> UIViewController {
        // Handling Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
            // Handling UIViewController's added as subviews to some other views.
        else {
            for view in self.view.subviews
            {
                // Key property which most of us are unaware of / rarely use.
                if let subViewController = view.next {
                    if subViewController is UIViewController {
                        let viewController = subViewController as! UIViewController
                        return viewController.topMostViewController()
                    }
                }
            }
            return self
        }
    }
}

extension UITabBarController {
    override func topMostViewController() -> UIViewController {
        return self.selectedViewController!.topMostViewController()
    }
}

extension UINavigationController {
    override func topMostViewController() -> UIViewController {
        return self.visibleViewController!.topMostViewController()
    }
}
