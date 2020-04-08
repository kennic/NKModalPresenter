//
//  DialogViewController.swift
//  Example
//
//  Created by Nam Kennic on 4/6/20.
//  Copyright © 2020 Nam Kennic. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController {
	let titleLabel = UILabel()
	let textField = UITextField()
	let showButton = UIButton()
	let closeButton = UIButton()
	var contentSize: CGSize = CGSize(width: 300, height: 300)
	
	override var preferredContentSize: CGSize {
		get {
			return contentSize
		}
		set {
			super.preferredContentSize = newValue
		}
	}
	
	init(contentSize: CGSize) {
		super.init(nibName: nil, bundle: nil)
		self.contentSize = contentSize
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .white
		
		titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
		titleLabel.text = "Test Dialog"
		titleLabel.textColor = .black
		titleLabel.textAlignment = .center
		
		textField.font = .systemFont(ofSize: 14, weight: .regular)
		textField.placeholder = "Tap here to show the keyboard"
		textField.returnKeyType = .done
		textField.layer.cornerRadius = 5.0
		textField.layer.borderWidth = 1.0
		textField.layer.borderColor = UIColor.gray.cgColor
		textField.delegate = self
		
		showButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		showButton.setTitle("Present another", for: .normal)
		showButton.setTitleColor(UIColor.white, for: .normal)
		showButton.backgroundColor = UIColor(red: 0.178, green: 0.179, blue: 0.177, alpha: 0.898)
		showButton.layer.cornerRadius = 5.0
		showButton.showsTouchWhenHighlighted = true
		showButton.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
		
		closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		closeButton.setTitle("Close", for: .normal)
		closeButton.setTitleColor(UIColor.white, for: .normal)
		closeButton.backgroundColor = UIColor(red: 0.178, green: 0.179, blue: 0.177, alpha: 0.898)
		closeButton.layer.cornerRadius = 5.0
		closeButton.showsTouchWhenHighlighted = true
		closeButton.addTarget(self, action: #selector(onButtonSelected), for: .touchUpInside)
		
		view.addSubview(titleLabel)
		view.addSubview(textField)
		view.addSubview(showButton)
		view.addSubview(closeButton)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let viewSize = view.bounds.size
		let buttonSize = CGSize(width: 120, height: 40)
		
		var buttonFrame = CGRect(x: (viewSize.width - buttonSize.width)/2, y: viewSize.height - buttonSize.height - 90, width: buttonSize.width, height: buttonSize.height)
		showButton.frame = buttonFrame
		
		buttonFrame.origin.y += buttonFrame.size.height + 10
		closeButton.frame = buttonFrame
		
		let labelSize = titleLabel.sizeThatFits(viewSize)
		titleLabel.frame = CGRect(x: (viewSize.width - labelSize.width)/2, y: 10, width: labelSize.width, height: labelSize.height)
		textField.frame = CGRect(x: 20, y: 80, width: viewSize.width - 40, height: 40)
	}
	
	@objc func onButtonSelected(_ button: UIButton) {
		if button == closeButton {
			dismiss(animated: true, completion: nil)
		}
		else {
			NKModalPresenter.shared.present(viewController: DialogViewController(contentSize: CGSize(width: Double.random(in: 200...400), height: Double.random(in: 300...500))), animatedFrom: button)
		}
	}
	
	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		_ = view.endEditing(true)
		
		if let controller = modalController {
			controller.dismiss(animated: flag, completion: completion)
		}
		else {
			super.dismiss(animated: flag, completion: completion)
		}
	}
	
	// MARK: -
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .slide
	}
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return .portrait
	}
	
	deinit {
		print("DEINIT")
	}

}

extension DialogViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
}

extension DialogViewController: NKModalControllerDelegate {
	
	func presentPosition(modalController: NKModalController) -> NKModalPresentPosition {
		return .center
	}
	
	func shouldTapOutsideToDismiss(modalController: NKModalController) -> Bool {
		return true
	}
	
	func shouldDragToDismiss(modalController: NKModalController) -> Bool {
		return true
	}
	
	func shouldAvoidKeyboard(modalController: NKModalController) -> Bool {
		return true
	}
	
	func animationDuration(modalController: NKModalController) -> TimeInterval {
		return 0.5
	}
	
}
