//
//  LNSideMenuNavigationController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

open class LNSideMenuNavigationController: UINavigationController, LNSideMenuProtocol {

  open var sideMenu: LNSideMenu?
  open var sideMenuAnimationType: LNSideMenuAnimation = .default
  
  open override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  open func setContentViewController(_ contentViewController: UIViewController) {
    // Hide side menu at the first
    sideMenu?.hideSideMenu()
    // Add contentViewController within default animation or none
    switch sideMenuAnimationType {
    case .none:
      self.viewControllers = [contentViewController]
      break
    case .default:
      contentViewController.navigationItem.hidesBackButton = true
      setViewControllers |> ([contentViewController], true)
      break
    }
  }

  /*
   The app will not supports the device rotation, it's perfectly compatible with the portrait mode.
   Because the design will be broken in the landscape mode.
   */
  open override var shouldAutorotate : Bool {
    return false
  }
  override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }
}
