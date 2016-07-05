//
//  LNSideMenuNavigationController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

public class LNSideMenuNavigationController: UINavigationController, LNSideMenuProtocol {

  public var sideMenu: LNSideMenu?
  public var sideMenuAnimationType: LNSideMenuAnimation = .Default
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  public func setContentViewController(contentViewController: UIViewController) {
    // Hide side menu at the first
    sideMenu?.hideSideMenu()
    // Add contentViewController within default animation or none
    switch sideMenuAnimationType {
    case .None:
      self.viewControllers = [contentViewController]
      break
    case .Default:
      contentViewController.navigationItem.hidesBackButton = true
      setViewControllers |> ([contentViewController], true)
      break
    }
  }
  
  /*
   The app will not supports the device rotation, it's perfectly compatible with the portrait mode.
   Because the design will be broken in the landscape mode.
   */
  public override func shouldAutorotate() -> Bool {
    return false
  }
  override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.Portrait
  }
}
