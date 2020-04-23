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
viewController.presentAsModal(animatedFrom: view)

// Dismissing
viewController.dismissModal(animated: true, completion: nil)
```

## Examples

Example project provided in Example folder.

## Requirements

* iOS 9+
* Swift 4.2+
