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
}
