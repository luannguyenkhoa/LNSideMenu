//
//  ViewController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/22/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import LNSideMenu

class ViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var barButton: UIBarButtonItem!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // FIXME: Remove code below if u're using your own menu
    setupNavforDefaultMenu()
  }

  private func setupNavforDefaultMenu() {
    barButton.image = UIImage(named: "burger")?.withRenderingMode(.alwaysOriginal)
    // Set navigation bar translucent style
    self.navigationBarTranslucentStyle()
    // Update side menu
    sideMenuManager?.instance()?.menu?.isNavbarHiddenOrTransparent = true
    // Re-enable sidemenu
    sideMenuManager?.instance()?.menu?.disabled = false
  }
  
  @IBAction func toogleSideMenu(_ sender: AnyObject) {
    sideMenuManager?.toggleSideMenuView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
