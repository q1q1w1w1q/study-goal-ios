//
//  StatsVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


enum kRanking:Int {
	case lowest = 100
	case low = 69
	case middle = 49
	case high = 29
	case veryHigh = 10
}

let rankingTitles:[kRanking:String] = [.lowest:localized("low_engagement"), .low:localized("low_medium_engagement"), .middle:localized("medium_high_engagement"), .high:localized("high_engagement"), .veryHigh:localized("very_high_engagement")]
let rankingIcons:[kRanking:String] = [.lowest:"engagement_rank_1", .low:"engagement_rank_2", .middle:"engagement_rank_3", .high:"engagement_rank_4", .veryHigh:"engagement_rank_5"]

class AttainmentObject {
	var date:Date
	var moduleName:String
	var grade:String
	
	init(date:Date, moduleName:String, grade:String) {
		self.date = date
		self.moduleName = moduleName
		self.grade = grade
	}
}

class StatsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var contentScroll:UIScrollView!
	@IBOutlet weak var engagementViewLeading:NSLayoutConstraint!
	@IBOutlet weak var showEngagementDataButton:UIButton!
	@IBOutlet weak var showActivityPointsButton:UIButton!
	@IBOutlet weak var thisWeekEngagementTitle:UILabel!
	@IBOutlet weak var thisWeekEngagementRanking:UILabel!
	@IBOutlet weak var overallEngagementTitle:UILabel!
	@IBOutlet weak var overallEngagementRanking:UILabel!
	@IBOutlet weak var shareThisWeekButton:UIButton!
	@IBOutlet weak var shareThisWeekView:UIView!
	@IBOutlet weak var shareOverallButton:UIButton!
	@IBOutlet weak var shareOverallView:UIView!
	@IBOutlet weak var thisWeekEngagementIconView:UIView!
	@IBOutlet weak var overallEngagementIconView:UIView!
	@IBOutlet weak var thisWeekActivityPoints:UILabel!
	@IBOutlet weak var overallActivityPoints:UILabel!
	@IBOutlet weak var shareThisWeekActivityPointsButton:UIButton!
	@IBOutlet weak var shareThisWeekActivityPointsView:UIView!
	@IBOutlet weak var shareOverallActivityPointsButton:UIButton!
	@IBOutlet weak var shareOverallActivityPointsView:UIView!
