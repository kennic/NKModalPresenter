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
	case from(view: UIView)
}

public enum NKModalDismissAnimation: Equatable {
	case auto
	case toTop
	case toLeft
	case toBottom
	case toRight
	case toCenter(scale: CGFloat)
	case to(view: UIView)
}

public enum NKModalEasingAnimation: Equatable {
	case easeIn
	case easeOut
	case easeInOut
	case linear
}

public protocol NKModalControllerDelegate {
	
	func modalController(_ controller: NKModalController, willPresent viewController: UIViewController)
	func modalController(_ controller: NKModalController, didPresent viewController: UIViewController)
	func modalController(_ controller: NKModalController, willDismiss viewController: UIViewController)
	func modalController(_ controller: NKModalController, didDismiss viewController: UIViewController)
	func modalController(_ controller: NKModalController, dragState: UIGestureRecognizer.State)
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool
	func shouldDragToDismiss(modalController: NKModalController) -> Bool
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool
	
	func presentingViewController(modalController: NKModalController) -> UIViewController?
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation
	func easingAnimation(modalController: NKModalController) -> NKModalEasingAnimation
	func animationDuration(modalController: NKModalController) -> TimeInterval
	func backgroundColor(modalController: NKModalController) -> UIColor
	func cornerRadius(modalController: NKModalController) -> CGFloat
	func transitionView(modalController: NKModalController) -> UIView?
	
}

public extension NKModalControllerDelegate {
	
	func modalController(_ controller: NKModalController, willPresent viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, didPresent viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, willDismiss viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, didDismiss viewController: UIViewController) {}
	func modalController(_ controller: NKModalController, dragState: UIGestureRecognizer.State) {}
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool { return false }
	func shouldDragToDismiss(modalController: NKModalController) -> Bool { return false }
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool { return false }
	
	func presentingViewController(modalController: NKModalController) -> UIViewController? { return nil }
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition { return .center }
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation { return .auto }
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation { return .auto }
	func easingAnimation(modalController: NKModalController) -> NKModalEasingAnimation { return .easeInOut }
	func animationDuration(modalController: NKModalController) -> TimeInterval { return NKModalController.animationDuration }
	func backgroundColor(modalController: NKModalController) -> UIColor { return NKModalController.backgroundColor }
	func cornerRadius(modalController: NKModalController) -> CGFloat { return NKModalController.cornerRadius }
	func transitionView(modalController: NKModalController) -> UIView? { return nil }
	
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

extension NKModalPresentAnimation {
	
	func toDismissAnimation(view: UIView) -> NKModalDismissAnimation {
		switch self {
			case .fromTop:
				return .toTop
			case .fromLeft:
				return .toLeft
			case .fromBottom:
				return .toBottom
			case .fromRight:
				return .toRight
			case .fromCenter(let scale):
				return .toCenter(scale: scale)
			case .from(let view):
				return .to(view: view)
			case .auto:
				return .toCenter(scale: 0.8)
		}
	}
	
}
extension NKModalEasingAnimation {
	
