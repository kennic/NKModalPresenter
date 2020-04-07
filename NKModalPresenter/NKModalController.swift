//
//  NKModalController.swift
//  NKModalPresenter
//
//  Created by Nam Kennic on 4/5/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit

public enum NKModalPresentPosition: Equatable {
	case top
	case left
	case bottom
	case right
	case center
	case fullscreen
	case custom(frame: CGRect)
}

public enum NKModalPresentAnimation: Equatable {
	case auto
	case fromTop
	case fromLeft
	case fromBottom
	case fromRight
	case fromCenter(scale: CGFloat)
}

public enum NKModalDismissAnimation: Equatable {
	case auto
	case toTop
	case toLeft
	case toBottom
	case toRight
	case toCenter(scale: CGFloat)
}

public enum NKModalDragAction: Equatable {
	case started
	case ended
	case canceled
}

public protocol NKModalControllerDelegate {
	
	func modalController(_ controller: NKModalController, willPresent viewController: UIViewController)
	func modalController(_ controller: NKModalController, didPresent viewController: UIViewController)
	func modalController(_ controller: NKModalController, willDismiss viewController: UIViewController)
	func modalController(_ controller: NKModalController, didDismiss viewController: UIViewController)
	func modalController(_ controller: NKModalController, dragAction: NKModalDragAction)
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool
	func shouldDragDownToDismiss(modalController: NKModalController) -> Bool
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool
	
	func presentingViewController(modalController: NKModalController) -> UIViewController?
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation
	func animationDuration(modalController: NKModalController) -> TimeInterval
	func backgroundColor(modalController: NKModalController) -> UIColor
	func backgroundBlurryValue(modalController: NKModalController) -> CGFloat
	func cornerRadius(modalController: NKModalController) -> CGFloat
	
}

public extension NKModalControllerDelegate {
	
	func modalController(_ controller: NKModalController, willPresent viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, didPresent viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, willDismiss viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, didDismiss viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, dragAction: NKModalDragAction) {}
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool { return false }
	func shouldDragDownToDismiss(modalController: NKModalController) -> Bool { return false }
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool { return false }
	
	func presentingViewController(modalController: NKModalController) -> UIViewController? { return nil }
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition { return .center }
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation { return .auto }
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation { return .auto }
	func animationDuration(modalController: NKModalController) -> TimeInterval { return 0.45 }
	func backgroundColor(modalController: NKModalController) -> UIColor { return UIColor.black.withAlphaComponent(0.75) }
	func backgroundBlurryValue(modalController: NKModalController) -> CGFloat { return 0.0 }
	func cornerRadius(modalController: NKModalController) -> CGFloat { return 8.0 }
	
}

extension NKModalPresentPosition {
	
	func toPresentAnimation(view: UIView) -> NKModalPresentAnimation {
		switch self {
		case .top:
			return .fromTop
		case .left:
			return .fromLeft
		case .bottom:
			return .fromBottom
		case .right:
			return .fromRight
		case .center:
			return .fromCenter(scale: 0.8)
		case .fullscreen:
			return .fromBottom
		case .custom(frame: let frame):
			let viewSize = view.frame.size
			let origin = frame.origin
			if origin.x == 0 {
				return .fromLeft
			}
			else if origin.y == 0 {
				return .fromBottom
			}
			else if origin.x > viewSize.width/2 {
				return .fromRight
			}
			else if origin.y > viewSize.height/2 {
				return .fromBottom
			}
			else {
				return .fromCenter(scale: 0.8)
			}
		}
	}
	
	func toDismissAnimation(view: UIView) -> NKModalDismissAnimation {
		switch self {
		case .top:
			return .toTop
		case .left:
			return .toLeft
		case .bottom:
			return .toBottom
		case .right:
			return .toRight
		case .center:
			return .toCenter(scale: 0.8)
		case .fullscreen:
			return .toBottom
		case .custom(frame: let frame):
			let viewSize = view.frame.size
			let origin = frame.origin
			if origin.x == 0 {
				return .toLeft
			}
			else if origin.y == 0 {
				return .toBottom
			}
			else if origin.x > viewSize.width/2 {
				return .toRight
			}
			else if origin.y > viewSize.height/2 {
				return .toBottom
			}
			else {
				return .toCenter(scale: 0.8)
			}
		}
	}
	
}

extension UIWindow {
	static var keyWindow: UIWindow? {
		if #available(iOS 13, *) {
			return UIApplication.shared.windows.first { $0.isKeyWindow }
		} else {
			return UIApplication.shared.keyWindow
		}
	}
}

// MARK: - NKModalController

public class NKModalController: UIViewController {
	public static let willPresent = Notification.Name(rawValue: "NKModalControllerWillPresent")
	public static let didPresent = Notification.Name(rawValue: "NKModalControllerDidPresent")
	public static let willDismiss = Notification.Name(rawValue: "NKModalControllerWillDismiss")
	public static let didDismiss = Notification.Name(rawValue: "NKModalControllerDidDismiss")
	
