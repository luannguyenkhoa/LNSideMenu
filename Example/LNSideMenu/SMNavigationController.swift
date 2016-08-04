//
//  SMNavigationController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/30/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import LNSideMenu

class SMNavigationController: LNSideMenuNavigationController {
  
  private var items:[String]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    items = ["All","Hot Food","Sandwiches","Hot Pots","Hot Rolls", "Salads","Pies","Dessrts","Drinks","Breakfast","Cookies","Lunch"]
    initialSideMenu(.Left)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func initialSideMenu(position: Position) {
    sideMenu = LNSideMenu(sourceView: view, menuPosition: position, items: items!)
    sideMenu?.menuViewController.menuBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.85)
    sideMenu?.delegate = self
    view.bringSubviewToFront(navigationBar)
  }
}

extension SMNavigationController: LNSideMenuDelegate {
  func sideMenuWillOpen() {
    print("sideMenuWillOpen")
  }
  
  func sideMenuWillClose() {
    print("sideMenuWillClose")
  }
  
  func sideMenuDidClose() {
    print("sideMenuDidClose")
  }
  
  func sideMenuDidOpen() {
    print("sideMenuDidOpen")
  }
  
  func didSelectItemAtIndex(index: Int) {
    print("Did select item at index: \(index)")
    var nViewController: UIViewController? = nil
    if let viewController = viewControllers.first where viewController is NextViewController {
      nViewController = storyboard?.instantiateViewControllerWithIdentifier("ViewController")
    } else {
      nViewController = storyboard?.instantiateViewControllerWithIdentifier("NextViewController")
    }
    if let viewController = nViewController {
      self.setContentViewController(viewController)
    }
  }
}