	func toAnimationOption() -> UIView.AnimationOptions {
		switch self {
		case .easeIn:
			return .curveEaseIn
		case .easeOut:
			return .curveEaseOut
		case .easeInOut:
			return .curveEaseInOut
		case .linear:
			return .curveLinear
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

public class NKModalController: NKModalContainerViewController {
	public static let willPresent = Notification.Name(rawValue: "NKModalControllerWillPresent")
	public static let didPresent = Notification.Name(rawValue: "NKModalControllerDidPresent")
	public static let willDismiss = Notification.Name(rawValue: "NKModalControllerWillDismiss")
	public static let didDismiss = Notification.Name(rawValue: "NKModalControllerDidDismiss")
	
	public var willPresent: ((NKModalController) -> Void)?
	public var didPresent: ((NKModalController) -> Void)?
	public var willDismiss: ((NKModalController) -> Void)?
	public var didDismiss: ((NKModalController) -> Void)?
	
	public fileprivate(set) var isPresenting = false
	public fileprivate(set) var isDismissing = false
	public fileprivate(set) var isAnimating = false
	public fileprivate(set) var targetPosition: NKModalPresentPosition?
	public fileprivate(set) var presentAnimation: NKModalPresentAnimation?
	public var dismissAnimation: NKModalDismissAnimation?
	
	public var delegate: NKModalControllerDelegate?
	public var tapOutsideToDismiss = false
	public var dragToDismiss = false
	public var avoidKeyboard = false
	
	public fileprivate(set) var contentView: UIView!
	public var anchorView: UIView? {
		didSet {
			guard anchorView != oldValue else { return }
			oldValue?.alpha = lastAnchorViewAlpha
			lastAnchorViewAlpha = anchorView?.alpha ?? 1.0
			if oldValue != nil {
				anchorView?.alpha = 0.0
			}
		}
	}
	
//	var originalMethod: Method?
//	var swizzledMethod: Method?
	
	// Default values
	public static var backgroundColor = UIColor.black.withAlphaComponent(0.65)
	public static var animationDuration: TimeInterval = 0.45
	public static var easingAnimation: NKModalEasingAnimation = .easeInOut
	public static var cornerRadius: CGFloat = 8.0
	
	public var backgroundColor = NKModalController.backgroundColor
	public var animationDuration: TimeInterval = NKModalController.animationDuration
	public var easingAnimation: NKModalEasingAnimation = NKModalController.easingAnimation
	public var cornerRadius: CGFloat = NKModalController.cornerRadius
	
	let containerView = UIView()
	var window: UIWindow?
	var lastWindow: UIWindow?
	var lastPosition: (container: UIView, frame: CGRect)?
	var anchorCapturedView: UIImageView?
	var contentCapturedView: UIImageView?
	var transitionView: UIView?
	var lastTransitionViewAlpha: CGFloat = 1.0
	var keyboardHeight: CGFloat = 0
	var contentSize: CGSize?
	var lastAnchorViewAlpha: CGFloat = 1.0
	var lastViewSize: CGSize?
	
	var tapGesture: UITapGestureRecognizer?
	var panGesture: UIPanGestureRecognizer?

	public init(viewController: UIViewController) {
		super.init(nibName: nil, bundle: nil)
		
		modalTransitionStyle = .crossDissolve
		modalPresentationStyle = .overCurrentContext
		modalPresentationCapturesStatusBarAppearance = true
		
		contentViewController = viewController
		contentView = viewController.view
		
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
		
		tapGesture = UITapGestureRecognizer(target: nil, action: nil)
		tapGesture?.delegate = self
		tapGesture?.delaysTouchesEnded = false
		tapGesture?.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture!)
		
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan))
		view.addGestureRecognizer(panGesture!)
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		registerKeyboardNotifications()
	}
	
	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard view.bounds.size != lastViewSize else { return }
		lastViewSize = view.bounds.size
		guard !isAnimating, !isPresenting, !isDismissing else { return }
		layoutView(duration: 0.0, completion: nil)
	}
	
	// MARK: -
	
