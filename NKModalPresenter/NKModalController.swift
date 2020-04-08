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
	func animationDuration(modalController: NKModalController) -> TimeInterval
	func backgroundColor(modalController: NKModalController) -> UIColor
	func cornerRadius(modalController: NKModalController) -> CGFloat
	
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
	func animationDuration(modalController: NKModalController) -> TimeInterval { return NKModalController.animationDuration }
	func backgroundColor(modalController: NKModalController) -> UIColor { return NKModalController.backgroundColor }
	func cornerRadius(modalController: NKModalController) -> CGFloat { return NKModalController.cornerRadius }
	
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

public class NKModalController: NKModalContainerViewController {
	public static let willPresent = Notification.Name(rawValue: "NKModalControllerWillPresent")
	public static let didPresent = Notification.Name(rawValue: "NKModalControllerDidPresent")
	public static let willDismiss = Notification.Name(rawValue: "NKModalControllerWillDismiss")
	public static let didDismiss = Notification.Name(rawValue: "NKModalControllerDidDismiss")
	
	public fileprivate(set) var isPresenting = false
	public fileprivate(set) var isDismissing = false
	public var animatedView: UIView?
	public var lastAnimatedViewAlpha: CGFloat = 1.0
	public var delegate: NKModalControllerDelegate?
	public var enableDragDownToDismiss = false
	
	// Default values
	public static var backgroundColor = UIColor.black.withAlphaComponent(0.8)
	public static var animationDuration: TimeInterval = 0.45
	public static var cornerRadius: CGFloat = 8.0
	
	let containerView = UIView()
	var window: UIWindow?
	var lastWindow: UIWindow?
	var lastPosition: (container: UIView, frame: CGRect)?
	var anchorCapturedView: UIImageView?
	var keyboardHeight: CGFloat = 0
	var contentSize: CGSize?
	
	var tapGesture: UITapGestureRecognizer?
	var panGesture: UIPanGestureRecognizer?

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
		
		containerView.addSubview(contentViewController.view)
		containerView.frame = startProperties.frame
		contentViewController.view.frame = containerView.bounds
		
		if let startView = animatedView, startView.window != nil {
			anchorCapturedView = capture(startView)
			anchorCapturedView?.alpha = 1.0
			containerView.addSubview(anchorCapturedView!)
			startView.alpha = 0.0
		}
		
		if startProperties.scale != 1.0 {
			containerView.transform = CGAffineTransform(scaleX: startProperties.scale, y: startProperties.scale)
			containerView.alpha = 0.0
		}
		
