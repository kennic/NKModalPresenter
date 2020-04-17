//
//  ViewController.swift
//  Example
//
//  Created by Nam Kennic on 4/4/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit

extension UIButton {
	
	static func appButton(title: String?) -> UIButton {
		let button = UIButton(type: .custom)
		button.setTitle(title, for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.backgroundColor = UIColor(red: 0.951, green: 0.956, blue: 0.945, alpha: 0.898)
		button.layer.cornerRadius = 5.0
		button.showsTouchWhenHighlighted = true
		return button
	}

	
}

class ViewController: UIViewController {
	let backgroundImageView = UIImageView(image: UIImage(named: "background"))
	let button1 = UIButton.appButton(title: "Animated from button")
	let button2 = UIButton.appButton(title: "Present from center")
	let button3 = UIButton.appButton(title: "Present existing")
	let testViewController = DialogViewController(contentSize: CGSize(width: 300, height: 300))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backgroundImageView.contentMode = .scaleAspectFill
		
		view.addSubview(backgroundImageView)
		view.addSubview(testViewController.view)
		
		[button1, button2, button3].forEach { (button) in
			button.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
			view.addSubview(button)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		backgroundImageView.frame = view.bounds
		
		let viewSize = view.bounds.size
		let buttonSize = CGSize(width: 200, height: 40)
		
		var buttonFrame = CGRect(x: CGFloat(roundf(Float(viewSize.width / 2 - buttonSize.width / 2))), y: viewSize.height - buttonSize.height - 200, width: buttonSize.width, height: buttonSize.height)
		button1.frame = buttonFrame
		
		buttonFrame.origin.y += buttonFrame.size.height + 20
		button2.frame = buttonFrame
		
		buttonFrame.origin.y += buttonFrame.size.height + 20
		button3.frame = buttonFrame
		
		if testViewController.view.superview == view {
			let contentViewSize = testViewController.preferredContentSize
		    testViewController.view.frame = CGRect(x: (viewSize.width - contentViewSize.width) / 2, y: 50, width: contentViewSize.width, height: contentViewSize.height)
		    testViewController.view.setNeedsLayout()
		}
	}
	
	@objc func onButtonSelected(_ button: UIButton) {
		if button == button1 {
			let dialogViewController = DialogViewController(contentSize: CGSize(width: Double.random(in: 200...400), height: Double.random(in: 300...500)))
			dialogViewController.allowTransitionView = true
			NKModalPresenter.shared.present(viewController: dialogViewController, animatedFrom: button)
		}
		else if button == button2 {
			NKModalPresenter.shared.present(viewController: DialogViewController(contentSize: CGSize(width: Double.random(in: 200...400), height: Double.random(in: 300...500))))
		}
		else if button == button3 {
			NKModalPresenter.shared.present(viewController: testViewController)
		}
	}
	
}

