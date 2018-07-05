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
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    /// Should set the below flag here to avoid its value gets changed while doing interactivePopGestureRecognizer
    // Disable sidemene
    sideMenuManager?.instance()?.menu?.disabled = true
  }
  
}
