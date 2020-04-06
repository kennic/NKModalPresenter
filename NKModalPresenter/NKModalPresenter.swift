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
	public private(set) var activeModalControllers: [NKModalController] = []

	private init() {
		activeModalControllers = []
	}
	
	@discardableResult
	public func present(viewController: UIViewController, animatedFrom view: UIView? = nil) -> NKModalController {
		let modalController = NKModalController(viewController: viewController)
		modalController.present(animatedFrom: view)
		activeModalControllers.append(modalController)
		return modalController
	}
	
	public func dismiss(viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		guard let modalController = modalController(containing: viewController) else { return }
		if let index = activeModalControllers.firstIndex(of: modalController) {
			activeModalControllers.remove(at: index)
		}
		modalController.dismiss(animated: animated, completion: completion)
	}
	
	public func dismissTopModalController(animated: Bool, completion: (() -> Void)? = nil) {
		guard let topModalController = activeModalControllers.last else { return }
		topModalController.dismiss(animated: animated, completion: completion)
		if let index = activeModalControllers.firstIndex(of: topModalController) {
			activeModalControllers.remove(at: index)
		}
	}
	
	public func dismissAll(animated: Bool, completion: (() -> Void)? = nil) {
		let lastModalController = activeModalControllers.last
		activeModalControllers.forEach { (modalController) in
			modalController.dismiss(animated: animated, completion: modalController == lastModalController ? completion : nil)
		}
		activeModalControllers.removeAll()
	}
	
	public func modalController(containing viewController: UIViewController) -> NKModalController? {
		for modalController in activeModalControllers {
			if modalController.contentViewController == viewController || modalController.contentViewController == viewController.navigationController {
				return modalController
			}
		}
		
		return nil
	}
	
	public func modalController(containing view: UIView) -> NKModalController? {
		for modalController in activeModalControllers {
			if modalController.contentViewController.view == view {
				return modalController
			}
		}
		
		return nil
	}
	
}

extension UIViewController {
	
	var modalController: NKModalController? {
		return NKModalPresenter.shared.modalController(containing: self)
	}
	
}
