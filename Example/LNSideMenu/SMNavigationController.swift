//
//  SMNavigationController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/30/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import LNSideMenu

class SMNavigationController: LNSideMenuNavigationController {
  
  fileprivate var items:[String]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    // Using default side menu
    items = ["All","Hot Food","Sandwiches","Hot Pots","Hot Rolls", "Salads","Pies","Dessrts","Drinks","Breakfast","Cookies","Lunch fers"]
    initialSideMenu(.left)
    // Custom side menu
//    initialCustomMenu(pos: .left)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  fileprivate func initialSideMenu(_ position: Position) {
    menu = LNSideMenu(sourceView: view, menuPosition: position, items: items!)
    menu?.menuViewController?.menuBgColor = UIColor.black.withAlphaComponent(0.85)
    menu?.delegate = self
    menu?.underNavigationBar = true
    view.bringSubview(toFront: navigationBar)
  }
  
  fileprivate func initialCustomMenu(pos position: Position) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuTableViewController") as! LeftMenuTableViewController
    vc.delegate = self
    menu = LNSideMenu(navigation: self, menuPosition: position, customSideMenu: vc)
    menu?.delegate = self
    menu?.enableDynamic = true
    // Moving down the menu view under navigation bar
    menu?.underNavigationBar = true
  }
  
  fileprivate func setContentVC(_ index: Int) {
    print("Did select item at index: \(index)")
    var nViewController: UIViewController? = nil
    if let viewController = viewControllers.first , viewController is NextViewController {
      nViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController")
    } else {
      nViewController = storyboard?.instantiateViewController(withIdentifier: "NextViewController")
    }
    if let viewController = nViewController {
      self.setContentViewController(viewController)
    }
    // Test moving up/down the menu view
    if let sm = menu, sm.isCustomMenu {
      menu?.underNavigationBar = false
    }
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
  
  func didSelectItemAtIndex(_ index: Int) {
    setContentVC(index)
  }
}

extension SMNavigationController: LeftMenuDelegate {
  func didSelectItemAtIndex(index idx: Int) {
    menu?.toggleMenu() { [unowned self] in
      self.setContentVC(idx)
    }
  }
}

