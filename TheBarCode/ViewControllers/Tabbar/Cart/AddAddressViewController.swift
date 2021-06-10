//
//  AddAddressViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 07/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper

protocol AddAddressViewControllerDelegate: class {
    func addAddressViewController(controller: AddAddressViewController, didUpdateAddress address: Address)
    func addAddressViewController(controller: AddAddressViewController, didAddedAddress address: Address)
}

class AddAddressViewController: UIViewController {

    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var contentHeight: NSLayoutConstraint!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var addressIconImageView: UIImageView!
    
    @IBOutlet var textViewContainer: UIView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var addressTextView: UITextView!
    
    @IBOutlet var postCodeFieldView: UIView!
    
    @IBOutlet var postCodeField: UITextField!
    
    @IBOutlet var cityFieldView: UIView!
    @IBOutlet var cityField: UITextField!
    @IBOutlet var cityValidationLabel: UILabel!
    
    @IBOutlet var postCodeValidationLabel: UILabel!
    
    @IBOutlet var spotlightImageView: UIImageView!
    
    @IBOutlet var notesTextView: UITextView!
    
    @IBOutlet var addAddressButton: GradientButton!
    
    @IBOutlet var accessoryView: UIView!
    
    var myLocationManager: MyLocationManager!
    
    var recentResponseNumber: UInt = 0
    
    var selectedAddress: GMSAddress?
    
    weak var delegate: AddAddressViewControllerDelegate?
    
    var address: Address?
    var isEditingAddress: Bool = false
    
    enum AddressLabel: Int {
        case home = 0, work = 1, other = 2
        
        func title() -> String {
            switch self {
            case .home:
                return "Home"
            case .work:
                return "Work"
            case .other:
                return "Other"
            }
        }
    }
    
    var maxPostCodeCharLimit = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.postCodeField.inputAccessoryView = self.accessoryView
        self.cityField.inputAccessoryView = self.accessoryView
        self.addressTextView.inputAccessoryView = self.accessoryView
        self.notesTextView.inputAccessoryView = self.accessoryView
        
        self.postCodeValidationLabel.text = ""
        self.cityValidationLabel.text = ""
        
        let placeholderAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                     NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.5)]
        
        let postCodePlaceholder = self.postCodeField.placeholder ?? ""
        let attributedPostCodePlaceholder = NSAttributedString(string: postCodePlaceholder, attributes: placeholderAttributes)
        self.postCodeField.attributedPlaceholder = attributedPostCodePlaceholder
        
        let cityPlaceholder = self.cityField.placeholder ?? ""
        let attributedCityPlaceholder = NSAttributedString(string: cityPlaceholder, attributes: placeholderAttributes)
        self.cityField.attributedPlaceholder = attributedCityPlaceholder
        
        self.postCodeFieldView.layer.borderWidth = 1.0
        self.postCodeFieldView.layer.borderColor = UIColor.appBgSecondaryGrayColor().cgColor
        
        self.cityFieldView.layer.borderWidth = 1.0
        self.cityFieldView.layer.borderColor = UIColor.appBgSecondaryGrayColor().cgColor

        self.textViewContainer.layer.borderWidth = 1.0
        self.textViewContainer.layer.borderColor = UIColor.appBgSecondaryGrayColor().cgColor
        
        self.addressIconImageView.image = self.addressIconImageView.image?.withRenderingMode(.alwaysTemplate)
        
        self.segmentedControl.backgroundColor = UIColor.appBgSecondaryGrayColor()
        
        if let address = self.address {
            self.title = "Update Address"
            let cameraPosition = GMSCameraPosition(latitude: address.latitude, longitude: address.longitude, zoom: 15.0)
            self.mapView.animate(to: cameraPosition)
            
            self.notesTextView.text = address.additionalInfo
            
            if address.label.lowercased() == AddressLabel.home.title().lowercased() {
                self.segmentedControl.selectedSegmentIndex = AddressLabel.home.rawValue
            } else if address.label.lowercased() == AddressLabel.work.title().lowercased() {
                self.segmentedControl.selectedSegmentIndex = AddressLabel.work.rawValue
            } else if address.label.lowercased() == AddressLabel.other.title().lowercased() {
                self.segmentedControl.selectedSegmentIndex = AddressLabel.other.rawValue
            }
        } else {
            self.title = "Add Address"
            self.getCurrentLocation()
        }
        
        self.maxPostCodeCharLimit = Utility.shared.regionalInfo.country == INCountryCode ? 6 : 8
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.contentHeight.constant = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.height + 16.0
    }
    
    //MARK: My Methods
    func getCurrentLocation() {
        
        self.cityField.text = ""
        self.postCodeField.text = ""
        self.addressTextView.text = ""
        self.addressTextView.isHidden = true
        self.activityIndicator.startAnimating()
        
        self.mapView.isUserInteractionEnabled = false
        self.myLocationManager = MyLocationManager()
        self.myLocationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyKilometer, timeOut: 10.0) { (location, error) in

            self.mapView.isUserInteractionEnabled = true
            
            if let location = location {
                let cameraPosition = GMSCameraPosition(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 14.0)
                self.mapView.animate(to: cameraPosition)
            } else {
                self.activityIndicator.stopAnimating()
                self.addressTextView.isHidden = false
            }
        }
    }
    
    func getReadableAddress(gmsAddress: GMSAddress) -> String {
        return gmsAddress.lines?.first ?? ""
    }
    
    func reverseGeoCodeCoorniate(coordinate: CLLocationCoordinate2D) {
        self.recentResponseNumber += 1
        let sequenceNumber = self.recentResponseNumber
        
        self.cityField.text = ""
        self.postCodeField.text = ""
        self.addressTextView.text = ""
        self.addressTextView.isHidden = true
        self.selectedAddress = nil
        self.activityIndicator.startAnimating()
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in

            guard sequenceNumber >= self.recentResponseNumber else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            self.addressTextView.isHidden = false
            
            guard error == nil else {
                return
            }
                        
            if let address = response?.firstResult() {
                self.addressTextView.text = self.getReadableAddress(gmsAddress: address)
                
                self.postCodeField.text = address.postalCode ?? ""
                self.postCodeValidationLabel.text = ""
                
                self.cityField.text = address.locality ?? ""
                self.cityValidationLabel.text = ""
            } else {
                self.addressTextView.text = ""
                self.postCodeField.text = ""
                self.cityField.text = ""
            }
            
            self.selectedAddress = response?.firstResult()
        }
    }
    
    func validate() -> Bool {
        var isValid = true
        
        if self.postCodeField.text?.isValidPostCode() == false {
            isValid = false
            
            self.postCodeValidationLabel.text = "Please enter a valid postcode"
        } else {
            self.postCodeValidationLabel.text = ""
        }
        
        if self.cityField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            
            self.cityValidationLabel.text = "Please enter city"
        } else {
            self.cityValidationLabel.text = ""
        }
        
        return isValid
    }
    
    //MARK: My IBActions
    @IBAction func saveAddressButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        if self.isEditingAddress, self.delegate != nil, self.address != nil {
            self.updateAddress()
        } else {
            self.addAddress()
        }
    }
    
    @IBAction func textFieldChangeEditing(sender: UITextField) {
        if self.postCodeField == sender {
            self.postCodeValidationLabel.text = ""
        } else if self.cityField == sender {
            self.cityValidationLabel.text = ""
        }
    }

    @IBAction func doneBarButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
}

