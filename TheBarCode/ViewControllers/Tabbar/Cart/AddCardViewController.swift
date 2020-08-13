//
//  AddCardViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 13/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Stripe

class AddCardViewController: UIViewController {

    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    @IBOutlet var cardField: UITextField!
    @IBOutlet var expiryField: InsetField!
    @IBOutlet var cvcField: InsetField!
    
    @IBOutlet var nameField: InsetField!
    @IBOutlet var addressField: InsetField!
    @IBOutlet var postalCodeField: InsetField!
    @IBOutlet var stateField: InsetField!
    @IBOutlet var cityField: InsetField!
    @IBOutlet var countryField: InsetField!
    
    @IBOutlet var cardValidationLabel: UILabel!
    @IBOutlet var expiryValidationLabel: UILabel!
    @IBOutlet var cvcValidationLabel: UILabel!
    
    @IBOutlet var nameValidationLabel: UILabel!
    @IBOutlet var addressValidationLabel: UILabel!
    @IBOutlet var postalCodeValidationLabel: UILabel!
    @IBOutlet var stateValidationLabel: UILabel!
    @IBOutlet var cityValidationLabel: UILabel!
    @IBOutlet var countryValidationLabel: UILabel!
    
    @IBOutlet var cardIconImageView: UIImageView!
    
    @IBOutlet var fieldInputView: UIView!
    @IBOutlet var pickerView: UIPickerView!
    
    lazy var countries: [Country] = {
        return Country.allCountries()
    }()
    var selectedCountry: Country?
    
    lazy var months: [Month] = {
        return Month.allValues
    }()
    
    lazy var years: [String] = {
        var years: [String] = []
        for i in 2020...2060 {
            years.append("\(i)")
        }
        return years
    }()
    
    var selectedExpiry: (month: Month, year: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.expiryField.canPaste = false
        self.cvcField.canPaste = false
        self.countryField.canPaste = false
        
        self.expiryField.inputView = self.fieldInputView
        self.countryField.inputView = self.fieldInputView
        
        self.closeBarButton.image = self.closeBarButton.image?.withRenderingMode(.alwaysOriginal)
    }
    
    func handleExpirySelection(month: Month, year: String) {
        self.selectedExpiry = (month, year)
        self.expiryField.text = month.displayableValue().full + " " + year
        self.expiryValidationLabel.isHidden = true
    }
    
    func handleCountrySelection(country: Country) {
        self.selectedCountry = country
        self.countryField.text = country.name
        self.countryValidationLabel.isHidden = true
    }

    func validate() -> Bool {
        var isValid = true
        
        let cardNumber = STPCardValidator.sanitizedNumericString(for: self.cardField.text!)
        if STPCardValidator.validationState(forNumber: cardNumber, validatingCardBrand: true) != .valid {
            isValid = false
            self.cardValidationLabel.isHidden = false
        }
        let year = self.selectedExpiry?.year.suffix(2) ?? ""
        if STPCardValidator.validationState(forExpirationYear: "\(year)", inMonth: self.selectedExpiry?.month.displayableValue().numeric ?? "") != .valid {
            isValid = false
            self.expiryValidationLabel.isHidden = false
        }
        
        let brand = STPCardValidator.brand(forNumber: cardNumber)
        if STPCardValidator.validationState(forCVC: self.cvcField.text!, cardBrand: brand) != .valid {
            isValid = false
            self.cvcValidationLabel.isHidden = false
        }
        
        if self.nameField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            self.nameValidationLabel.isHidden = false
        }
        
