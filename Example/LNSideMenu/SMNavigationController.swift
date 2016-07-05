//
//  SMNavigationController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/30/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import LNSideMenu

class SMNavigationController: LNSideMenuNavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let items = ["All","Popular","Invitations","Anniversaries","Concerts", "Cultural","Fesivals","Holidays","Cele","Lonely","Daily","Hobbit","Alone","Single","Fesivals","Holidays","Invitations","Anniversaries"]
    sideMenu = LNSideMenu(sourceView: view, menuPosition: .Left, items: items)
    sideMenu?.delegate = self
    view.bringSubviewToFront(navigationBar)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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