//	var pointsRefreshTimer:NSTimer?
	@IBOutlet weak var attainmentTableView:UITableView!
	var attainmentArray = [AttainmentObject]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(StatsVC.refreshAllInfo(_:)), for: UIControlEvents.valueChanged)
		contentScroll.addSubview(refreshControl)
		contentScroll.alwaysBounceVertical = true
		attainmentTableView.register(UINib(nibName: kAttainmentCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kAttainmentCellIdentifier)
		let weekPercentage = dataManager.studentLastWeekRankings[dataManager.currentStudent!.lastWeekActivityPoints.intValue]
		let overallPercentage = dataManager.studentOverallRankings[dataManager.currentStudent!.totalActivityPoints.intValue]
		
		if (weekPercentage != nil) {
			var iconImage:UIImage?
			var foundRank = kRanking.middle
			if (weekPercentage <= kRanking.veryHigh.rawValue) {
				thisWeekEngagementTitle.text = rankingTitles[.veryHigh]!
				thisWeekEngagementRanking.text = localizedWith1Parameter("you_are_in_top", parameter: "\(weekPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.veryHigh]!)
				foundRank = .veryHigh
			} else if (weekPercentage <= kRanking.high.rawValue) {
				thisWeekEngagementTitle.text = rankingTitles[.high]!
				thisWeekEngagementRanking.text = localizedWith1Parameter("you_are_in_top", parameter: "\(weekPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.high]!)
				foundRank = .high
			} else if (weekPercentage <= kRanking.middle.rawValue) {
				thisWeekEngagementTitle.text = rankingTitles[.middle]!
				thisWeekEngagementRanking.text = localizedWith1Parameter("you_are_in_top", parameter: "\(weekPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.middle]!)
				foundRank = .middle
			} else if (weekPercentage <= kRanking.low.rawValue) {
				thisWeekEngagementTitle.text = rankingTitles[.low]!
				thisWeekEngagementRanking.text = localizedWith1Parameter("you_are_in_bottom", parameter: "\(weekPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.low]!)
				foundRank = .low
			} else {
				thisWeekEngagementTitle.text = rankingTitles[.lowest]!
				thisWeekEngagementRanking.text = localizedWith1Parameter("you_are_in_bottom", parameter: "\(weekPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.lowest]!)
				foundRank = .lowest
			}
			if (iconImage != nil) {
				let imageView = UIImageView(image: iconImage!)
				imageView.translatesAutoresizingMaskIntoConstraints = false
				thisWeekEngagementIconView.addSubview(imageView)
				let centerX = makeConstraint(thisWeekEngagementIconView, attribute1: .centerX, relation: .equal, item2: imageView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
				let centerY = makeConstraint(thisWeekEngagementIconView, attribute1: .centerY, relation: .equal, item2: imageView, attribute2: .centerY, multiplier: 1.0, constant: 0.0)
				thisWeekEngagementIconView.addConstraints([centerX, centerY])
				thisWeekEngagementIconView.layoutIfNeeded()
				
				if (foundRank == .low) {
					addKeepGoingText(imageView)
				}
			}
		} else {
			thisWeekEngagementTitle.text = localized("nothing_to_display")
			thisWeekEngagementRanking.text = localized("no_ranking_info")
		}
		
		if (overallPercentage != nil) {
			var iconImage:UIImage?
			var foundRank = kRanking.middle
			if (overallPercentage <= kRanking.veryHigh.rawValue) {
				overallEngagementTitle.text = rankingTitles[.veryHigh]!
				overallEngagementRanking.text = localizedWith1Parameter("you_are_in_top", parameter: "\(overallPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.veryHigh]!)
				foundRank = .veryHigh
			} else if (overallPercentage <= kRanking.high.rawValue) {
				overallEngagementTitle.text = rankingTitles[.high]!
				overallEngagementRanking.text = localizedWith1Parameter("you_are_in_top", parameter: "\(overallPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.high]!)
				foundRank = .high
			} else if (overallPercentage <= kRanking.middle.rawValue) {
				overallEngagementTitle.text = rankingTitles[.middle]!
				overallEngagementRanking.text = localizedWith1Parameter("you_are_in_top", parameter: "\(overallPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.middle]!)
				foundRank = .middle
			} else if (overallPercentage <= kRanking.low.rawValue) {
				overallEngagementTitle.text = rankingTitles[.low]!
				overallEngagementRanking.text = localizedWith1Parameter("you_are_in_bottom", parameter: "\(overallPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.low]!)
				foundRank = .low
			} else {
				overallEngagementTitle.text = rankingTitles[.lowest]!
				overallEngagementRanking.text = localizedWith1Parameter("you_are_in_bottom", parameter: "\(overallPercentage!)%")
				iconImage = UIImage(named: rankingIcons[.lowest]!)
				foundRank = .lowest
			}
			if (iconImage != nil) {
				let imageView = UIImageView(image: iconImage!)
				imageView.translatesAutoresizingMaskIntoConstraints = false
				overallEngagementIconView.addSubview(imageView)
				let centerX = makeConstraint(overallEngagementIconView, attribute1: .centerX, relation: .equal, item2: imageView, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
				let centerY = makeConstraint(overallEngagementIconView, attribute1: .centerY, relation: .equal, item2: imageView, attribute2: .centerY, multiplier: 1.0, constant: 0.0)
				overallEngagementIconView.addConstraints([centerX, centerY])
				overallEngagementIconView.layoutIfNeeded()
				
				if (foundRank == .low) {
					addKeepGoingText(imageView)
				}
			}
		} else {
			overallEngagementTitle.text = localized("nothing_to_display")
			overallEngagementRanking.text = localized("no_ranking_info")
		}
		
		thisWeekActivityPoints.text = ""
		overallActivityPoints.text = ""
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if (!iPad) {
			self.view.layoutIfNeeded()
			self.engagementViewLeading.constant = -self.view.frame.size.width
			self.view.layoutIfNeeded()
		}
		
		getActivityPoints { 
			
		}
	}
	
	func refreshAllInfo(_ sender:UIRefreshControl) {
		getActivityPoints { 
			sender.endRefreshing()
		}
	}
	
	func getActivityPoints(_ completion:@escaping (() -> Void)) {
		let xMGR = xAPIManager()
		xMGR.silent = true
		xMGR.getActivityPoints(kXAPIActivityPointsPeriod.Overall) { (success, result, results, error) in
			if (result != nil) {
				if let totalPoints = result!["totalPoints"] as? Int {
					dataManager.currentStudent!.totalActivityPoints = totalPoints as NSNumber
					self.overallActivityPoints.text = self.finelyFormatterNumber(dataManager.currentStudent!.totalActivityPoints)
				}
			}
			let xMGR = xAPIManager()
			xMGR.silent = true
			xMGR.getActivityPoints(kXAPIActivityPointsPeriod.SevenDays) { (success, result, results, error) in
				if (result != nil) {
					if let totalPoints = result!["totalPoints"] as? Int {
						dataManager.currentStudent!.lastWeekActivityPoints = totalPoints as NSNumber
						self.thisWeekActivityPoints.text = self.finelyFormatterNumber(dataManager.currentStudent!.lastWeekActivityPoints)
					}
				}
				self.getAttainmentData(completion)
			}
		}
	}
	
	func getAttainmentData(_ completion:@escaping (() -> Void)) {
		attainmentArray.removeAll()
		attainmentTableView.reloadData()
		let xMGR = xAPIManager()
		xMGR.silent = true
		xMGR.getAttainment { (success, result, results, error) in
			if (results != nil) {
				for (_, item) in results!.enumerated() {
					if let dictionary = item as? NSDictionary {
						if let grade = dictionary["ASSESS_AGREED_GRADE"] as? String {
							if let moduleName = dictionary["X_MOD_NAME"] as? String {
								if let dateString = dictionary["CREATED_AT"] as? String {
									dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
									if let temp = dateString.components(separatedBy: ".").first {
										if let date = dateFormatter.date(from: temp.replacingOccurrences(of: "T", with: " ")) {
											self.attainmentArray.append(AttainmentObject(date: date, moduleName: moduleName, grade: grade))
										}
									}
								}
							}
						}
					}
				}
			}
			self.attainmentArray.sort(by: { (obj1:AttainmentObject, obj2:AttainmentObject) -> Bool in
				return (obj2.date.compare(obj1.date) != .orderedDescending)
			})
			self.attainmentTableView.reloadData()
			completion()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
//		pointsRefreshTimer?.invalidate()
	}
	
//	func refreshActivityPoints() {
//		dataManager.getStudentActivityPoints(true) { (success, failureReason) -> Void in
//			self.thisWeekActivityPoints.text = self.finelyFormatterNumber(dataManager.currentStudent!.lastWeekActivityPoints)
//			self.overallActivityPoints.text = self.finelyFormatterNumber(dataManager.currentStudent!.totalActivityPoints)
//		}
//	}
	
	func addKeepGoingText(_ imageView:UIImageView) {
		let keepGoingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
		keepGoingLabel.text = localized("keep_going")
		keepGoingLabel.textAlignment = .center
		keepGoingLabel.textColor = lilacColor.withAlphaComponent(0.75)
		keepGoingLabel.backgroundColor = UIColor.clear
		keepGoingLabel.font = myriadProRegular(12)
		keepGoingLabel.numberOfLines = 2
		keepGoingLabel.translatesAutoresizingMaskIntoConstraints = false
		imageView.addSubview(keepGoingLabel)
		
		let width = makeConstraint(keepGoingLabel, attribute1: .width, relation: .equal, item2: nil, attribute2: .width, multiplier: 1.0, constant: 32.0)
		let height = makeConstraint(keepGoingLabel, attribute1: .height, relation: .equal, item2: nil, attribute2: .height, multiplier: 1.0, constant: 28.0)
		keepGoingLabel.addConstraints([width, height])
		let bottom = makeConstraint(imageView, attribute1: .bottom, relation: .equal, item2: keepGoingLabel, attribute2: .bottom, multiplier: 1.0, constant: 5)
		let centerX = makeConstraint(imageView, attribute1: .centerX, relation: .equal, item2: keepGoingLabel, attribute2: .centerX, multiplier: 1.0, constant: 0.0)
		imageView.addConstraints([bottom, centerX])
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	func finelyFormatterNumber(_ number:NSNumber) -> String {
		var digits:[Int] = [Int]()
		var text = "\(number)"
		var numberValue = number.intValue
		while (numberValue > 0) {
			let lastDigit = numberValue % 10
			numberValue = numberValue / 10
			digits.append(lastDigit)
		}
		if (digits.count > 0) {
			text = ""
			for (index, digit) in digits.enumerated() {
				if ((index > 0) && ((index % 3) == 0)) {
					text = "\(digit),\(text)"
				} else {
					text = "\(digit)\(text)"
				}
			}
		}
		return text
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func showEngagementGraph(_ sender:UIButton) {
		let vc = EngagementGraphVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func showEngagementData(_ sender:UIButton) {
		showEngagementDataButton.isSelected = true
		showEngagementDataButton.isUserInteractionEnabled = false
		showActivityPointsButton.isSelected = false
		showActivityPointsButton.isUserInteractionEnabled = true
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.engagementViewLeading.constant = 0.0
			self.view.layoutIfNeeded()
		}) 
	}
	
	@IBAction func showActivityPoints(_ sender:UIButton) {
		showEngagementDataButton.isSelected = false
		showEngagementDataButton.isUserInteractionEnabled = true
		showActivityPointsButton.isSelected = true
		showActivityPointsButton.isUserInteractionEnabled = false
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.engagementViewLeading.constant = -self.view.frame.size.width
			self.view.layoutIfNeeded()
		}) 
	}
	
	//MARK: Share this week engagement
	
	func showThisWeekSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareThisWeekButton.alpha = 0.0
			self.shareThisWeekView.alpha = 1.0
		}) 
	}
	
	func hideThisWeekSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareThisWeekButton.alpha = 1.0
			self.shareThisWeekView.alpha = 0.0
		}) 
	}
	
	@IBAction func showThisWeekSharingOptions(_ sender:UIButton) {
		showThisWeekSharingOptions()
	}
	
	@IBAction func shareThisWeekOnFacebook(_ sender:UIButton) {
		hideThisWeekSharingOptions()
		shareThisWeekRankingOn(.facebook)
	}
	
	@IBAction func shareThisWeekOnTwitter(_ sender:UIButton) {
		hideThisWeekSharingOptions()
		shareThisWeekRankingOn(.twitter)
	}
	
	@IBAction func shareThisWeekOnMail(_ sender:UIButton) {
		hideThisWeekSharingOptions()
		shareThisWeekRankingOn(.mail)
	}
	
	func shareThisWeekRankingOn(_ platform:kShareOption) {
		let weekPercentage = dataManager.studentLastWeekRankings[dataManager.currentStudent!.lastWeekActivityPoints.intValue]
		var shareText = localized("i_have_no_rank_to_share")
		if (weekPercentage != nil) {
			if (weekPercentage <= kRanking.veryHigh.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_week", parameter: "\(localized("top")) \(weekPercentage!)%")
			} else if (weekPercentage <= kRanking.high.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_week", parameter: "\(localized("top")) \(weekPercentage!)%")
			} else if (weekPercentage <= kRanking.middle.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_week", parameter: "\(localized("top")) \(weekPercentage!)%")
			} else if (weekPercentage <= kRanking.low.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_week", parameter: "\(localized("bottom")) \(weekPercentage!)%")
			} else {
				shareText = localizedWith1Parameter("comparing_my_level_this_week", parameter: "\(localized("bottom")) \(weekPercentage!)%")
			}
		}
		shareText = "\(shareText)\n\n\(localized("sent_from"))"
		sharingManager.shareText(shareText, on: platform, nvc: self.navigationController, successText: nil)
	}
	
	//MARK: Share overall engagement
	
	func showOverallSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareOverallButton.alpha = 0.0
			self.shareOverallView.alpha = 1.0
		}) 
	}
	
	func hideOverallSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareOverallButton.alpha = 1.0
			self.shareOverallView.alpha = 0.0
		}) 
	}
	
	@IBAction func showOverallSharingOptions(_ sender:UIButton) {
		showOverallSharingOptions()
	}
	
	@IBAction func shareOverallOnFacebook(_ sender:UIButton) {
		hideOverallSharingOptions()
		shareOverallRankingOn(.facebook)
	}
	
	@IBAction func shareOverallOnTwitter(_ sender:UIButton) {
		hideOverallSharingOptions()
		shareOverallRankingOn(.twitter)
	}
	
	@IBAction func shareOverallOnMail(_ sender:UIButton) {
		hideOverallSharingOptions()
		shareOverallRankingOn(.mail)
	}
	
	func shareOverallRankingOn(_ platform:kShareOption) {
		let overallPercentage = dataManager.studentOverallRankings[dataManager.currentStudent!.totalActivityPoints.intValue]
		var shareText = localized("i_have_no_rank_to_share")
		if (overallPercentage != nil) {
			if (overallPercentage <= kRanking.veryHigh.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_overall", parameter: "\(localized("top")) \(overallPercentage!)%")
			} else if (overallPercentage <= kRanking.high.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_overall", parameter: "\(localized("top")) \(overallPercentage!)%")
			} else if (overallPercentage <= kRanking.middle.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_overall", parameter: "\(localized("top")) \(overallPercentage!)%")
			} else if (overallPercentage <= kRanking.low.rawValue) {
				shareText = localizedWith1Parameter("comparing_my_level_this_overall", parameter: "\(localized("bottom")) \(overallPercentage!)%")
			} else {
				shareText = localizedWith1Parameter("comparing_my_level_this_overall", parameter: "\(localized("bottom")) \(overallPercentage!)%")
			}
		}
		shareText = "\(shareText)\n\n\(localized("sent_from"))"
		sharingManager.shareText(shareText, on: platform, nvc: self.navigationController, successText: nil)
	}
	
	//MARK: Share this week activity poins
	
	func showThisWeekActivityPointsSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareThisWeekActivityPointsButton.alpha = 0.0
			self.shareThisWeekActivityPointsView.alpha = 1.0
		}) 
	}
	
	func hideThisWeekActivityPointsSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareThisWeekActivityPointsButton.alpha = 1.0
			self.shareThisWeekActivityPointsView.alpha = 0.0
		}) 
	}
	
	@IBAction func showThisWeekActivityPointsSharingOptions(_ sender:UIButton) {
		showThisWeekActivityPointsSharingOptions()
	}
	
	@IBAction func shareThisWeekActivityPointsOnFacebook(_ sender:UIButton) {
		hideThisWeekActivityPointsSharingOptions()
		shareThisWeekActivityPointsOn(.facebook)
	}
	
	@IBAction func shareThisWeekActivityPointsOnTwitter(_ sender:UIButton) {
		hideThisWeekActivityPointsSharingOptions()
		shareThisWeekActivityPointsOn(.twitter)
	}
	
	@IBAction func shareThisWeekActivityPointsOnMail(_ sender:UIButton) {
		hideThisWeekActivityPointsSharingOptions()
		shareThisWeekActivityPointsOn(.mail)
	}
	
	func shareThisWeekActivityPointsOn(_ platform:kShareOption) {
		let shareText = localizedWith1Parameter("i_have_activity_points_this_week", parameter: thisWeekActivityPoints.text!)
		sharingManager.shareText(shareText, on: platform, nvc: self.navigationController, successText: nil)
	}
	
	//MARK: Share overall activity points
	
	func showOverallActivityPointsSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareOverallActivityPointsButton.alpha = 0.0
			self.shareOverallActivityPointsView.alpha = 1.0
		}) 
	}
	
	func hideOverallActivityPointsSharingOptions() {
		UIView.animate(withDuration: 0.25, animations: { () -> Void in
			self.shareOverallActivityPointsButton.alpha = 1.0
			self.shareOverallActivityPointsView.alpha = 0.0
		}) 
	}
	
	@IBAction func showOverallActivityPointsSharingOptions(_ sender:UIButton) {
		showOverallActivityPointsSharingOptions()
	}
	
	@IBAction func shareOverallActivityPointsOnFacebook(_ sender:UIButton) {
		hideOverallActivityPointsSharingOptions()
		shareOverallActivityPointsOn(.facebook)
	}
	
	@IBAction func shareOverallActivityPointsOnTwitter(_ sender:UIButton) {
		hideOverallActivityPointsSharingOptions()
		shareOverallActivityPointsOn(.twitter)
	}
	
	@IBAction func shareOverallActivityPointsOnMail(_ sender:UIButton) {
		hideOverallActivityPointsSharingOptions()
		shareOverallActivityPointsOn(.mail)
	}
	
	func shareOverallActivityPointsOn(_ platform:kShareOption) {
		let shareText = localizedWith1Parameter("i_have_activity_points_overall", parameter: overallActivityPoints.text!)
		sharingManager.shareText(shareText, on: platform, nvc: self.navigationController, successText: nil)
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return dataManager.myMarks().count
//		return dataManager.myAssignmentRankings.count
		return attainmentArray.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell = tableView.dequeueReusableCell(withIdentifier: kAttainmentCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 35.0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let theCell:AttainmentCell? = cell as? AttainmentCell
		if (theCell != nil) {
//			let attainment = dataManager.myMarks()[indexPath.row]
//			let assignment = dataManager.myAssignmentRankings[indexPath.row]
			let attObject = attainmentArray[(indexPath as NSIndexPath).row]
//			theCell!.loadAttainment(attainment)
//			theCell!.loadAssignmentRanking(assignment)
			theCell!.loadAttainmentObject(attObject)
		}
	}
}
