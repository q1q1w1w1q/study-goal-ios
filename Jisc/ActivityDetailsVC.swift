//
//  ActivityDetailsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/20/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let minNotesHeight:CGFloat = 80.0
let saveNoteHeight:CGFloat = 33.0

class ActivityDetailsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextViewDelegate {
	
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var contentScroll:UIScrollView!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var moduleLabel:UILabel!
	@IBOutlet weak var activityTypeLabel:UILabel!
	@IBOutlet weak var activityLabel:UILabel!
	@IBOutlet weak var timeSpentLabel:UILabel!
	@IBOutlet weak var noteTextView:UITextView!
	@IBOutlet weak var noteTextViewHeight:NSLayoutConstraint!
	@IBOutlet weak var scrollViewBottomSpace:NSLayoutConstraint!
	@IBOutlet weak var availableTrophiesTable:UITableView!
	@IBOutlet weak var myTrophiesTable:UITableView!
	@IBOutlet weak var availableTrophiesButton:UIButton!
	@IBOutlet weak var myTrophiesButton:UIButton!
	@IBOutlet weak var trophiesTablesHeight:NSLayoutConstraint!
	@IBOutlet weak var saveNoteButtonHeight:NSLayoutConstraint!
	var theActivity:ActivityLog
	var initialNote:String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
		availableTrophiesTable.register(UINib(nibName: kActivityTrophyCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kActivityTrophyCellIdentifier)
		myTrophiesTable.register(UINib(nibName: kActivityTrophyCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kActivityTrophyCellIdentifier)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		refresh()
		availableTrophiesTable.reloadData()
		myTrophiesTable.reloadData()
		view.layoutIfNeeded()
		trophiesTablesHeight.constant = availableTrophiesTable.contentSize.height
		view.layoutIfNeeded()
	}
	
	func refresh() {
		titleLabel.text = theActivity.textForDisplay()
		dateFormatter.dateFormat = "d-MM-yyyy"
		dateLabel.text = "\(localized("date").uppercased()): \(dateFormatter.string(from: theActivity.date))"
		noteTextView.text = theActivity.note
		initialNote = theActivity.note
		if (theActivity.module != nil) {
			moduleLabel.text = theActivity.module!.name
		}
		activityTypeLabel.text = theActivity.activityType.name
		activityLabel.text = theActivity.activity.name
		let hoursSpent = theActivity.timeSpent.intValue / 60
		let minutesSpent = (theActivity.timeSpent.intValue - (hoursSpent * 60))
		let secondsSpent = theActivity.timeSpent.intValue - (hoursSpent * 60) - minutesSpent
		var timeSpent = ""
		if (hoursSpent < 10) {
			if (minutesSpent < 10) {
				if (secondsSpent < 10) {
					timeSpent = "0\(hoursSpent):0\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "0\(hoursSpent):0\(minutesSpent):\(secondsSpent)"
				}
			} else {
				if (secondsSpent < 10) {
					timeSpent = "0\(hoursSpent):\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "0\(hoursSpent):\(minutesSpent):\(secondsSpent)"
				}
			}
		} else {
			if (minutesSpent < 10) {
				if (secondsSpent < 10) {
					timeSpent = "\(hoursSpent):0\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "\(hoursSpent):0\(minutesSpent):\(secondsSpent)"
				}
			} else {
				if (secondsSpent < 10) {
					timeSpent = "\(hoursSpent):\(minutesSpent):0\(secondsSpent)"
				} else {
					timeSpent = "\(hoursSpent):\(minutesSpent):\(secondsSpent)"
				}
			}
		}
		timeSpentLabel.text = timeSpent
	}
	
	required init(activity:ActivityLog) {
		theActivity = activity
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	@IBAction func goBack(_ sender:UIButton) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func availableTrophies(_ sender:UIButton) {
		availableTrophiesButton.isSelected = true
		myTrophiesButton.isSelected = false
		trophiesTablesHeight.constant = availableTrophiesTable.contentSize.height
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.availableTrophiesTable.alpha = 1.0
			self.myTrophiesTable.alpha = 0.0
		}) 
	}
	
