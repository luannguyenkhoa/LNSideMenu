# LNSideMenu

[![CI Status](http://img.shields.io/travis/Luan Nguyen/LNSideMenu.svg?style=flat)](https://travis-ci.org/Luan Nguyen/LNSideMenu)
[![Version](https://img.shields.io/cocoapods/v/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![License](https://img.shields.io/cocoapods/l/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)
[![Platform](https://img.shields.io/cocoapods/p/LNSideMenu.svg?style=flat)](http://cocoapods.org/pods/LNSideMenu)

A side menu based on [ENSwiftSideMenu](https://github.com/evnaz/ENSwiftSideMenu). The side menu view controller is available and it will be automatically added to Left/Right container view. This project is written in **Swift**:

<a href="http://www.youtube.com/watch?feature=player_embedded&v=KdHJ3Q43wtY
" target="_blank"><img src="http://img.youtube.com/vi/KdHJ3Q43wtY/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>

## Usage

. Create a UINavigationController subclassing from LNSideMenuNavigationController

. Initilize the menu view with a source view:
```swift
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    let items = ["All","Popular","Invitations","Anniversaries","Concerts", "Cultural","Fesivals","Holidays","Cele","Lonely","Daily","Hobbit","Alone","Single","Fesivals","Holidays","Invitations","Anniversaries"]
    sideMenu = LNSideMenu(sourceView: view, menuPosition: .Left, items: items)
    // One more optional parameter is highlighItemAtIndex (Int)
    sideMenu?.delegate = self
    view.bringSubviewToFront(navigationBar)
  }
```
. Implementing delegate methods

. To change content viewcontroller use next line in your UINavigationController subclassing

```swift
  func didSelectItemAtIndex(index: Int) {
    // TODO: Get your destViewController in here
    self.setContentViewController(destViewController)
  }
```

. Toggle menu:

```swift
  self.sideMenuManager?.toggleSideMenuView()
```

. It has a feature for navigation bar translucent. To use this feature, just add code as below:
```swift
  self.navigationBarTranslucentStyle()
  sideMenuManager?.sideMenuController()?.sideMenu?.isNavbarHiddenOrTranslucent = true
```

. Check example project for more explaination

## Requirements
. Xcode 7.3 or higher
. iOS 8 or higher

## Installation

### Cocoapods

LNSideMenu is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LNSideMenu', '~> 1.0.1'
```

### Manual

Adding all files in LNSideMenu folder to your project folder

## TODO

Implementing the UIDynamic's bouncing animation and UIBlurEffect for side menu's background 

## Author

Luan Nguyen

## License

LNSideMenu is available under the MIT license. See the LICENSE file for more info.