	public func present(animate: NKModalPresentAnimation? = nil, to position: NKModalPresentPosition? = nil) {
		guard !isPresenting else { return }
		isPresenting = true
		presentAnimation = animate
		targetPosition = position
		
//		DispatchQueue.once(token: "\(contentViewController!)") {
//			let classType = type(of: contentViewController!)
//			originalMethod = class_getInstanceMethod(classType.self, #selector(classType.dismiss(animated:completion:)))
//			swizzledMethod = class_getInstanceMethod(classType.self, #selector(classType.dismissModal(animated:completion:)))
//			method_exchangeImplementations(originalMethod!, swizzledMethod!)
//		}
		
		willPresent?(self)
		delegate?.modalController(self, willPresent: contentViewController)
		NotificationCenter.default.post(name: NKModalController.willPresent, object: self, userInfo: nil)
		
		if let container = contentView.superview {
			lastPosition = (container, contentView.frame)
		}
		
		var presentingViewController = delegate?.presentingViewController(modalController: self)
		if presentingViewController == nil {
			modalPresentationStyle = .fullScreen
			lastWindow = UIWindow.keyWindow
			
			let containerViewController = NKModalContainerViewController()
			containerViewController.contentViewController = contentViewController
			presentingViewController = containerViewController
			
			if #available(iOS 13.0, *) {
				if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive}) as? UIWindowScene {
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
		let startProperties = initFrame()
		
		containerView.addSubview(contentView)
		containerView.frame = startProperties.frame
		
		if let anchorView = anchorView {
			transitionView = delegate?.transitionView(modalController: self)
			
			let frame = presentFrame()
			if transitionView != nil {
				containerView.frame = frame
			}
			contentView.frame = frame
			contentView.setNeedsLayout()
			contentView.layoutIfNeeded()
			
			contentCapturedView = capture(transitionView ?? contentView)
			contentCapturedView?.alpha = 0.0
			contentCapturedView?.contentMode = .scaleToFill
			contentView.alpha = 0.0
			
			anchorCapturedView = capture(anchorView)
			anchorCapturedView?.alpha = 1.0
			
			if transitionView != nil {
				let frame = view.convert(anchorView.frame, from: anchorView.superview)
				anchorCapturedView?.frame = frame
				contentCapturedView?.frame = frame
				view.addSubview(contentCapturedView!)
				view.addSubview(anchorCapturedView!)
			}
			else {
				containerView.addSubview(contentCapturedView!)
				containerView.addSubview(anchorCapturedView!)
			}
			
			anchorView.alpha = 0.0
		}
		
		contentView.frame = containerView.bounds
		
		if startProperties.scale != 1.0 {
			containerView.transform = CGAffineTransform(scaleX: startProperties.scale, y: startProperties.scale)
			containerView.alpha = 0.0
		}
		
		layoutView(duration: nil) {
			self.isPresenting = false
			
			self.didPresent?(self)
			self.delegate?.modalController(self, didPresent: self.contentViewController)
			NotificationCenter.default.post(name: NKModalController.didPresent, object: self, userInfo: nil)
		}
	}
	
	public func updatePosition(_ position: NKModalPresentPosition, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		guard targetPosition != position else { return }
		targetPosition = position
		
		contentSize = getContentSize()
		layoutView(duration: duration, completion: completion)
	}
	
	public func updateLayout(duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		guard !isDismissing else { return }
		
		let newContentSize = getContentSize()
		guard contentSize != newContentSize else { return }
		guard !isPresenting else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.updateLayout(duration: duration, completion: completion)
			}
			return
		}
		
		contentSize = newContentSize
		layoutView(duration: duration, completion: completion)
	}
	
	private func layoutView(duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		guard contentViewController != nil else { return }
		guard !isDismissing else { return }
		
		let cornerRadius = delegate?.cornerRadius(modalController: self) ?? self.cornerRadius
		containerView.clipsToBounds = cornerRadius > 0
		
		let color = delegate?.backgroundColor(modalController: self) ?? backgroundColor
		let easing = delegate?.easingAnimation(modalController: self) ?? easingAnimation
		let durationValue = duration ?? delegate?.animationDuration(modalController: self) ?? animationDuration
		
		isAnimating = true
		
		var targetFrame: CGRect? = nil
		if transitionView != nil {
			lastTransitionViewAlpha = transitionView!.alpha
			transitionView!.alpha = 0.0
			targetFrame = view.convert(transitionView!.frame, from: transitionView!.superview)
		}
		
		animationBlock(duration: durationValue, options: easing.toAnimationOption(), animations: {
			self.view.backgroundColor = color
			self.setNeedsStatusBarAppearanceUpdate()
			
			self.containerView.transform = .identity
			self.containerView.frame = self.presentFrame()
			self.containerView.alpha = 1.0
			self.containerView.layer.cornerRadius = cornerRadius
			
			self.anchorCapturedView?.alpha = 0.0
			self.contentCapturedView?.alpha = 1.0
			
			if let frame = targetFrame {
				self.contentView?.alpha = 1.0
				self.contentCapturedView?.frame = frame
				self.anchorCapturedView?.frame = frame
			}
			
			self.contentView?.frame = self.containerView.bounds
		}) { (finished) in
			self.view.setNeedsLayout()
			self.contentView?.frame = self.containerView.bounds
			self.contentView?.alpha = 1.0
			self.transitionView?.alpha = self.lastTransitionViewAlpha
			self.removeCapturedView(&self.anchorCapturedView)
			self.removeCapturedView(&self.contentCapturedView)
			self.setNeedsStatusBarAppearanceUpdate()
			self.isAnimating = false
			completion?()
		}
	}
	
	public override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
		guard !isPresenting else {
			print("[NKModalController] Can not dismiss a modal controller while it's presenting")
			return
		}
		
		guard !isDismissing else { return }
		isDismissing = true
		isAnimating = true
		
