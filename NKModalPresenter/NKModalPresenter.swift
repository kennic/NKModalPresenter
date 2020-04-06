//
//  NKModalPresenter.swift
//  NKModalPresenter
//
//  Created by Nam Kennic on 4/4/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit

public class NKModalPresenter {
	static let shared = NKModalPresenter()

	private init() {
		
	}
	
	@discardableResult
	public func present(viewController: UIViewController, animatedFrom view: UIView? = nil) -> NKModalController {
		let modalController = NKModalController(viewController: viewController)
		modalController.present(animatedFrom: view)
		return modalController
	}
	
}
