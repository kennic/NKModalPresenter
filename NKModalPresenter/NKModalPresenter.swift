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
	public static let shared = NKModalPresenter()
	public private(set) var activeModalControllers: [NKModalController] = []
	
	public var topModalController: NKModalController? {
		return activeModalControllers.last
	}
	
	private var listenOnDismissEvent = true

	private init() {}
	
	@discardableResult
	public func present(viewController: UIViewController, animate: NKModalPresentAnimation? = nil, to position: NKModalPresentPosition? = nil) -> NKModalController {
		let modalController = NKModalController(viewController: viewController)
		modalController.present(animate: animate, to: position)
		
		let classType = type(of: viewController)
		viewController.swizzleInstanceMethod(classType, from: #selector(classType.dismiss(animated:completion:)), to: #selector(classType.dismissModal(animated:completion:)))
		
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
		return activeModalControllers.first(where: { $0.contentViewController == viewController || $0.contentViewController == viewController.navigationController })
	}
	
	public func modalController(containing view: UIView) -> NKModalController? {
		return activeModalControllers.first(where: { $0.contentViewController.view == view})
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
	
	@discardableResult
	public func presentAsModal(animate: NKModalPresentAnimation? = nil, to position: NKModalPresentPosition? = nil) -> NKModalController {
		NKModalPresenter.shared.present(viewController: self, animate: animate, to: position)
	}
	
	public var modalController: NKModalController? {
		return NKModalPresenter.shared.modalController(containing: self)
	}
	
	@objc public func dismissModal(animated: Bool, completion: (() -> Void)? = nil) {
		let classType = type(of: self)
		swizzleInstanceMethod(classType, from: #selector(classType.dismissModal(animated:completion:)), to: #selector(classType.dismiss(animated:completion:)))
		
		if let modal = modalController {
			modal.dismiss(animated: animated, completion: completion)
		}
		else {
			dismiss(animated: animated, completion: completion)
		}
	}
	
}

// Swizzle methods

extension UIViewController {
	
	func swizzleInstanceMethod(_ class_: AnyClass, from sel1: Selector, to sel2: Selector) {
		DispatchQueue.once {
			let originalMethod = class_getInstanceMethod(class_, sel1)
			let swizzledMethod = class_getInstanceMethod(class_, sel2)
			method_exchangeImplementations(originalMethod!, swizzledMethod!)
		}
	}
	
}

extension DispatchQueue {
	private static var _onceTracker = [String]()
	
	public class func once(file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
		let token = file + ":" + function + ":" + String(line)
		once(token: token, block: block)
	}
	
	/**
	Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
	only execute the code once even in the presence of multithreaded calls.
	
	- parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
	- parameter block: Block to execute once
	*/
	public class func once(token: String, block:()->Void) {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		
		
		if _onceTracker.contains(token) {
			return
		}
		
		_onceTracker.append(token)
		block()
	}
}
