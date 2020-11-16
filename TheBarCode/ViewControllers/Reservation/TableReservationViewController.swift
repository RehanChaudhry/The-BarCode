//
//  ReservationViewController.swift
//  TheBarCode
//
//  Created by Macbook on 24/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class TableReservationViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var tableHeaderView: UIView!
    
    @IBOutlet var closeBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var barNameLabel: UILabel!
    
    @IBOutlet var dateTextField: InsetField!
    @IBOutlet var timeTextField: InsetField!
    @IBOutlet var noOfPeopleTextField: InsetField!
    
    @IBOutlet var dateValidationLabel: UILabel!
    @IBOutlet var timeValidationLabel: UILabel!
    @IBOutlet var noOfPeopleValidationLabel: UILabel!
    
    @IBOutlet var dateInputView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    var bar: Bar!
    
    var cards: [CreditCard] = []
    
    var selectedCard: CreditCard?
    
    var selectedDate: Date?
    var selectedTime: Date?
    
    enum ReservationSection: Int {
        case cardsInfo = 0,
        addCard = 1,
        reservationNote = 2
        
        static func allValue() -> [ReservationSection] {
            return [.cardsInfo, .addCard, reservationNote]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Table Reservation"
        self.barNameLabel.text = "Reserve your table at \(self.bar.title.value)"
        
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.tableFooterView = UIView()
        self.tableView.register(headerFooterViewType: SectionHeaderView.self)
        self.tableView.register(cellType: CardInfoCell.self)
        self.tableView.register(cellType: AddNewCardCell.self)
        self.tableView.register(cellType: TableReserveNoteCell.self)
        
        self.dateTextField.inputView = self.dateInputView
        self.timeTextField.inputView = self.dateInputView
        
        self.datePicker.date = Date()
        
        self.dateTextField.canPaste = false
        self.timeTextField.canPaste = false
        
        self.closeBarButtonItem.image = self.closeBarButtonItem.image?.withRenderingMode(.alwaysOriginal)
    }
    
    //MARK: My Methods
    func setDateFieldValue(date: Date) {
        self.selectedDate = date
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd-MM-yyy"
        self.dateTextField.text = dateformatter.string(from: date)
        
        self.dateValidationLabel.isHidden = true
    }
    
    func setTimeFieldValue(date: Date) {
        self.selectedTime = date
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        self.timeTextField.text = dateformatter.string(from: date)
        
        self.timeValidationLabel.isHidden = true
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        if self.selectedDate == nil {
            isValid = false
            self.dateValidationLabel.isHidden = false
        } else {
            self.dateValidationLabel.isHidden = true
        }
        
        if self.selectedTime == nil {
            isValid = false
            self.timeValidationLabel.isHidden = false
        } else {
            self.timeValidationLabel.isHidden = true
        }
        
        if let noOfPeople = Int(self.noOfPeopleTextField.text!), noOfPeople > 0 {
            self.noOfPeopleValidationLabel.isHidden = true
        } else {
            self.noOfPeopleValidationLabel.isHidden = false
        }
        
        return isValid
    }
    
    func moveToreservationDetailsVC(reservation: Reservation) {
        
        let reservationDetailsNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReservationDetailsNavigation") as! UINavigationController)
        reservationDetailsNavigation.modalPresentationStyle = .fullScreen
               
        let reservationDetailsViewController = reservationDetailsNavigation.viewControllers.first as! ReservationDetailsViewController
        reservationDetailsViewController.showHeader = true
        reservationDetailsViewController.reservation = reservation
        
        self.present(reservationDetailsNavigation, animated: true, completion: nil)
    }
   
    //MARK: IBAction
    @IBAction func closeBarButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        if self.dateTextField.isFirstResponder {
            self.setDateFieldValue(date: sender.date)
        } else if self.timeTextField.isFirstResponder {
            self.setTimeFieldValue(date: self.datePicker.date)
        }
    }
    
    @IBAction func doneBarButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @IBAction func previousBarButtonTapped(sender: UIBarButtonItem) {
        if self.timeTextField.isFirstResponder {
            self.dateTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func nextBarButtonTapped(sender: UIBarButtonItem) {
        if self.dateTextField.isFirstResponder {
            self.timeTextField.becomeFirstResponder()
        } else if self.timeTextField.isFirstResponder {
            self.noOfPeopleTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func reserveTableButtonTapped(sender: UIButton) {
        if self.isDataValid() {
            let reservation = ReservationCategory.getAllDummyReservations().first!.reservations.first!
            self.moveToreservationDetailsVC(reservation: reservation)
        }
    }
}

//MARK: UITextFieldDelegate
extension TableReservationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.dateTextField {
            self.datePicker.datePickerMode = .date
            if let date = self.selectedDate {
                self.datePicker.setDate(date, animated: true)
            }
        } else if textField == self.timeTextField {
            self.datePicker.datePickerMode = .time
            if let date = self.selectedTime {
                self.datePicker.setDate(date, animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.dateTextField {
            self.setDateFieldValue(date: self.datePicker.date)
        } else if textField == self.timeTextField {
            self.setTimeFieldValue(date: self.datePicker.date)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if self.dateTextField == textField {
            self.dateValidationLabel.isHidden = true
        } else if self.timeTextField == textField {
            self.timeValidationLabel.isHidden = true
        } else if self.noOfPeopleTextField == textField {
            self.noOfPeopleValidationLabel.isHidden = true
        }
        
        return true
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension TableReservationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReservationSection.allValue().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ReservationSection.cardsInfo.rawValue {
            return self.cards.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == ReservationSection.cardsInfo.rawValue {
            let headerView = self.tableView.dequeueReusableHeaderFooterView(SectionHeaderView.self)
            headerView?.setupHeader(title: "SELECT CARD")
            headerView?.titleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            return headerView
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == ReservationSection.cardsInfo.rawValue {
            return 44.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == ReservationSection.cardsInfo.rawValue {
            
            let isFirstCell = indexPath.row == 0
            
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: CardInfoCell.self)
            
            let card = self.cards[indexPath.row]
            
            cell.setUpCell(card: card, isSelected: card.cardToken == self.selectedCard?.cardToken, canShowSelection: true)
            
            cell.maskCorners(radius: 8.0, mask: isFirstCell ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [])
            return cell
        } else if indexPath.section == ReservationSection.addCard.rawValue {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: AddNewCardCell.self)
            cell.maskCorners(radius: 8.0, mask: self.cards.count == 0 ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            return cell
        } else if indexPath.section == ReservationSection.reservationNote.rawValue {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: TableReserveNoteCell.self)
            return cell
        }
        
        return UITableViewCell()
    }
}
