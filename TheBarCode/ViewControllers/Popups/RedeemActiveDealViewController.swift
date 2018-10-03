//
//  RedeemActiveDealViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class RedeemActiveDealViewController: UIViewController {

    @IBOutlet weak var hiddenField: UITextField!
    
    @IBOutlet weak var codeField1: UITextField!
    @IBOutlet weak var codeField2: UITextField!
    @IBOutlet weak var codeField3: UITextField!
    @IBOutlet weak var codeField4: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeUserInterface()

        // Do any additional setup after loading the view.
        hiddenField.becomeFirstResponder()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hiddenField.becomeFirstResponder()

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
     //
    */
    
    func customizeUserInterface() {
        codeField1.addBorders(edges: [.bottom], color: .white, thickness: 1.0)
        codeField2.addBorders(edges: [.bottom], color: .white, thickness: 1.0)
        codeField3.addBorders(edges: [.bottom], color: .white, thickness: 1.0)
        codeField4.addBorders(edges: [.bottom], color: .white, thickness: 1.0)
    }
    
    func resetField() {
        codeField1.text = ""
        codeField2.text = ""
        codeField3.text = ""
        codeField4.text = ""
    }
    
    //MARK: IBActions
    @IBAction func textFieldTextDidChanged(_ sender: Any) {
        
        let text = hiddenField.text!
        resetField()
        
        for (index, char) in text.enumerated() {
            if index == 0 {
                codeField1.text = "\(char)"
            } else if index == 1 {
                codeField2.text = "\(char)"
            } else if index == 2 {
                codeField3.text = "\(char)"
            } else if index == 3 {
                codeField4.text = "\(char)"
            } else {
                break
            }
        }
        
        if text.count >= 4 {
          //  verifyCode(code: text)
        }
        
       // continueButton.isEnabled = text.count >= 4
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
    }
}

extension RedeemActiveDealViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