//		if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
//			method_exchangeImplementations(swizzledMethod, originalMethod)
//			self.originalMethod = nil
//			self.swizzledMethod = nil
//		}
		
		NotificationCenter.default.removeObserver(self)
		removeGestures()
		
		willDismiss?(self)
		delegate?.modalController(self, willDismiss: contentViewController)
		NotificationCenter.default.post(name: NKModalController.willDismiss, object: self, userInfo: nil)
		
		let duration = animated ? delegate?.animationDuration(modalController: self) ?? animationDuration : 0.0
		let targetProperties = dismissFrame()
		let transform: CGAffineTransform = targetProperties.scale == 1.0 ? .identity : CGAffineTransform(scaleX: targetProperties.scale, y: targetProperties.scale)
		
		if let anchorView = anchorView, duration > 0.0 {
			transitionView = delegate?.transitionView(modalController: self)
			contentCapturedView = capture(transitionView ?? contentView)
			contentCapturedView?.alpha = 1.0
			contentCapturedView?.contentMode = .scaleToFill
			
			anchorView.alpha = 1.0
			anchorCapturedView = capture(anchorView)
			anchorCapturedView?.alpha = 0.0
			anchorView.alpha = 0.0
			
			if transitionView != nil {
				let frame = view.convert(transitionView!.frame, from: transitionView?.superview)
				contentCapturedView?.frame = frame
				anchorCapturedView?.frame = frame
				view.addSubview(contentCapturedView!)
				view.addSubview(anchorCapturedView!)
			}
			else {
				contentView.alpha = 0.0
				containerView.addSubview(contentCapturedView!)
				containerView.addSubview(anchorCapturedView!)
			}
		}
		
		var targetFrame: CGRect? = nil
		if let anchorView = anchorView, transitionView != nil {
			transitionView!.alpha = 0.0
			targetFrame = view.convert(anchorView.frame, from: anchorView.superview)
		}
		
		let easing = delegate?.easingAnimation(modalController: self) ?? easingAnimation
		animationBlock(duration: duration, options: easing.toAnimationOption(), animations: {
			self.view.backgroundColor = .clear
			
			if self.lastPosition != nil {
				self.contentView.alpha = self.lastAnchorViewAlpha
				self.containerView.layer.cornerRadius = 0.0
			}
			else {
				if targetProperties.scale != 1.0 {
					self.containerView.alpha = 0.0
				}
				if self.anchorView != nil {
					self.contentView.alpha = 0.0
				}
			}
			
			self.anchorCapturedView?.alpha = 1.0
			self.contentCapturedView?.alpha = 0.0
			
			if let frame = targetFrame {
//				self.contentView?.alpha = 0.0
				self.contentCapturedView?.frame = frame
				self.anchorCapturedView?.frame = frame
			}
			else {
				self.containerView.frame = targetProperties.frame
				self.containerView.transform = transform
				self.contentView.frame = self.containerView.bounds
			}
		}) { (finished) in
			self.anchorView?.alpha = self.lastAnchorViewAlpha
			self.removeCapturedView(&self.contentCapturedView)
			
			if let lastPosition = self.lastPosition {
				lastPosition.container.addSubview(self.contentView)
				self.contentView.alpha = self.lastAnchorViewAlpha
				self.contentView.frame = lastPosition.frame
				self.contentView.setNeedsLayout()
			}
			
			self.animationBlock(duration: min(0.1, duration), options: .curveEaseOut, animations: {
				self.anchorCapturedView?.alpha = 0.0
			}) { (finished) in
				self.removeCapturedView(&self.anchorCapturedView)
				
				super.dismiss(animated: false) {
					self.setNeedsStatusBarAppearanceUpdate()
					self.isAnimating = false
					self.isDismissing = false
					self.lastWindow?.makeKeyAndVisible()
					
					self.window?.rootViewController?.resignFirstResponder()
					self.window?.rootViewController = nil
					self.window?.removeFromSuperview()
					self.window = nil
					
					self.didDismiss?(self)
					self.delegate?.modalController(self, didDismiss: self.contentViewController)
					NotificationCenter.default.post(name: NKModalController.didDismiss, object: self, userInfo: nil)
					
					self.contentView = nil
					self.contentViewController = nil
				}
			}
		}
	}
	
	// MARK: -
	
	private func registerKeyboardNotifications() {
	    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
	    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	private func getContentSize() -> CGSize {
		var result = (visibleViewController ?? contentViewController).preferredContentSize
		if result == .zero {
			return view.bounds.size
		}
		
		result.width = max(1, result.width)
		result.height = max(1, result.height)
		return result
	}
	
	private func animationBlock(duration: TimeInterval, options: UIView.AnimationOptions, animations: @escaping (() -> Void), completion: ((Bool) -> Void)? = nil) {
		if duration == 0 {
			animations()
			completion?(true)
		}
		else {
			UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: options, animations: animations, completion: completion)
		}
	}
	
	private func capture(_ view: UIView) -> UIImageView {
		let imageView = UIImageView(image: captureImage(view))
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleToFill
		imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		imageView.layer.cornerRadius = view.layer.cornerRadius
		imageView.frame = containerView.bounds
		return imageView
	}
	
	private func captureImage(_ view: UIView) -> UIImage? {
		UIGraphicsBeginImageContext(view.frame.size)
		
		if let context = UIGraphicsGetCurrentContext() {
			view.layer.render(in: context)
			
			if let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage {
				UIGraphicsEndImageContext()
				return UIImage(cgImage: cgImage)
			}
		}
		
		return nil
	}
	
	private func removeCapturedView(_ imageView: inout UIImageView?) {
		imageView?.removeFromSuperview()
		imageView?.image = nil
		imageView = nil
	}
	
	private func removeGestures() {
		if tapGesture != nil {
			view.removeGestureRecognizer(tapGesture!)
		}
		if panGesture != nil {
			view.removeGestureRecognizer(panGesture!)
		}
		
		tapGesture?.delegate = nil
		panGesture?.delegate = nil
	}
	
	// MARK: -
	
	private var presentPosition: NKModalPresentPosition {
		return targetPosition ?? delegate?.presentPosition(modalController: self) ?? .center
	}
	
	func initFrame() -> (frame: CGRect, scale: CGFloat) {
		if let lastContainer = lastPosition?.container {
			return (lastContainer.convert(contentView.frame, to: view), 1.0)
		}
		
		var result = presentFrame()
		var scaleValue: CGFloat = 1.0
		var animation: NKModalPresentAnimation = presentAnimation ?? delegate?.presentAnimation(modalController: self) ?? .auto
		if animation == .auto {
			animation = presentPosition.toPresentAnimation(view: view)
		}
		
		switch animation {
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
			case .from(let targetView):
				anchorView = targetView.window != nil ? targetView : nil
				result = targetView.convert(targetView.bounds, to: view)
		}
		
		return (frame: result, scale: scaleValue)
	}
	
	func presentFrame() -> CGRect {
		if contentSize == nil {
			contentSize = getContentSize()
		}
		
		guard var contentSize = contentSize else { return UIScreen.main.bounds }
		var viewSize = view.bounds.size
		viewSize.height -= keyboardHeight
		
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
			origin = frame.origin
			contentSize = frame.size
		}
		
		return CGRect(origin: origin, size: contentSize)
	}
	
	func dismissFrame() -> (frame: CGRect, scale: CGFloat) {
		if let lastPosition = lastPosition {
			return (lastPosition.frame, 1.0)
		}
		
		var result = presentFrame()
		var scaleValue: CGFloat = 1.0
		var animation: NKModalDismissAnimation = dismissAnimation ?? delegate?.dismissAnimation(modalController: self) ?? .auto
		if animation == .auto {
			animation = presentAnimation?.toDismissAnimation(view: view) ?? presentPosition.toDismissAnimation(view: view)
		}
		
		switch animation {
			case .auto: break
			case .toTop: result.origin.y = -result.size.height
			case .toLeft: result.origin.x = -result.size.width
			case .toBottom: result.origin.y = view.bounds.size.height
			case .toRight: result.origin.x = view.bounds.size.width
			case .toCenter(let scale): scaleValue = scale
			case .to(let targetView):
				anchorView = targetView.window != nil ? targetView : nil
				result = targetView.convert(targetView.bounds, to: view)
		}
		
		return (frame: result, scale: scaleValue)
	}
	
	fileprivate var touchPoint: CGPoint = .zero
	fileprivate var originPoint: CGPoint = .zero
	
	@objc func onPan(_ gesture: UIPanGestureRecognizer) {
		let enablePanGesture = delegate?.shouldDragToDismiss(modalController: self) ?? dragToDismiss
		guard enablePanGesture else { return }
		
		let state = gesture.state
		let currentPoint = gesture.location(in: view)
		
		var animation = dismissAnimation
		if animation == nil {
			animation = delegate?.dismissAnimation(modalController: self) ?? .auto
			if animation == .auto {
				animation = presentAnimation?.toDismissAnimation(view: view) ?? presentPosition.toDismissAnimation(view: view)
			}
		}
		
		if state == .began {
			touchPoint = currentPoint
			originPoint = containerView.frame.origin
			delegate?.modalController(self, dragState: state)
		}
		else {
			var distance: CGFloat
			
			if animation == .toTop {
			    distance = touchPoint.y - currentPoint.y
			} else if animation == .toLeft {
			    distance = touchPoint.x - currentPoint.x
			} else if animation == .toRight {
			    distance = currentPoint.x - touchPoint.x
			} else {
			    distance = currentPoint.y - touchPoint.y
			}
			
			if state == .changed {
				if animation == .toLeft {
				    var newFrame = containerView.frame
				    newFrame.origin.x = min(originPoint.x - distance, originPoint.x)
				    containerView.frame = newFrame
				} else if animation == .toRight {
				    var newFrame = containerView.frame
				    newFrame.origin.x = max(originPoint.x + distance, originPoint.x)
				    containerView.frame = newFrame
				} else if animation == .toTop {
				    var newFrame = containerView.frame
				    newFrame.origin.y = min(originPoint.y - distance, originPoint.y)
				    containerView.frame = newFrame
				} else {
				    var newFrame = containerView.frame
				    newFrame.origin.y = max(originPoint.y + distance, originPoint.y)
				    containerView.frame = newFrame
				}
				delegate?.modalController(self, dragState: state)
			}
			else if state == .ended || state == .cancelled || state == .failed {
				if state == .ended && distance > 60 {
					delegate?.modalController(self, dragState: state)
					dismiss(animated: true)
				}
				else {
					UIView.animate(withDuration: 0.3, animations: {
						var newFrame = self.containerView.frame
						newFrame.origin.x = self.originPoint.x
						newFrame.origin.y = self.originPoint.y
						self.containerView.frame = newFrame
					}) { (finished) in
						self.delegate?.modalController(self, dragState: state)
					}
				}
			}
		}
	}
	
	@objc func keyboardWillShow(_ notification: Notification) {
		let avoidKeyboard = delegate?.shouldAvoidKeyboard(modalController: self) ?? self.avoidKeyboard
		guard avoidKeyboard else { return }
		guard let userInfo = notification.userInfo as? [String : AnyObject] else { return }
		guard let isLocalKeyboard: Bool = userInfo[UIResponder.keyboardIsLocalUserInfoKey]?.boolValue, isLocalKeyboard else { return }
		guard let endFrame: CGRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue else { return }
		guard keyboardHeight != endFrame.size.height else { return }
		
		keyboardHeight = endFrame.size.height
		layoutView(duration: 0.5)
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		let avoidKeyboard = delegate?.shouldAvoidKeyboard(modalController: self) ?? self.avoidKeyboard
		guard avoidKeyboard else { return }
		guard keyboardHeight != 0.0 else { return }
		
		keyboardHeight = 0.0
		layoutView(duration: 0.5)
	}
	
	deinit {
		tapGesture?.delegate = nil
		panGesture?.delegate = nil
		NotificationCenter.default.removeObserver(self)
	}
	
}

