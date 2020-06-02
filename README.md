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
viewController.presentAsModal()
viewController.presentAsModal(animate: .from(view)) // transition from view
viewController.presentAsModal(animate: .fromTop, to: .center) // customize the animation path

// Modal Controller Configuration
viewController.modalController?.updatePosition(.top) // change position
viewController.modalController?.dismissAnimation = .toBottom // change dismiss animation
viewController.modalController?.tapOutsideToDismiss = true
viewController.modalController?.dragToDismiss = true
viewController.modalController?.avoidKeyboard = true // auto push up when keyboard is visible
```

## Examples

Example project provided in Example folder.

## Requirements

* iOS 9+
* Swift 4.2+
