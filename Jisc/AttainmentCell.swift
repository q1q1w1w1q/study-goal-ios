//
//  AttainmentCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/27/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kAttainmentCellNibName = "AttainmentCell"
let kAttainmentCellIdentifier = "AttainmentCellIdentifier"

class AttainmentCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel:UILabel!
	@IBOutlet weak var positionLabel:UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
//	func loadAttainment(mark:Mark) {
//		nameLabel.text = mark.name
//		var sum = 0
//		for (_, item) in mark.values.enumerate() {
//			let value = item as? MarkValue
//			if (value != nil) {
//				sum += value!.value.integerValue
//			}
//		}
//		positionLabel.text = "\(sum)"
//	}
	
//	func loadAssignmentRanking(ranking:(name:String, rank:Int)) {
//		nameLabel.text = ranking.name
//		positionLabel.text = "\(ranking.rank)%"
//	}
	
	func loadAttainmentObject(_ object:AttainmentObject) {
		dateFormatter.dateFormat = "dd/MM/yy"
		nameLabel.text = "\(dateFormatter.string(from: object.date)) \(object.moduleName)"
//		let percentage = (Int)((object.points / object.maxPoints) * 100)
//		let percentage = (Int)(object.percentage)
		positionLabel.text = object.grade
	}
}
