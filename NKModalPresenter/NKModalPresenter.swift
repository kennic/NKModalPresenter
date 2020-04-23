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
	public func present(viewController: UIViewController, animatedFrom view: UIView? = nil) -> NKModalController {
		let modalController = NKModalController(viewController: viewController)
		modalController.present(animatedFrom: view)
		
//		let classType = type(of: viewController)
//		viewController.swizzleInstanceMethod(classType, from: #selector(classType.dismiss(animated:completion:)), to: #selector(classType.dismissModal(animated:completion:)))
		
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
	public func presentAsModal(animatedFrom view: UIView? = nil) -> NKModalController {
		NKModalPresenter.shared.present(viewController: self, animatedFrom: view)
	}
	
	public var modalController: NKModalController? {
		return NKModalPresenter.shared.modalController(containing: self)
	}
	
	@objc public func dismissModal(animated: Bool, completion: (() -> Void)? = nil) {
//		let classType = type(of: self)
//		swizzleInstanceMethod(classType, from: #selector(classType.dismissModal(animated:completion:)), to: #selector(classType.dismiss(animated:completion:)))
		
		if let modal = modalController {
			modal.dismiss(animated: animated, completion: completion)
		}
		else {
			dismiss(animated: animated, completion: completion)
		}
	}
	
}

// Swizzle methods

//extension UIViewController {
//
//	private func _swizzleMethod(_ class_: AnyClass, from selector1: Selector, to selector2: Selector, isClassMethod: Bool) {
//		let c: AnyClass
//		if isClassMethod {
//			guard let c_ = object_getClass(class_) else { return }
//			c = c_
//		}
//		else {
//			c = class_
//		}
//
//		guard let method1: Method = class_getInstanceMethod(c, selector1),
//			let method2: Method = class_getInstanceMethod(c, selector2) else
//		{
//			return
//		}
//
//		if class_addMethod(c, selector1, method_getImplementation(method2), method_getTypeEncoding(method2)) {
//			class_replaceMethod(c, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))
//		}
//		else {
//			method_exchangeImplementations(method1, method2)
//		}
//	}
//
//	/// Instance-method swizzling.
//	fileprivate func swizzleInstanceMethod(_ class_: AnyClass, from sel1: Selector, to sel2: Selector) {
//		_swizzleMethod(class_, from: sel1, to: sel2, isClassMethod: false)
//	}
//	
//}
