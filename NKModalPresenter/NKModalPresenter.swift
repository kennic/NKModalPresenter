//
//  NKModalPresenter.swift
//  NKModalPresenter
//
//  Created by Nam Kennic on 4/4/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit

extension Array where Element: Equatable {
	
	mutating func remove(element: Element) {
		if let index = self.firstIndex(of: element) {
			self.remove(at: index)
		}
	}
	
}

public class NKModalPresenter {
	static let shared = NKModalPresenter()
	public private(set) var activeModalControllers: [NKModalController] = []
	private var listenOnDismissEvent = true

	private init() {}
	
	@discardableResult
	public func present(viewController: UIViewController, animatedFrom view: UIView? = nil) -> NKModalController {
		let modalController = NKModalController(viewController: viewController)
		modalController.present(animatedFrom: view)
		NotificationCenter.default.addObserver(self, selector: #selector(onModalControllerDismissed), name: NKModalController.didDismiss, object: modalController)
		activeModalControllers.append(modalController)
		return modalController
	}
	
	public func dismiss(viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
		guard let modalController = modalController(containing: viewController) else { return }
		activeModalControllers.remove(element: modalController)
		modalController.dismiss(animated: animated, completion: completion)
	}
	
	public func dismissTopModalController(animated: Bool, completion: (() -> Void)? = nil) {
		guard let topModalController = activeModalControllers.last else { return }
		topModalController.dismiss(animated: animated, completion: completion)
		activeModalControllers.remove(element: topModalController)
	}
	
	public func dismissAll(animated: Bool, completion: (() -> Void)? = nil) {
		listenOnDismissEvent = false
		let lastModalController = activeModalControllers.last
		activeModalControllers.forEach { (modalController) in
			modalController.dismiss(animated: animated, completion: modalController == lastModalController ? completion : nil)
		}
		activeModalControllers.removeAll()
		listenOnDismissEvent = true
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
	
	@objc func onModalControllerDismissed(_ notification: Notification) {
		guard listenOnDismissEvent, let modalController = notification.object as? NKModalController else { return }
		NotificationCenter.default.removeObserver(modalController)
		activeModalControllers.remove(element: modalController)
	}
	
	deinit {
		activeModalControllers.removeAll()
	}
	
}

extension UIViewController {
	
	var modalController: NKModalController? {
		return NKModalPresenter.shared.modalController(containing: self)
	}
	
}
