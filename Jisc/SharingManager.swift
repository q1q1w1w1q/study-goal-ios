//
//  SharingManager.swift
//  Jisc
//
//  Created by Therapy Box on 11/24/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import Foundation
import Social
import MessageUI

let sharingManager = SharingManager()

enum kShareOption {
	case facebook
	case twitter
	case mail
}

class SharingManager: NSObject, MFMailComposeViewControllerDelegate {
	
	var navigationController:UINavigationController?
	var successMessage:String = ""

	func shareText(_ text:String, on:kShareOption, nvc:UINavigationController?, successText:String?) {
		if (internetAvailability == ReachabilityStatus.notReachable) {
			UIAlertView(title: localized("error"), message: localized("no_internet_connection_detected"), delegate: nil, cancelButtonTitle: localized("ok").capitalized).show()
		} else {
			successMessage = ""
			if (successText != nil) {
				successMessage = successText!
			}
			navigationController = nvc
			switch (on) {
			case .facebook:
				shareTextOnFacebook(text)
				break
			case .twitter:
				shareTextOnTwitter(text)
				break
			case .mail:
				shareTextOnMail(text)
				break
			}
		}
	}
	
	fileprivate func shareTextOnFacebook(_ text:String) {
		if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
			let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
			vc?.setInitialText(text)
			vc?.completionHandler = { (result:SLComposeViewControllerResult) in
				switch (result) {
				case .cancelled:
					break
				case .done:
					if (!self.successMessage.isEmpty) {
						AlertView.showAlert(true, message: self.successMessage, completion: nil)
					}
					break
				}
			}
			navigationController?.present(vc!, animated: true, completion: nil)
		} else {
			let message = "Go to your device's settings and log in with Facebook to be able to use this functionality"
			UIAlertView(title: "Not available", message: message, delegate: nil, cancelButtonTitle: "Ok").show()
		}
	}
	
	fileprivate func shareTextOnTwitter(_ text:String) {
		if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
			let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
			vc?.setInitialText(text)
			vc?.completionHandler = { (result:SLComposeViewControllerResult) in
				switch (result) {
				case .cancelled:
					break
				case .done:
					if (!self.successMessage.isEmpty) {
						AlertView.showAlert(true, message: self.successMessage, completion: nil)
					}
					break
				}
			}
			navigationController?.present(vc!, animated: true, completion: nil)
		} else {
			let message = "Go to your device's settings and log in with Twitter to be able to use this functionality"
			UIAlertView(title: "Not available", message: message, delegate: nil, cancelButtonTitle: "Ok").show()
		}
	}
	
	fileprivate func shareTextOnMail(_ text:String) {
		if (MFMailComposeViewController.canSendMail()) {
			let vc = MFMailComposeViewController()
			vc.mailComposeDelegate = self
			vc.setMessageBody(text, isHTML: false)
			navigationController?.present(vc, animated: true, completion: nil)
		} else {
			let message = "Go to your device's settings and log in with an e-mail account to be able to use this functionality"
			UIAlertView(title: "Not available", message: message, delegate: nil, cancelButtonTitle: "Ok").show()
		}
	}
	
	//MARK: MFMailComposeViewController Delegate
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		switch (result) {
		case MFMailComposeResult.cancelled:
			break
		case MFMailComposeResult.failed:
			break
		case MFMailComposeResult.saved:
			break
		case MFMailComposeResult.sent:
			if (!self.successMessage.isEmpty) {
				AlertView.showAlert(true, message: self.successMessage, completion: nil)
			}
			break
		default: break
		}
		controller.dismiss(animated: true, completion: nil)
	}
}
