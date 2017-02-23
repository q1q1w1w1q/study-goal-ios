//
//  CheckinVC.swift
//  Jisc
//
//  Created by Paul on 2/23/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class CheckinVC: BaseViewController {
	
	@IBOutlet weak var entryField:UILabel!
	var currentPin = ""

    override func viewDidLoad() {
        super.viewDidLoad()
		entryField.adjustsFontSizeToFitWidth = true
		entryField.text = currentPin
    }

	@IBAction func digit(_ sender:UIButton) {
		currentPin = currentPin + "\(sender.tag)"
		entryField.text = currentPin
		view.layoutIfNeeded()
	}
	
	@IBAction func backspace(_ sender:UIButton?) {
		if !currentPin.isEmpty {
			currentPin = currentPin.substring(to: currentPin.characters.index(before: currentPin.characters.endIndex))
			entryField.text = currentPin
			view.layoutIfNeeded()
		}
	}
}