        if self.addressField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            self.addressValidationLabel.isHidden = false
        }
        
        if self.postalCodeField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            self.postalCodeValidationLabel.isHidden = false
        }
        
        if self.stateField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            self.stateValidationLabel.isHidden = false
        }
        
        if self.cityField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            self.cityValidationLabel.isHidden = false
        }
        
        if self.countryField.text?.trimWhiteSpaces().count == 0 {
            isValid = false
            self.countryValidationLabel.isHidden = false
        }
        
        return isValid
    }
    
    //MARK: IBActions
    @IBAction func closeBarButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCardButtonTapped(sender: UIButton) {
        if self.validate() {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func nextBarButtonTapped(sender: UIBarButtonItem) {
        if self.expiryField.isFirstResponder {
            self.cvcField.becomeFirstResponder()
        }
        
    }
    
    @IBAction func previousBarButtonTapped(sender: UIBarButtonItem) {
        if self.expiryField.isFirstResponder {
            self.cardField.becomeFirstResponder()
        } else if self.countryField.isFirstResponder {
            self.stateField.becomeFirstResponder()
        }
    }
    
    @IBAction func doneBarButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldDidChangeEditing(sender: UITextField) {
        if sender == self.cardField {
            self.cardValidationLabel.isHidden = true
        } else if sender == self.expiryField {
            self.expiryValidationLabel.isHidden = true
        } else if sender == self.cvcField {
            self.cvcValidationLabel.isHidden = true
        } else if sender == self.nameField {
            self.nameValidationLabel.isHidden = true
        } else if sender == self.addressField {
            self.addressValidationLabel.isHidden = true
        } else if sender == self.postalCodeField {
            self.postalCodeValidationLabel.isHidden = true
        } else if sender == self.stateField {
            self.stateValidationLabel.isHidden = true
        } else if sender == self.cityField {
            self.cityValidationLabel.isHidden = true
        } else if sender == self.countryField {
            self.countryValidationLabel.isHidden = true
        }
    }
}

//MARK: UITextFieldDelegate
extension AddCardViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.cardField {
            var result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            result = STPCardValidator.sanitizedNumericString(for: result)
            
            if STPCardValidator.validationState(forNumber: result, validatingCardBrand: true) == .invalid {
                return false
            }
            
            let attributedString = NSMutableAttributedString(string: result, attributes: [:])
            var cardSpacing: [Int] = []
            
            let currentBrand = STPCardValidator.brand(forNumber: result)
            if currentBrand == .amex {
                cardSpacing = [3, 9]
            } else {
                cardSpacing = [3, 7, 11]
            }
            
            for i in 0..<attributedString.length {
                if cardSpacing.contains(i) {
                    attributedString.addAttribute(
                        .kern,
                        value: NSNumber(value: 5),
                        range: NSRange(location: i, length: 1))
                } else {
                    attributedString.addAttribute(
                        .kern,
                        value: NSNumber(value: 0),
                        range: NSRange(location: i, length: 1))
                }
            }
            
            textField.attributedText = attributedString
            
            if attributedString.length == 0 {
                self.cardIconImageView.image = UIImage(named: "icon_card")?.withRenderingMode(.alwaysTemplate)
            } else {
                self.cardIconImageView.image = STPImageLibrary.templatedBrandImage(for: currentBrand).withRenderingMode(.alwaysTemplate)
            }
            
            self.cardValidationLabel.isHidden = true
            
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.expiryField {
            self.pickerView.reloadAllComponents()
            if let month = self.selectedExpiry?.month,
                let year = self.selectedExpiry?.year,
                let monthIndex = self.months.firstIndex(where: {$0 == month}),
                let yearIndex = self.years.firstIndex(where: {$0 == year}) {
                self.pickerView.selectRow(monthIndex, inComponent: 0, animated: true)
                self.pickerView.selectRow(yearIndex, inComponent: 1, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
                self.pickerView.selectRow(0, inComponent: 1, animated: true)
            }
        } else if textField == self.countryField {
            self.pickerView.reloadAllComponents()
            if let country = self.selectedCountry,
                let index = self.countries.firstIndex(where: {$0.id == country.id}) {
                self.pickerView.selectRow(index, inComponent: 0, animated: true)
            } else {
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.expiryField {
            let month = self.pickerView.selectedRow(inComponent: 0)
            let year = self.pickerView.selectedRow(inComponent: 1)
            self.handleExpirySelection(month: self.months[month], year: self.years[year])
        } else if textField == self.countryField {
            let index = self.pickerView.selectedRow(inComponent: 0)
            let country = self.countries[index]
            self.handleCountrySelection(country: country)
        }
    }
}

//MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension AddCardViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.expiryField.isFirstResponder {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.expiryField.isFirstResponder {
            if component == 0 {
                return self.months.count
            } else {
                return self.years.count
            }
        } else {
            return self.countries.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var width = pickerView.frame.width

        var title: String = ""
        
        if self.expiryField.isFirstResponder {
            width = pickerView.frame.width/2.0 - 30.0
            if component == 0 {
                title = self.months[row].displayableValue().full
            } else {
                title = self.years[row]
            }
        } else if self.countryField.isFirstResponder {
            title = self.countries[row].name
        }
            
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30.0))
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 16.0),
                                                         
                                                         NSAttributedStringKey.foregroundColor : UIColor.white,
                                                         NSAttributedStringKey.paragraphStyle : paraStyle]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        titleLabel.attributedText = attributedTitle
        
        return titleLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.expiryField.isFirstResponder {
            let month = pickerView.selectedRow(inComponent: 0)
            let year = pickerView.selectedRow(inComponent: 1)
            self.handleExpirySelection(month: self.months[month], year: self.years[year])
        } else if self.countryField.isFirstResponder {
            let country = self.countries[row]
            self.handleCountrySelection(country: country)
        }
        
        
    }
}