		layoutView(duration: nil) {
			self.isPresenting = false
			self.delegate?.modalController(self, didPresent: self.contentViewController)
			NotificationCenter.default.post(name: NKModalController.didPresent, object: self, userInfo: nil)
		}
	}
	
	public func updateLayout(duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		contentSize = contentViewController.preferredContentSize
		layoutView(duration: duration, completion: completion)
	}
	
	private func layoutView(duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
		guard contentViewController != nil else { return }
		
		let cornerRadius = delegate?.cornerRadius(modalController: self) ?? Self.cornerRadius
		containerView.clipsToBounds = cornerRadius > 0
		
		let color = delegate?.backgroundColor(modalController: self) ?? Self.backgroundColor
		let durationValue = duration ?? delegate?.animationDuration(modalController: self) ?? Self.animationDuration
		UIView.animate(withDuration: durationValue, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
			self.view.backgroundColor = color
			self.setNeedsStatusBarAppearanceUpdate()
			self.containerView.transform = .identity
			self.containerView.frame = self.presentFrame()
			self.containerView.alpha = 1.0
			self.containerView.layer.cornerRadius = cornerRadius
			self.anchorCapturedView?.alpha = 0.0
		}) { (finished) in
			self.removeCapturedView(&self.anchorCapturedView)
			self.view.setNeedsLayout()
			if self.contentViewController != nil {
				self.contentViewController.view.frame = self.containerView.bounds
			}
			
			self.setNeedsStatusBarAppearanceUpdate()
			completion?()
		}
	}
	
	public override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
		guard !isDismissing else { return }
		isDismissing = true
		
		NotificationCenter.default.removeObserver(self)
		removeGestures()
		
		delegate?.modalController(self, willDismiss: contentViewController)
		NotificationCenter.default.post(name: NKModalController.willDismiss, object: self, userInfo: nil)
		
		let duration = delegate?.animationDuration(modalController: self) ?? Self.animationDuration
		let targetProperties = dismissFrame()
		let transform: CGAffineTransform = targetProperties.scale == 1.0 ? .identity : CGAffineTransform(scaleX: targetProperties.scale, y: targetProperties.scale)
		
		if let startView = animatedView, startView.window != nil {
			startView.alpha = 1.0
			anchorCapturedView = capture(startView)
			anchorCapturedView?.alpha = 0.0
			containerView.addSubview(anchorCapturedView!)
			startView.alpha = 0.0
		}
		
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
			self.view.backgroundColor = .clear
			
			if self.lastPosition != nil {
				self.contentViewController.view.alpha = self.lastAnimatedViewAlpha
				self.containerView.layer.cornerRadius = 0.0
			}
			else {
				if targetProperties.scale != 1.0 {
					self.containerView.alpha = 0.0
				}
				if self.animatedView != nil {
					self.contentViewController.view.alpha = 0.0
				}
			}
			
			self.containerView.frame = targetProperties.frame
			self.containerView.transform = transform
			self.contentViewController.view.frame = self.containerView.bounds
			self.anchorCapturedView?.alpha = 1.0
		}) { (finished) in
			UIView.animate(withDuration: duration == 0 ? 0.0 : 0.1, animations: {
				self.animatedView?.alpha = self.lastAnimatedViewAlpha
				self.anchorCapturedView?.alpha = 0.0
			}) { (finished) in
				self.removeCapturedView(&self.anchorCapturedView)
				
				if let lastPosition = self.lastPosition {
					lastPosition.container.addSubview(self.contentViewController.view)
					self.contentViewController.view.alpha = self.lastAnimatedViewAlpha
					self.contentViewController.view.frame = lastPosition.frame
					self.contentViewController.view.setNeedsLayout()
				}
				
				super.dismiss(animated: false) {
					self.setNeedsStatusBarAppearanceUpdate()
					
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
	}
	
	// MARK: -
	
	func registerKeyboardNotifications() {
	    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
	    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
		return delegate?.presentPosition(modalController: self) ?? .center
	}
	
	func initFrame() -> (frame: CGRect, scale: CGFloat) {
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
		if contentSize == nil {
			contentSize = contentViewController.preferredContentSize
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
	
	fileprivate var touchPoint: CGPoint = .zero
	fileprivate var originPoint: CGPoint = .zero
	fileprivate var dismissAnimation: NKModalDismissAnimation?
	
	@objc func onPan(_ gesture: UIPanGestureRecognizer) {
		let enablePanGesture = delegate?.shouldDragToDismiss(modalController: self) ?? false
		guard enablePanGesture else { return }
		
		let state = gesture.state
		let currentPoint = gesture.location(in: view)
		
		if dismissAnimation == nil {
			dismissAnimation = delegate?.dismissAnimation(modalController: self) ?? .auto
			if dismissAnimation == .auto {
				dismissAnimation = presentPosition.toDismissAnimation(view: view)
			}
		}
		
		if state == .began {
			touchPoint = currentPoint
			originPoint = containerView.frame.origin
			delegate?.modalController(self, dragState: state)
		}
		else {
			var distance: CGFloat
			
			if dismissAnimation == .toTop {
			    distance = touchPoint.y - currentPoint.y
			} else if dismissAnimation == .toLeft {
			    distance = touchPoint.x - currentPoint.x
			} else if dismissAnimation == .toRight {
			    distance = currentPoint.x - touchPoint.x
			} else {
			    distance = currentPoint.y - touchPoint.y
			}
			
			if state == .changed {
				if dismissAnimation == .toLeft {
				    var newFrame = containerView.frame
				    newFrame.origin.x = min(originPoint.x - distance, originPoint.x)
				    containerView.frame = newFrame
				} else if dismissAnimation == .toRight {
				    var newFrame = containerView.frame
				    newFrame.origin.x = max(originPoint.x + distance, originPoint.x)
				    containerView.frame = newFrame
				} else if dismissAnimation == .toTop {
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
		let avoidKeyboard = delegate?.shouldAvoidKeyboard(modalController: self) ?? false
		guard avoidKeyboard else { return }
		
		guard let userInfo = notification.userInfo as? [String : AnyObject] else { return }
		guard let isLocalKeyboard: Bool = userInfo[UIResponder.keyboardIsLocalUserInfoKey]?.boolValue, isLocalKeyboard else { return }
		guard let endFrame: CGRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue else { return }
		guard keyboardHeight != endFrame.size.height else { return }
		
		keyboardHeight = endFrame.size.height
		layoutView(duration: 0.5)
	}
	
	@objc func keyboardWillHide(_ notification: Notification) {
		let avoidKeyboard = delegate?.shouldAvoidKeyboard(modalController: self) ?? false
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
			let enableTapOutsideToDismiss = delegate?.shouldTapOutsideToDismiss(modalController: self) ?? false
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
		return visibleViewController?.preferredInterfaceOrientationForPresentation ?? UIApplication.shared.statusBarOrientation
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