	public fileprivate(set) var contentViewController: UIViewController!
	public fileprivate(set) var isPresenting = false
	public fileprivate(set) var isDismissing = false
	public var animatedView: UIView?
	public var lastAnimatedViewAlpha: CGFloat = 1.0
	public var delegate: NKModalControllerDelegate?
	public var enableDragDownToDismiss = false
	
	// Default values
	let backgroundColor = UIColor.black.withAlphaComponent(0.8)
	let animationDuration: TimeInterval = 0.45
	let cornerRadius: CGFloat = 8.0
	
	let containerView = UIView()
	var window: UIWindow?
	var lastWindow: UIWindow?
	var lastPosition: (container: UIView, frame: CGRect)?

	public init(viewController: UIViewController) {
		super.init(nibName: nil, bundle: nil)
		
		modalTransitionStyle = .crossDissolve
		modalPresentationStyle = .overCurrentContext
		modalPresentationCapturesStatusBarAppearance = true
		
		contentViewController = viewController
		
		delegate = viewController as? NKModalControllerDelegate
		if delegate == nil, let navigationController = viewController as? UINavigationController {
			delegate = navigationController.topViewController as? NKModalControllerDelegate
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: -
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .clear
		view.addSubview(containerView)
	}
	
	// MARK: -
	
	public func present(animatedFrom view: UIView?) {
		guard !isPresenting else { return }
		isPresenting = true
		
		delegate?.modalController(self, willPresent: contentViewController)
		NotificationCenter.default.post(name: NKModalController.willPresent, object: self, userInfo: nil)
		
		animatedView = view
		if let container = contentViewController.view.superview {
			lastPosition = (container, contentViewController.view.frame)
		}
		lastAnimatedViewAlpha = view?.alpha ?? contentViewController.view.alpha
		
		var presentingViewController = delegate?.presentingViewController(modalController: self)
		if presentingViewController == nil {
			modalPresentationStyle = .fullScreen
			lastWindow = UIWindow.keyWindow
			
			let containerViewController = NKModalContainerViewController()
			containerViewController.contentViewController = contentViewController
			presentingViewController = containerViewController
			
			if #available(iOS 13.0, *) {
				if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
					window = UIWindow(windowScene: scene)
				}
			}
			
			if window == nil {
				window = UIWindow(frame: UIScreen.main.bounds)
			}
			
			window?.windowLevel = .normal
			window?.rootViewController = presentingViewController
			window?.makeKeyAndVisible()
		}
		