	@IBAction func myTrophies(_ sender:UIButton) {
		availableTrophiesButton.isSelected = false
		myTrophiesButton.isSelected = true
		trophiesTablesHeight.constant = myTrophiesTable.contentSize.height
		view.layoutIfNeeded()
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.availableTrophiesTable.alpha = 0.0
			self.myTrophiesTable.alpha = 1.0
		}) 
	}
	
	func availableTrophies() -> [Trophy] {
		var array:[Trophy] = [Trophy]()
		let allTrophies = dataManager.availableTrophies()
		for (_, item) in allTrophies.enumerated() {
			if (item.activityName == theActivity.activity.englishName) {
				array.append(item)
			}
		}
		return array
	}
	
	func myTrophies() -> [Trophy] {
		var array:[Trophy] = [Trophy]()
		let allTrophies = dataManager.myTrophies()
		for (_, item) in allTrophies.enumerated() {
			if (item.trophy.activityName == theActivity.activity.englishName) {
				array.append(item.trophy)
			}
		}
		return array
	}
	
	@IBAction func editLog(_ sender:UIButton!) {
		if (theActivity.isRunning.boolValue) {
			let vc = NewActivityVC(activity: theActivity, atIndex:dataManager.runningActivities().index(of: theActivity)!)
			navigationController?.pushViewController(vc, animated: true)
		} else {
			let vc = LogActivityVC(activity: theActivity)
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	@IBAction func deleteLog(_ sender:UIButton!) {
		UIAlertView(title: localized("confirmation"), message: localized("are_you_sure_you_want_to_delete_this_activity_log"), delegate: self, cancelButtonTitle: localized("no"), otherButtonTitles: localized("yes")).show()
	}
	
	@IBAction func saveNote(_ sender:UIButton) {
		noteTextView.resignFirstResponder()
		theActivity.note = noteTextView.text
		dataManager.editActivityLog(theActivity, completion: { (success, failureReason) -> Void in
			if (success) {
				AlertView.showAlert(true, message: localized("saved_successfully"), completion: { (done) -> Void in
					self.initialNote = self.noteTextView.text
					UIView.animate(withDuration: 0.25, animations: { () -> Void in
						self.saveNoteButtonHeight.constant = 0.0
						self.view.layoutIfNeeded()
					})
				})
			} else {
				AlertView.showAlert(false, message: failureReason, completion: nil)
			}
		})
	}
	
	//MARK: UIAlertView Delegate
	
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == 1) {
			if (theActivity.isRunning.boolValue) {
				dataManager.deleteObject(theActivity)
				_ = self.navigationController?.popViewController(animated: true)
			} else {
				dataManager.deleteActivityLog(theActivity) { (success, failureReason) -> Void in
					if (success) {
						dataManager.deleteObject(self.theActivity)
						_ = self.navigationController?.popViewController(animated: true)
					} else {
						AlertView.showAlert(false, message: failureReason, completion: nil)
					}
				}
			}
		}
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var nrRows = 0
		switch (tableView) {
		case availableTrophiesTable:
			nrRows = availableTrophies().count
			break
		case myTrophiesTable:
			nrRows = myTrophies().count
			break
		default:break
		}
		return nrRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell = tableView.dequeueReusableCell(withIdentifier: kActivityTrophyCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 112.0
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let theCell:ActivityTrophyCell? = cell as? ActivityTrophyCell
		if (theCell != nil) {
			switch (tableView) {
			case availableTrophiesTable:
				let trophy = availableTrophies()[indexPath.row]
				theCell!.loadTrophy(trophy)
				break
			case myTrophiesTable:
				let trophy = myTrophies()[indexPath.row]
				theCell!.loadTrophy(trophy)
				break
			default:break
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
	
	//MARK: Close TextView
	
	@IBAction func closeTextView(_ sender:UIBarButtonItem) {
		noteTextView.resignFirstResponder()
	}
	
	//MARK: UITextView Delegate
	
	func textViewDidChange(_ textView: UITextView) {
		if (textView.text != initialNote && saveNoteButtonHeight.constant == 0) {
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				self.saveNoteButtonHeight.constant = saveNoteHeight
				self.view.layoutIfNeeded()
			})
		} else if (textView.text == initialNote && saveNoteButtonHeight.constant != 0) {
			UIView.animate(withDuration: 0.25, animations: { () -> Void in
				self.saveNoteButtonHeight.constant = 0.0
				self.view.layoutIfNeeded()
			})
		}
		let fixedWidth = textView.frame.size.width
		textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
		let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
		noteTextViewHeight.constant = max(minNotesHeight, newSize.height)
		view.layoutIfNeeded()
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollViewBottomSpace.constant = keyboardHeight - 5.0
			self.view.layoutIfNeeded()
			}, completion: { (done) -> Void in
				let newRect = self.noteTextView.convert(self.noteTextView.frame, to: self.contentScroll)
				self.contentScroll.setContentOffset(CGPoint(x: 0.0, y: newRect.origin.y - 60), animated: true)
		}) 
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.scrollViewBottomSpace.constant = 0.0
			self.view.layoutIfNeeded()
		}) 
	}
}
