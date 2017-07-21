//
//  MenuButton.swift
//  Jisc
//
//  Created by Paul on 6/6/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

enum MenuButtonType:String {
	case Feed = "Activity Feed"
	case Stats = "Stats"
	case Log = "Log"
	case Target = "Target"
	case Settings = "Settings"
	case Logout = "Logout"
}

let kButtonSelectionNotification = Notification.Name("kButtonSelectionNotification")

class MenuButton: UIView {
	
	@IBOutlet weak var button:UIButton!
	var type = MenuButtonType.Feed
	weak var parent:MenuView?
	
	class func insertSelfinView(_ view:UIView, buttonType: MenuButtonType, previousButton:MenuButton?, isLastButton:Bool, parent:MenuView) -> MenuButton {
		let button = Bundle.main.loadNibNamed("\(self.classForCoder())", owner: nil, options: nil)!.first as! MenuButton
		button.translatesAutoresizingMaskIntoConstraints = false
		button.type = buttonType
		button.parent = parent
		button.button.setTitle(buttonType.rawValue, for: .normal)
		button.button.setTitle(buttonType.rawValue, for: .selected)
        setImageOf(button:button.button, with: buttonType)
		view.addSubview(button)
        
		let leading = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
		let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1.0, constant: 0.0)
		view.addConstraints([leading, trailing])
		if let previousButton = previousButton {
			let top = NSLayoutConstraint(item: previousButton, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .top, multiplier: 1.0, constant: 0.0)
			view.addConstraint(top)
		} else {
			let top = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
			view.addConstraint(top)
		}
		if isLastButton {
			let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1.0, constant: 0.0)
			view.addConstraint(bottom)
		}
		NotificationCenter.default.addObserver(button, selector: #selector(selectedAButton(_:)), name: kButtonSelectionNotification, object: nil)
		return button
	}
	
	func selectedAButton(_ notification:Notification) {
		if let type = notification.object as? MenuButtonType {
			if self.type == type {
				button.isSelected = true
			} else {
				button.isSelected = false
				if let stats = self as? StatsMenuButton {
					stats.retract()
				}
			}
		}
	}
	
	@IBAction func buttonAction(_ sender:UIButton?) {
		switch type {
		case .Feed:
			parent?.feed()
			break
		case .Stats:
			parent?.stats()
			break
		case .Log:
			parent?.log()
			break
		case .Target:
			parent?.target()
			break
		case .Settings:
			parent?.settings()
			break
		case .Logout:
			parent?.logout()
			break
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
    private class func setImageOf(button: UIButton, with buttonType: MenuButtonType) {
        switch buttonType {
        case .Feed:
            button.setImage(UIImage(named: "FeedVCMenuIcon"), for: .normal)
            button.setImage(UIImage(named: "FeedVCMenuIconSelected"), for: .selected)
            break
        case .Stats:
            button.setImage(UIImage(named: "StatsVCMenuIcon"), for: .normal)
            button.setImage(UIImage(named: "StatsVCMenuIconSelected"), for: .selected)
            break
        case .Log:
            button.setImage(UIImage(named: "LogVCMenuIcon"), for: .normal)
            button.setImage(UIImage(named: "LogVCMenuIconSelected"), for: .selected)
            break
        case .Target:
            button.setImage(UIImage(named: "TargetVCMenuIcon"), for: .normal)
            button.setImage(UIImage(named: "TargetVCMenuIconSelected"), for: .selected)
            break
        case .Settings:
            button.setImage(UIImage(named: "settingsMenuIcon"), for: .normal)
            button.setImage(UIImage(named: "settingsMenuIconSelected"), for: .selected)
            break
        case .Logout:
            button.setImage(UIImage(named: "logoutMenuIcon"), for: .normal)
            button.setImage(UIImage(named: "logoutMenuIcon"), for: .selected)
            break
        }
    }

}

class IPadStatsMenuButton: MenuButton {
    @IBOutlet weak var arrow:UIImageView!
    @IBOutlet weak var buttonsHeight:NSLayoutConstraint!
    var expanded = false
    
    override func buttonAction(_ sender: UIButton?) {
        if expanded {
            retract()
        } else {
            expand()
        }
    }
    
    func expand() {
      expanded = true
        UIView.animate(withDuration: 0.25) {
            self.arrow.transform = CGAffineTransform(rotationAngle: .pi / 2.0)
            self.buttonsHeight.constant = 40 * 4
            self.parent?.layoutIfNeeded()
        }
    }
    
    func retract() {
        expanded = false
        UIView.animate(withDuration: 0.25) {
            self.arrow.transform = CGAffineTransform.identity
            self.buttonsHeight.constant = 0.0
            self.parent?.layoutIfNeeded()
        }
    }
    
    @IBAction func graph(_ sender:UIButton?) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToGraph()
        }
        retract()
    }
    
    @IBAction func leaderBoard(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToLeaderBoard()
        }
        retract()
    }
    
    @IBAction func eventsAttended(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToEventsAttended()
        }
        retract()
    }
    
    @IBAction func attendance(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToAttendance()
        }
        retract()
    }
    
}

class StatsMenuButton: MenuButton {
	@IBOutlet weak var arrow:UIImageView!
	@IBOutlet weak var buttonsHeight:NSLayoutConstraint!
	var expanded = false
	
    @IBOutlet weak var points: UIButton!
    @IBOutlet weak var attainment: UIButton!
    @IBOutlet weak var allActivity: UIButton!
  
	override func buttonAction(_ sender: UIButton?) {
		if expanded {
			retract()
		} else {
			expand()
		}
	}
	
	func expand() {
		expanded = true
		UIView.animate(withDuration: 0.25) {
			self.arrow.transform = CGAffineTransform(rotationAngle: .pi / 2.0)
			self.buttonsHeight.constant = 40 * 6
			self.parent?.layoutIfNeeded()
		}
	}
	
	func retract() {
		expanded = false
		UIView.animate(withDuration: 0.25) {
			self.arrow.transform = CGAffineTransform.identity
			self.buttonsHeight.constant = 0.0
			self.parent?.layoutIfNeeded()
		}
	}
	
	@IBAction func graph(_ sender:UIButton?) {
		parent?.close(nil)
		parent?.stats()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.parent?.statsViewController.goToGraph()
		}
		retract()
	}
	
	@IBAction func attainment(_ sender:UIButton?) {
		parent?.close(nil)
		parent?.stats()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.parent?.statsViewController.goToAttainment()
		}
		retract()
	}
	
	@IBAction func points(_ sender:UIButton?) {
		parent?.close(nil)
		parent?.stats()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			self.parent?.statsViewController.goToPoints()
		}
		retract()
	}
    
    @IBAction func leaderBoard(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToLeaderBoard()
        }
        retract()
    }
    
    @IBAction func eventsAttended(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToEventsAttended()
        }
        retract()
    }
    
    @IBAction func attendance(_ sender: UIButton) {
        parent?.close(nil)
        parent?.stats()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.parent?.statsViewController.goToAttendance()
        }
        retract()
    }
	
}
