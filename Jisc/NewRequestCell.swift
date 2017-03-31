//
//  NewRequestCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/26/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kNewRequestCellNibName = "NewRequestCell"
let kNewRequestCellIdentifier = "NewRequestCellIdentifier"

class NewRequestCell: BasicSearchCell {

	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		loadProfilePicture("")
	}
	
	func loadFriendRequest(_ request:FriendRequest) {
		theFriendRequest = request
		nameLabel.text = "\(request.firstName) \(request.lastName)"
		loadProfilePicture("\(hostPath)\(request.photo)")
	}
	
	@IBAction func confirmRequest(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_acceptrequest"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			parent?.navigationController?.present(alert, animated: true, completion: nil)
		} else {
			if (theFriendRequest != nil) {
				parent?.friendRequestToTakeActionWith = theFriendRequest
				parent?.acceptThisFriendRequest(theFriendRequest!)
				iPadParent?.friendRequestToTakeActionWith = theFriendRequest
				iPadParent?.acceptThisFriendRequest(theFriendRequest!)
			}
		}
	}
	
	@IBAction func deleteRequest(_ sender:UIButton) {
		if demo() {
			let alert = UIAlertController(title: "", message: localized("demo_mode_deleterequest"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			parent?.navigationController?.present(alert, animated: true, completion: nil)
		} else {
			parent?.friendRequestToTakeActionWith = theFriendRequest
			parent?.deleteFriendRequest({ (success, result, results, error) -> Void in
				self.parent?.refreshData()
				AlertView.showAlert(true, message: localized("deleted_successfully"), completion: nil)
			})
			
			iPadParent?.friendRequestToTakeActionWith = theFriendRequest
			iPadParent?.deleteFriendRequest({ (success, result, results, error) -> Void in
				self.iPadParent?.refreshData()
				AlertView.showAlert(true, message: localized("deleted_successfully"), completion: nil)
			})
		}
	}
}
