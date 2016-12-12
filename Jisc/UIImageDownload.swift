//
//  UIImageDownload.swift
//  Jisc
//
//  Created by Therapy Box on 11/23/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kProfileImageNotFound = "profileImageNotFound"
let kImageNotFound = "imageNotFound"

enum kImageType {
	case profile
	case other
}

typealias imageCompletionBlock = ((_ success:Bool, _ imageData:Data?) -> Void)
typealias imageFetchCompletionBlock = (() -> Void)

let imagesPath = "\(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!)/Images/"

func imageFilePath(_ fileName:String) -> String {
	
	var isDir : ObjCBool = true
	if (!FileManager.default.fileExists(atPath: imagesPath, isDirectory: &isDir))
	{
		do {
			try FileManager.default.createDirectory(atPath: imagesPath, withIntermediateDirectories: false, attributes: nil)
		} catch {
			print("create directory error: \(error)")
		}
	}
	return imagesPath + fileName	
}

//MARK: The Visual Element

class UIImageDownload: UIImageView, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
	
	var imageType:kImageType = .profile
	var currentConnectionID:String = ""
	var indicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
	var completionBlock:imageFetchCompletionBlock?
	
	func loadImageWithLink(_ link:String, type:kImageType, completion:imageFetchCompletionBlock?) {
		if (link.isEmpty || link == hostPath) {
			loadPlaceholder()
			completion?()
		} else {
			completionBlock = completion
			image = nil
			contentMode = .scaleAspectFill
			layer.shouldRasterize = true
			layer.rasterizationScale = UIScreen.main.scale
			indicator.center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
			addSubview(indicator)
			indicator.startAnimating()
			imageType = type
			allImageConnectionsManager.cancelConnectionForContainer(self, connectionID: currentConnectionID)
			currentConnectionID = md5("\(link)\(self.frame.size)")
			allImageConnectionsManager.requestImage(link, container: self)
		}
	}
	
	func loadPlaceholder() {
		indicator.stopAnimating()
		indicator.removeFromSuperview()
		switch (imageType) {
		case .profile:
			image = UIImage(named: kProfileImageNotFound)
			break
		case .other:
			image = UIImage(named: kImageNotFound)
			break
		}
	}
	
	class func scaleImage(_ image:UIImage, toSize:CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(toSize, false, 1.0)
		image.draw(in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return scaledImage!
	}
}

//MARK: The Download Connection

class ImageConnection: NSObject, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
	
	var imageData:NSMutableData
	var request:NSMutableURLRequest
	var connection:NSURLConnection?
	var completionBlock:imageCompletionBlock?
	var connectionID:String
	var imageSize:CGSize
	
	required init(link:String, size:CGSize) {
		imageSize = size
		connectionID = md5("\(link)\(size)")
		imageData = NSMutableData()
		let url = URL(string: link)
		if (url != nil) {
			request = NSMutableURLRequest(url: url!)
		} else {
			request = NSMutableURLRequest()
		}
	}
	
	func startDownload(_ completion:@escaping imageCompletionBlock) {
		allImageConnectionsManager.runningConnections[connectionID] = self
		completionBlock = completion
		let imagePath = imageFilePath(self.connectionID)
		var imageExists = false
		if (FileManager.default.fileExists(atPath: imagePath)) {
			let data = NSMutableData(contentsOfFile: imagePath)
			if (data != nil) {
				imageExists = true
				imageData = data!
			}
		}
		
		if (imageExists) {
			completionBlock!(true, imageData as Data)
		} else {
			connection = NSURLConnection(request: request as URLRequest, delegate: self)
			connection?.start()
		}
	}
	
	//MARK: NSURLConnection Data Delegate
	
	func connection(_ connection: NSURLConnection, didReceive data: Data) {
		imageData.append(data)
	}
	
	func connectionDidFinishLoading(_ connection: NSURLConnection) {
		DispatchQueue.main.async(execute: { () -> Void in
			if (self.imageData.length > 0) {
				if (self.completionBlock != nil) {
					self.completionBlock!(true, self.imageData as Data)
				}
			} else {
				if (self.completionBlock != nil) {
					self.completionBlock!(false, nil)
				}
			}
			allImageConnectionsManager.runningConnections[self.connectionID] = nil
		})
	}
	
	//MARK: NSURLConnection Delegate
	
	func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
		DispatchQueue.main.async { () -> Void in
			if (self.completionBlock != nil) {
				self.completionBlock!(false, nil)
			}
			allImageConnectionsManager.runningConnections[self.connectionID] = nil
		}
	}
}

//MARK: The Connections Manager

let allImageConnectionsManager = ConnectionsManager()

class ConnectionsManager: NSObject {
	
	var runningConnections:[String:ImageConnection] = [String:ImageConnection]()
	var waitingImageContainers:[String:[UIImageDownload]] = [String:[UIImageDownload]]()
	
	func requestImage(_ link:String, container:UIImageDownload) {
		let connectionID = md5("\(link)\(container.frame.size)")
		
		if (waitingImageContainers[connectionID] == nil) {
			waitingImageContainers[connectionID] = [UIImageDownload]()
		}
		waitingImageContainers[connectionID]!.append(container)
		
		if (runningConnections[connectionID] == nil) {
			let connection = ImageConnection(link: link, size: container.frame.size)
			runningConnections[connectionID] = connection
			connection.startDownload({ (success, imageData) -> Void in
				DispatchQueue.main.async(execute: { () -> Void in
					if (success && imageData != nil) {
						var imageWithData = UIImage(data: imageData!)
						if (imageWithData != nil) {
							let maxSize = max(container.frame.size.width, container.frame.size.height) * UIScreen.main.scale
							if (imageWithData!.size.width > maxSize || imageWithData!.size.height > maxSize) {
								imageWithData = UIImageDownload.scaleImage(imageWithData!, toSize: CGSize(width: maxSize, height: maxSize))
							}
							let imagePath = imageFilePath(connectionID)
							try? UIImagePNGRepresentation(imageWithData!)!.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])
						}
						for (_, item) in self.waitingImageContainers[connectionID]!.enumerated() {
							item.indicator.stopAnimating()
							item.indicator.removeFromSuperview()
							if (item.currentConnectionID == connectionID) {
								item.image = imageWithData
							}
							if (item.completionBlock != nil) {
								item.completionBlock!()
							}
						}
					} else {
						for (_, item) in self.waitingImageContainers[connectionID]!.enumerated() {
							item.loadPlaceholder()
							if (item.completionBlock != nil) {
								item.completionBlock!()
							}
						}
					}
					self.waitingImageContainers[connectionID]!.removeAll()
					self.runningConnections[connectionID] = nil
				})
			})
		}
	}
	
	func cancelConnectionForContainer(_ container:UIImageDownload, connectionID:String) {
		var imageContainers = waitingImageContainers[connectionID]
		if (imageContainers != nil) {
			if (imageContainers!.contains(container)) {
				imageContainers!.remove(at: imageContainers!.index(of: container)!)
				if (imageContainers!.count == 0) {
					let connection = runningConnections[connectionID]
					connection?.completionBlock = nil
					connection?.connection?.cancel()
					runningConnections[connectionID] = nil
				}
			}
		}
	}
	
}
