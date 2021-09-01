//
//  CounterCollectionNoteTableViewCell.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 13/08/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class CounterCollectionNoteTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var textField: InsetField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var counterCollectionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(counterCollectionNote: CounterCollectionField) {
        if let message : String? = counterCollectionNote.text, message != "" {
            self.counterCollectionLabel.text = message
        }
        else{
            
            self.counterCollectionLabel.isHidden = true
        }
        
    }
    
}
