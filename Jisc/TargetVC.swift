//
//  TargetVC.swift
//  Jisc
//
//  Created by Therapy Box on 10/14/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let emptyTargetPageMessage = localized("empty_target_page_message")

class TargetVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var targetsTableView:UITableView!
	var aCellIsOpen:Bool = false
	@IBOutlet weak var emptyScreenMessage:UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		targetsTableView.register(UINib(nibName: kTargetCellNibName, bundle: Bundle.main), forCellReuseIdentifier: kTargetCellIdentifier)
		targetsTableView.contentInset = UIEdgeInsetsMake(35.0, 0, 35.0, 0)
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return UIStatusBarStyle.lightContent
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		targetsTableView.reloadData()
	}
	
	@IBAction func settings(_ sender:UIButton) {
		let vc = SettingsVC()
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func newTarget(_ sender:UIButton) {
		if isDemo {
			let alert = UIAlertController(title: "", message: localized("demo_mode_addtarget"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: localized("ok"), style: .cancel, handler: nil))
			navigationController?.present(alert, animated: true, completion: nil)
		} else {
			let vc = NewTargetVC()
			navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	//MARK: UITableView Datasource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let nrRows = dataManager.targets().count
		if (nrRows == 0) {
			emptyScreenMessage.alpha = 1.0
		} else {
			emptyScreenMessage.alpha = 0.0
		}
		return nrRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var theCell = tableView.dequeueReusableCell(withIdentifier: kTargetCellIdentifier)
		if (theCell == nil) {
			theCell = UITableViewCell()
		}
		return theCell!
	}
	
	//MARK: UITableView Delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 108.0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let theCell:TargetCell? = cell as? TargetCell
		if (theCell != nil) {
			theCell!.parent = self
			theCell!.loadTarget(dataManager.targets()[(indexPath as NSIndexPath).row], isLast:((indexPath as NSIndexPath).row == (dataManager.targets().count - 1)))
			theCell!.indexPath = indexPath
			theCell!.tableView = tableView
			theCell!.navigationController = navigationController
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (aCellIsOpen) {
			tableView.reloadData()
		} else {
			let target = dataManager.targets()[(indexPath as NSIndexPath).row]
			let vc = TargetDetailsVC(target: target, index: (indexPath as NSIndexPath).row)
			navigationController?.pushViewController(vc, animated: true)
		}
	}
}
