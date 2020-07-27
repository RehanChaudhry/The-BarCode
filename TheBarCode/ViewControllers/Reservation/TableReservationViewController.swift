//
//  ReservationViewController.swift
//  TheBarCode
//
//  Created by Macbook on 24/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class TableReservationViewController: UIViewController {
    
    @IBOutlet var barNameLabel: UILabel!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var timeTextField: UITextField!
    @IBOutlet var noOfPeopleTextField: UITextField!
    @IBOutlet var cardOptionsView: UIView!
    
    @IBOutlet var visaCheckedImageView: UIImageView!
    @IBOutlet var visaLabel: UILabel!
    
    @IBOutlet var masterCheckedImageView: UIImageView!
    @IBOutlet var masterLabel: UILabel!
    
    @IBOutlet var americanExpressCheckedImageView: UIImageView!
    @IBOutlet var americanExpressLabel: UILabel!
    
    
    var bar: Bar!
    var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Table Reservation"
        self.barNameLabel.text = "Reserve your table at \(self.bar.title.value)"
     
//        self.dateTextField.delegate = self
//        self.timeTextField.delegate = self
//        self.noOfPeopleTextField.delegate = self

        self.cardOptionsView.layer.cornerRadius = 12.0
    }
    

    //MARK: MY METHODS
    func resetOptions() {
        self.visaCheckedImageView.isHidden = true
        self.masterCheckedImageView.isHidden = true
        self.americanExpressCheckedImageView.isHidden = true

    }
    
    func updateDateField() {
          let dateformatter = DateFormatter()
          dateformatter.dateFormat = "dd/MM/yyyy"
          self.dateTextField.text = dateformatter.string(from: self.selectedDate)
      }
    
        //MARK: IBAction
    @IBAction func closeBarButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func visaOptionButtonTapped(_ sender: UIButton) {
        self.resetOptions()
        self.visaCheckedImageView.isHidden = false
    }
    
    @IBAction func masterOptionButtonTapped(_ sender: UIButton) {
        self.resetOptions()
        self.masterCheckedImageView.isHidden = false
    }
    
    @IBAction func americanExpressOptionButtonTapped(_ sender: UIButton) {
        self.resetOptions()
        self.americanExpressCheckedImageView.isHidden = false
    }

    @IBAction func addPaymentMethodButtonTapped(_ sender: UIButton) {
    }
    
}


//MARK: FieldViewDelegate
extension TableReservationViewController: FieldViewDelegate {
    
    func fieldView(fieldView: FieldView, didBeginEditing textField: UITextField) {
                                
            
        if textField == self.dateTextField {
            self.updateDateField()
        }
    }
    
    func fieldView(fieldView: FieldView, didEndEditing textField: UITextField) {
        
    }
}
