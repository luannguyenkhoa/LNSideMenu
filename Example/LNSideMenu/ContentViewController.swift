//
//  ContentViewController.swift
//  LNSideMenu
//
//  Created by Luan Nguyen on 8/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Disable sidemene
    sideMenuManager?.sideMenuController()?.sideMenu?.disabled = true
  }
  
}