//MARK: UITextFieldDelegate
extension AddAddressViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength: Int?
        
        if textField == self.postCodeField {
            maxLength = self.maxPostCodeCharLimit
        } else {
            maxLength = 300
        }
        
        if let maxLength = maxLength {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        return true
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

//MARK: Webservices Methods
extension AddAddressViewController {
    func addAddress() {
        
        guard let selectedAddress = self.selectedAddress else {
            self.showAlertController(title: "", msg: "Please select an address")
            return
        }
        
        guard self.validate() else {
            return
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.addAddressButton.showLoader()
        
        let label = AddressLabel(rawValue: self.segmentedControl.selectedSegmentIndex) ?? .other
        let params: [String : Any] = ["title" : label.title(),
                                      "post_code" : self.postCodeField.text ?? "",
                                      "address" : self.addressTextView.text ?? "",
                                      "latitude" : "\(selectedAddress.coordinate.latitude)",
                                      "longitude" : "\(selectedAddress.coordinate.longitude)",
                                      "city" : self.cityField.text ?? "",
                                      "optional_note" : self.notesTextView.text ?? ""]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddresses, method: .post) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.addAddressButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.detail)
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let data = responseDict?["data"] as? [String : Any] {
                let address = Mapper<Address>().map(JSON: data)!
                self.delegate?.addAddressViewController(controller: self, didAddedAddress: address)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func updateAddress() {
        guard let address = self.address else {
            self.showAlertController(title: "", msg: "Please select an address to update")
            return
        }
        
        guard let gmsAddress = self.selectedAddress else {
            self.showAlertController(title: "", msg: "Please select an address")
            return
        }
        
        guard self.validate() else {
            return
        }
        
        let addressString = gmsAddress.lines?.first ?? ""
        let latitude = gmsAddress.coordinate.latitude
        let longitude = gmsAddress.coordinate.longitude
        let city = gmsAddress.locality ?? ""
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.addAddressButton.showLoader()
        
        let label = AddressLabel(rawValue: self.segmentedControl.selectedSegmentIndex) ?? .other
        let params: [String : Any] = ["title" : label.title(),
                                      "address" : addressString,
                                      "latitude" : "\(latitude)",
                                      "longitude" : "\(longitude)",
                                      "city" : city,
                                      "optional_note" : self.notesTextView.text ?? ""]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddresses + "/" + address.id, method: .put) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.addAddressButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.detail)
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let data = responseDict?["data"] as? [String : Any] {
                let address = Mapper<Address>().map(JSON: data)!
                self.delegate?.addAddressViewController(controller: self, didUpdateAddress: address)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}