		presentingViewController?.present(self, animated: false, completion: {
			self.showView()
		})
	}
	
	func showView() {
		let startProperties = startFrame()
		
		containerView.addSubview(contentViewController.view)
		containerView.frame = startProperties.frame
		contentViewController.view.frame = containerView.bounds
		
		if startProperties.scale != 1.0 {
			containerView.transform = CGAffineTransform(scaleX: startProperties.scale, y: startProperties.scale)
			containerView.alpha = 0.0
		}
		
		updateLayout(duration: nil) {
			self.isPresenting = false
			self.delegate?.modalController(self, didPresent: self.contentViewController)
			NotificationCenter.default.post(name: NKModalController.didPresent, object: self, userInfo: nil)
		}
	}
	
	public override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
		guard !isDismissing else { return }
		isDismissing = true
		
		delegate?.modalController(self, willDismiss: contentViewController)
		NotificationCenter.default.post(name: NKModalController.willDismiss, object: self, userInfo: nil)
		
		let duration = delegate?.animationDuration(modalController: self) ?? animationDuration
		let targetProperties = dismissFrame()
		let transform: CGAffineTransform = targetProperties.scale == 1.0 ? .identity : CGAffineTransform(scaleX: targetProperties.scale, y: targetProperties.scale)
		
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
			self.view.backgroundColor = .clear
			if self.animatedView != nil || targetProperties.scale != 1.0 {
				self.containerView.alpha = 0.0
			}
			self.containerView.frame = targetProperties.frame
			self.containerView.transform = transform
		}) { (finished) in
			if let lastPosition = self.lastPosition {
				lastPosition.container.addSubview(self.contentViewController.view)
				self.contentViewController.view.alpha = self.lastAnimatedViewAlpha
				self.contentViewController.view.frame = lastPosition.frame
				self.contentViewController.view.setNeedsLayout()
			}
			
			self.animatedView?.alpha = self.lastAnimatedViewAlpha
			
			super.dismiss(animated: false) {
				self.isDismissing = false
				self.lastWindow?.makeKeyAndVisible()
				
				self.window?.rootViewController?.resignFirstResponder()
				self.window?.rootViewController = nil
				self.window?.removeFromSuperview()
				self.window = nil
				
				self.delegate?.modalController(self, didDismiss: self.contentViewController)
				self.contentViewController = nil
				NotificationCenter.default.post(name: NKModalController.didDismiss, object: self, userInfo: nil)
			}
		}
	}
	
	public func updateLayout(duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		containerView.layer.cornerRadius = delegate?.cornerRadius(modalController: self) ?? cornerRadius
		containerView.clipsToBounds = containerView.layer.cornerRadius > 0
		
		let color = delegate?.backgroundColor(modalController: self) ?? backgroundColor
		let durationValue = duration ?? delegate?.animationDuration(modalController: self) ?? animationDuration
		UIView.animate(withDuration: durationValue, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
			self.view.backgroundColor = color
			self.setNeedsStatusBarAppearanceUpdate()
			self.containerView.transform = .identity
			self.containerView.frame = self.presentFrame()
			self.containerView.alpha = 1.0
			self.animatedView?.alpha = 0.0
		}) { (finished) in
			self.view.setNeedsLayout()
			self.contentViewController.view.frame = self.containerView.bounds
			
			completion?()
		}
	}
	
	// MARK: -
	
	private var presentPosition: NKModalPresentPosition {
		return delegate?.presentPosition(modalController: self) ?? .center
	}
	
	func startFrame() -> (frame: CGRect, scale: CGFloat) {
		if let lastContainer = lastPosition?.container {
			return (lastContainer.convert(contentViewController.view.frame, to: view), 1.0)
		}
		
		if let animatedView = animatedView ?? contentViewController.view.superview {
			return (frame: animatedView.convert(animatedView.bounds, to: view), scale: 1.0) // [_startView convertRect:_startView.bounds toCoordinateSpace:self.view];
		}
		
		var result = presentFrame()
		var scaleValue: CGFloat = 1.0
		var presentAnimation: NKModalPresentAnimation = delegate?.presentAnimation(modalController: self) ?? .auto
		if presentAnimation == .auto {
			presentAnimation = presentPosition.toPresentAnimation(view: view)
		}
		
		switch presentAnimation {
		case .auto: break
		case .fromTop:
			result.origin.y = -result.size.height
		case .fromLeft:
			result.origin.x = -result.size.width
		case .fromBottom:
			result.origin.y = view.bounds.size.height
		case .fromRight:
			result.origin.x = view.bounds.size.width
		case .fromCenter(let scale):
			scaleValue = scale
		}
		
		return (frame: result, scale: scaleValue)
	}
	
	func presentFrame() -> CGRect {
		let viewSize = view.bounds.size
		var contentSize = contentViewController.preferredContentSize
		
		var origin: CGPoint = .zero
		switch presentPosition {
		case .top:
			origin.x = (viewSize.width - contentSize.width)/2
			origin.y = 0
			
		case .left:
			origin.x = 0
			origin.y = (viewSize.height - contentSize.height)/2
			
		case .bottom:
			origin.x = (viewSize.width - contentSize.width)/2
			origin.y = viewSize.height - contentSize.height
			
		case .right:
			origin.x = viewSize.width - contentSize.width
			origin.y = (viewSize.height - contentSize.height)/2
			
		case .center:
			origin.x = (viewSize.width - contentSize.width)/2
			origin.y = (viewSize.height - contentSize.height)/2
		case .fullscreen:
			origin.x = 0
			origin.y = 0
			contentSize = viewSize
		case .custom(let frame):
			return frame
		}
		
		return CGRect(origin: origin, size: contentSize)
	}
	
	func dismissFrame() -> (frame: CGRect, scale: CGFloat) {
		if let lastPosition = lastPosition {
			return (lastPosition.frame, 1.0)
		}
		
		if let animatedView = animatedView {
			return (frame: animatedView.convert(animatedView.bounds, to: view), scale: 1.0) // [_startView convertRect:_startView.bounds toCoordinateSpace:self.view];
		}
		
		var result = presentFrame()
		var scaleValue: CGFloat = 1.0
		var dismissAnimation: NKModalDismissAnimation = delegate?.dismissAnimation(modalController: self) ?? .auto
		if dismissAnimation == .auto {
			dismissAnimation = presentPosition.toDismissAnimation(view: view)
		}
		
		switch dismissAnimation {
		case .auto: break
		case .toTop:
			result.origin.y = -result.size.height
		case .toLeft:
			result.origin.x = -result.size.width
		case .toBottom:
			result.origin.y = view.bounds.size.height
		case .toRight:
			result.origin.x = view.bounds.size.width
		case .toCenter(let scale):
			scaleValue = scale
		}
		
		return (frame: result, scale: scaleValue)
	}
	
}

class NKModalContainerViewController: UIViewController {
	weak var contentViewController: UIViewController?
	
	var visibleViewController: UIViewController? {
		return (contentViewController as? UINavigationController)?.visibleViewController ?? contentViewController
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Orientation
	
	override var shouldAutorotate: Bool {
		return visibleViewController?.shouldAutorotate ?? true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return visibleViewController?.supportedInterfaceOrientations ?? .all
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return visibleViewController?.preferredInterfaceOrientationForPresentation ?? UIApplication.shared.statusBarOrientation
	}
	
	// Statusbar
	
	override var prefersStatusBarHidden: Bool {
		return visibleViewController?.prefersStatusBarHidden ?? false
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return visibleViewController?.preferredStatusBarStyle ?? .default
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return visibleViewController?.preferredStatusBarUpdateAnimation ?? .fade
	}
	
}
