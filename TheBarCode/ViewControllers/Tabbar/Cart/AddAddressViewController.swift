//
//  AddAddressViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 07/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import GoogleMaps

protocol AddAddressViewControllerDelegate: class {
    func addAddressViewController(controller: AddAddressViewController, didUpdateAddress address: Address)
}

class AddAddressViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var contentHeight: NSLayoutConstraint!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var addressIconImageView: UIImageView!
    
    @IBOutlet var textViewContainer: UIView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var spotlightImageView: UIImageView!
    
    var myLocationManager: MyLocationManager!
    
    var recentResponseNumber: UInt = 0
    
    var selectedAddress: GMSAddress?
    
    weak var delegate: AddAddressViewControllerDelegate?
    
    var address: Address?
    var isEditingAddress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Add Address"
        
        self.textViewContainer.layer.borderWidth = 1.0
        self.textViewContainer.layer.borderColor = UIColor.appBgSecondaryGrayColor().cgColor
        
        self.addressIconImageView.image = self.addressIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        self.segmentedControl.backgroundColor = UIColor.appBgSecondaryGrayColor()
        
        self.getCurrentLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.contentHeight.constant = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.height + 16.0
    }
    
    //MARK: My Methods
    func getCurrentLocation() {
        
        self.addressLabel.text = ""
        self.activityIndicator.startAnimating()
        
        self.mapView.isUserInteractionEnabled = false
        self.myLocationManager = MyLocationManager()
        self.myLocationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyKilometer, timeOut: 10.0) { (location, error) in

            self.mapView.isUserInteractionEnabled = true
            
            if let location = location {
                let cameraPosition = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 13.0)
                self.mapView.animate(to: cameraPosition)
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func getReadableAddress(gmsAddress: GMSAddress) -> String {
        var address = gmsAddress.thoroughfare ?? ""
        if address.count > 0 {
            address = address + " "
        }
        
        address += (gmsAddress.locality ?? "")
        
        return address
    }
    
    func reverseGeoCodeCoorniate(coordinate: CLLocationCoordinate2D) {
        self.recentResponseNumber += 1
        let sequenceNumber = self.recentResponseNumber
        
        self.addressLabel.text = ""
        self.selectedAddress = nil
        self.activityIndicator.startAnimating()
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in

            guard sequenceNumber >= self.recentResponseNumber else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            
            guard error == nil else {
                return
            }
                        
            if let address = response?.firstResult() {
                self.addressLabel.text = self.getReadableAddress(gmsAddress: address)
            } else {
                self.addressLabel.text = ""
            }
            
            self.selectedAddress = response?.firstResult()
        }
    }
    
    //MARK: My IBActions
    @IBAction func saveAddressButtonTapped(sender: UIButton) {
        if self.isEditingAddress, self.delegate != nil, self.address != nil {
            self.delegate?.addAddressViewController(controller: self, didUpdateAddress: self.address!)
            self.navigationController?.popViewController(animated: true)
        }
    }

}

//MARK: GMSMapViewDelegate
extension AddAddressViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        let spotlightImage = UIImage(named: "icon_my_addresses")?.withRenderingMode(.alwaysTemplate)

        self.spotlightImageView.image = spotlightImage?.imageWithAlpha(alpha: 0.4)
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        debugPrint("Idle position")
        
        let spotlightImage = UIImage(named: "icon_my_addresses")?.withRenderingMode(.alwaysTemplate)
        self.spotlightImageView.image = spotlightImage
        
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        self.reverseGeoCodeCoorniate(coordinate: position.target)
    }
}
