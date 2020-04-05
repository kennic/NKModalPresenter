//
//  NKModalController.swift
//  NKModalPresenter
//
//  Created by Nam Kennic on 4/5/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit

public enum NKModalPresentPosition {
	case top
	case left
	case bottom
	case right
	case center
	case custom(frame: CGRect)
}

public enum NKModalPresentAnimation {
	case auto
	case fromTop
	case fromLeft
	case fromBottom
	case fromRight
	case fromCenter
}

public enum NKModalDismissAnimation {
	case auto
	case toTop
	case toLeft
	case toBottom
	case toRight
	case toCenter
}

public enum NKModalDragAction {
	case started
	case ended
	case canceled
}

public protocol NKModalControllerDelegate: class {
	
	func modalController(_ controller: NKModalController, willPresent viewController: UIViewController)
	func modalController(_ controller: NKModalController, didPresent viewController: UIViewController)
	func modalController(_ controller: NKModalController, willDismiss viewController: UIViewController)
	func modalController(_ controller: NKModalController, didDismiss viewController: UIViewController)
	func modalController(_ controller: NKModalController, dragAction: NKModalDragAction)
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool
	func shouldDragDownToDismiss(modalController: NKModalController) -> Bool
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool
	
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation
	func animationDuration(modalController: NKModalController) -> TimeInterval
	func backgroundColor(modalController: NKModalController) -> UIColor
	func backgroundBlurryValue(modalController: NKModalController) -> CGFloat
	func cornerRadius(modalController: NKModalController) -> CFloat
	
}

extension NKModalControllerDelegate {
	
	func modalController(_ controller: NKModalController, willPresent viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, didPresent viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, willDismiss viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, didDismiss viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, dragAction: NKModalDragAction) {}
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool { return false }
	func shouldDragDownToDismiss(modalController: NKModalController) -> Bool { return false }
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool { return false }
	
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition { return .center }
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation { return .auto }
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation { return .auto }
	func animationDuration(modalController: NKModalController) -> TimeInterval { return 0.45 }
	func backgroundColor(modalController: NKModalController) -> UIColor { return UIColor.black.withAlphaComponent(0.75) }
	func backgroundBlurryValue(modalController: NKModalController) -> CGFloat { return 0.0 }
	func cornerRadius(modalController: NKModalController) -> CFloat { return 8.0 }
	
}

public class NKModalController: UIViewController {
	public fileprivate(set) var contentViewController: UIViewController!
	public var animatedView: UIView?
	public var delegate: NKModalControllerDelegate?

	public init(viewController: UIViewController) {
		super.init(nibName: nil, bundle: nil)
		contentViewController = viewController
		delegate = viewController as? NKModalControllerDelegate
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func present(animatedFrom view: UIView?) {
		animatedView = view
	}
	
	public override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
	}
	
}
