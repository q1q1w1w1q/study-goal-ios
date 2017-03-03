//
//  SocialLoginVC.swift
//  Jisc
//
//  Created by Paul on 3/3/17.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Google
import Fabric
import TwitterKit

class SocialLoginVC: BaseViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		GIDSignIn.sharedInstance().uiDelegate = self
    }
	
	@IBAction func close(_ sender:UIButton?) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func facebook(_ sender:UIButton?) {
		FBSDKLoginManager().logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
			print("facebook result: \n \(result)")
			print("facebook error: \(error?.localizedDescription)")
		}
	}
	
	@IBAction func googlePlus(_ sender:UIButton?) {
		GIDSignIn.sharedInstance().signIn()
	}
	
	@IBAction func twitter(_ sender:UIButton?) {
		Twitter().logIn(with: self) { (session, error) in
			print("twitter result: \n \(session)")
			print("twitter error: \(error?.localizedDescription)")
		}
	}
	
	//MARK: - Google
	
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		navigationController?.present(viewController, animated: true, completion: nil)
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		viewController.dismiss(animated: true, completion: nil)
	}
}
