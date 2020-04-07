//
//  UIImage+FromView.swift
//  FireLock
//
//  Created by Nam Kennic on 6/11/18.
//  Copyright © 2018 Nam Kennic. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	
	convenience init(view: UIView) {
		UIGraphicsBeginImageContext(view.frame.size)
		
		if let context = UIGraphicsGetCurrentContext() {
			view.layer.render(in: context)
			
			if let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage {
				UIGraphicsEndImageContext()
				self.init(cgImage: cgImage)
				return
			}
		}
		
		self.init()
	}
	
}

extension UIView {
	
	@available(iOS 10.0, *)
	func asImage() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: bounds)
		return renderer.image { rendererContext in
			layer.render(in: rendererContext.cgContext)
		}
	}
	
}
