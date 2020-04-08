# NKModalPresenter
`NKModalPresenter` allows you to present modal view controller easily and beautifully with animation.

![Demo Gif](Screenshots/demo1.gif)

## Installation

NKModalPresenter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NKModalPresenter'
```


## Usage
```swift
import NKModalPresenter

let viewController = MyViewController()

// Presenting
NKModalPresenter.shared.present(viewController: viewController, animatedFrom: view)

// Dismissing
viewController.modalDismiss(animated: true, completion: nil)
```

## Examples

Example project provided in Example folder.

## Requirements

* iOS 9+
* Swift 4.2+
