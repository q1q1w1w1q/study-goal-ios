//
//  InstituteCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/19/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kInstituteCellNibName = "InstituteCell"
let kInstituteCellIdentifier = "InstituteCellIdentifier"

class InstituteCell: UITableViewCell {
	
	var institute:Institution?
	@IBOutlet weak var instituteName:UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		if (selected) {
			setSelected(false, animated: animated)
		}
	}
	
	func loadInstitute(_ institute:Institution) {
		self.institute = institute
		instituteName.text = self.institute?.name
		layoutIfNeeded()
	}
}
