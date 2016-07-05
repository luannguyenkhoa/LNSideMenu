//
//  ViewController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import LNSideMenu

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Set navigation bar translucent style
    self.navigationBarTranslucentStyle()
    // Update side menu
    sideMenuManager?.sideMenuController()?.sideMenu?.isNavbarHiddenOrTranslucent = true
  }

  @IBAction func toogleSideMenu(sender: AnyObject) {
    sideMenuManager?.toggleSideMenuView()
  }
  
  @IBAction func toggleRightMenu(sender: AnyObject) {
    sideMenuManager?.toggleSideMenuView()
  }
  
  @IBAction func switchSideMenuPosition(sender: AnyObject) {
    if let navigationController = self.navigationController as? SMNavigationController {
      navigationController.switchPosition()
      navigationController.sideMenu?.isNavbarHiddenOrTranslucent = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

