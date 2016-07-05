//
//  NextViewController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/30/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import UIKit

class NextViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // Revert navigation bar translucent style to default
    navigationBarNonTranslecentStyle()
    // Update side menu after reverted navigation bar style
    sideMenuManager?.sideMenuController()?.sideMenu?.isNavbarHiddenOrTranslucent = false
    
    // Add left bar button item
    let leftBarItem = UIBarButtonItem(title: "Toggle", style: .Plain, target: self, action: #selector(toggleSideMenu))
    navigationItem.leftBarButtonItem = leftBarItem
    
    title = "Next ViewController"
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func toggleSideMenu() {
    sideMenuManager?.toggleSideMenuView()
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
