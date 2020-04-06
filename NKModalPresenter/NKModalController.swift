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
	case custom(frame: CGRect)
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

public protocol NKModalControllerDelegate: class {
	
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
	
	func presentingViewController(modalController: NKModalController) -> UIViewController? { return nil }
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition { return .center }
	func presentAnimation(modalController: NKModalController) -> NKModalPresentAnimation { return .auto }
	func dismissAnimation(modalController: NKModalController) -> NKModalDismissAnimation { return .auto }
	func animationDuration(modalController: NKModalController) -> TimeInterval { return 0.45 }
	func backgroundColor(modalController: NKModalController) -> UIColor { return UIColor.black.withAlphaComponent(0.75) }
	func backgroundBlurryValue(modalController: NKModalController) -> CGFloat { return 0.0 }
	func cornerRadius(modalController: NKModalController) -> CFloat { return 8.0 }
	
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

public class NKModalController: UIViewController {
	public fileprivate(set) var contentViewController: UIViewController!
	public var animatedView: UIView?
	public var delegate: NKModalControllerDelegate?
	
	let containerView = UIView()
	var lastWindow: UIWindow?
	var lastPosition: (container: UIView?, frame: CGRect)?

	public init(viewController: UIViewController) {
		super.init(nibName: nil, bundle: nil)
		
		modalTransitionStyle = .crossDissolve
		modalPresentationStyle = .overCurrentContext
		
		contentViewController = viewController
		containerView.addSubview(contentViewController.view)
		
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
		animatedView = view
		lastPosition = (contentViewController.view.superview, contentViewController.view.frame)
		
		var presentingViewController = delegate?.presentingViewController(modalController: self)
		if presentingViewController == nil {
			modalPresentationStyle = .fullScreen
			lastWindow = UIWindow.keyWindow
			
			presentingViewController = NKModalContainerViewController()
			var window: UIWindow! = nil
			if #available(iOS 13.0, *) {
				if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
					window = UIWindow(windowScene: scene)
				}
			}
			
			if window == nil {
				window = UIWindow(frame: UIScreen.main.bounds)
			}
			
			window.windowLevel = .normal
			window.rootViewController = presentingViewController
			window.makeKeyAndVisible()
		}
		
		presentingViewController?.present(self, animated: false, completion: {
			self.showView()
		})
	}
	
	func showView() {
		containerView.addSubview(contentViewController.view)
	}
	
	public override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
		
	}
	
	// MARK: -
	
	func startFrame() -> (frame: CGRect, scale: CGFloat) {
		if let animatedView = animatedView ?? contentViewController.view.superview {
			return (frame: animatedView.convert(animatedView.bounds, to: view), scale: 1.0) // [_startView convertRect:_startView.bounds toCoordinateSpace:self.view];
		}
		
		var result = presentFrame()
		var scaleValue: CGFloat = 1.0
		var presentAnimation: NKModalPresentAnimation = delegate?.presentAnimation(modalController: self) ?? .auto
		if presentAnimation == .auto {
			let presentPosition: NKModalPresentPosition = delegate?.presentPosition(modalController: self) ?? .center
			presentAnimation = presentPosition.toPresentAnimation(view: view)
		}
		
		switch presentAnimation {
		case .auto: break
		case .fromTop:
			result.origin.y -= result.size.height
		case .fromLeft:
			result.origin.x -= result.size.width
		case .fromBottom:
			result.origin.y += result.size.height
		case .fromRight:
			result.origin.x += result.size.width
		case .fromCenter(let scale):
			scaleValue = scale
		}
		
		return (frame: result, scale: scaleValue)
	}
	
	func presentFrame() -> CGRect {
		let presentPosition: NKModalPresentPosition = delegate?.presentPosition(modalController: self) ?? .center
		let viewSize = view.bounds.size
		let contentSize = contentViewController.preferredContentSize
		
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
			origin.x = viewSize.width - contentSize.width
			origin.y = (viewSize.height - contentSize.height)/2
			
		case .custom(let frame):
			return frame
		}
		
		return CGRect(origin: origin, size: contentSize)
	}
	
}

class NKModalContainerViewController: UIViewController {
	weak var contentViewController: UIViewController?
	
	var visibleViewController: UIViewController? {
		return (contentViewController as? UINavigationController)?.visibleViewController ?? contentViewController
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
