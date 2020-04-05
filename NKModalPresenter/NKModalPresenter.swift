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
	
	public func present(viewController: UIViewController, animatedFrom view: UIView) -> NKModalController {
		let modalController = NKModalController(viewController: viewController)
		return modalController
	}
	
}