extension NKModalController: UIGestureRecognizerDelegate {
	
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
	    if touch.view == view {
			let enableTapOutsideToDismiss = delegate?.shouldTapOutsideToDismiss(modalController: self) ?? tapOutsideToDismiss
			if enableTapOutsideToDismiss {
				dismiss(animated: true)
				return false
			}
	    }
	
	    return true
	}
	
}

public class NKModalContainerViewController: UIViewController {
	public fileprivate(set) var contentViewController: UIViewController!
	
	var visibleViewController: UIViewController? {
		return (contentViewController as? UINavigationController)?.visibleViewController ?? contentViewController
	}
	
	// Orientation
	
	public override var shouldAutorotate: Bool {
		return visibleViewController?.shouldAutorotate ?? true
	}
	
	public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return visibleViewController?.supportedInterfaceOrientations ?? .all
	}
	
	public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		#if targetEnvironment(macCatalyst)
		return visibleViewController?.preferredInterfaceOrientationForPresentation ?? UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait
		#else
		return visibleViewController?.preferredInterfaceOrientationForPresentation ?? UIApplication.shared.statusBarOrientation
		#endif
	}
	
	// Statusbar
	
	public override var prefersStatusBarHidden: Bool {
		return visibleViewController?.prefersStatusBarHidden ?? false
	}
	
	public override var preferredStatusBarStyle: UIStatusBarStyle {
		return visibleViewController?.preferredStatusBarStyle ?? .default
	}
	
	public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return visibleViewController?.preferredStatusBarUpdateAnimation ?? .fade
	}
	
}

// Swizzle methods

extension UIViewController {
	
	func swizzleInstanceMethod(from sel1: Selector, to sel2: Selector) {
		let classType = type(of: self)
		DispatchQueue.once(token: "\(classType)") {
			let originalMethod = class_getInstanceMethod(classType, sel1)
			let swizzledMethod = class_getInstanceMethod(classType, sel2)
			method_exchangeImplementations(originalMethod!, swizzledMethod!)
		}
	}
	
}

extension DispatchQueue {
	private static var _onceTracker = [String]()
	
	public class func once(token: String, file: String = #file, function: String = #function, line: Int = #line, block:()->Void) {
		let token = file + ":" + function + ":" + String(line) + token
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
