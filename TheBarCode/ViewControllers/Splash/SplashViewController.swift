//
//  ViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import CoreLocation

class SplashViewController: UIViewController {

    var locationManager: MyLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        CoreStore.defaultStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<User>("User")
                ]
            )
        )
        
        try! CoreStore.addStorageAndWait()
        
        let dataStack = Utility.inMemoryStack
        
        try! dataStack.addStorageAndWait(InMemoryStore())
        
        self.setupAuthIfNeeded()
        
        self.updateLocationIfNeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: My Methods
    
    func setupAuthIfNeeded() {
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User not found for auth setup")
            return
        }
        
        APIHelper.shared.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
    }
    
    @objc func moveToNextController() {
        self.performSegue(withIdentifier: "SplashToLoginOptions", sender: nil)
    }
}

//Webservices Methods
extension SplashViewController {
    func updateLocationIfNeed() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User does not exists for location update")
            self.moveToNextController()
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        var canContinue: Bool? = nil
        if authorizationStatus == .authorizedAlways {
            canContinue = true
        } else if authorizationStatus == .authorizedWhenInUse {
            canContinue = false
        }
        
        guard let requestAlwaysAccess = canContinue else {
            debugPrint("Location permission not authorized")
            self.moveToNextController()
            return
        }
        
        self.locationManager = MyLocationManager()
        self.locationManager.locationPreferenceAlways = requestAlwaysAccess
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyHundredMeters, timeOut: 20.0) { [unowned self] (location, error) in
            
            guard error == nil else {
                debugPrint("Error while getting location: \(error!.localizedDescription)")
                self.moveToNextController()
                return
            }
            
            var params = ["latitude" : "\(location!.coordinate.latitude)",
                "longitude" : "\(location!.coordinate.longitude )"] as [String : Any]
            if !Utility.shared.getCurrentUser()!.isLocationUpdated.value {
                params["send_five_day_notification"] = true
            }
            
            let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathLocationUpdate, method: .put, completion: { (response, serverError, error) in
                
                defer {
                    self.moveToNextController()
                }
                
                guard error == nil else {
                    debugPrint("Error while updating location: \(error!.localizedDescription)")
                    return
                }
                
                guard serverError == nil else {
                    debugPrint("Server error while updating location: \(serverError!.errorMessages())")
                    return
                }
                
                debugPrint("Location update successfully")
                
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let edittedUser = transaction.edit(user)
                    edittedUser?.isLocationUpdated.value = true
                })
                
            })
            
        }
    }
}

