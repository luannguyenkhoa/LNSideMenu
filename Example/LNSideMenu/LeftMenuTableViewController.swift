//
//  LeftMenuTableViewController.swift
//  LNSideMenu
//
//  Created by Luan Nguyen on 10/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

protocol LeftMenuDelegate: class {
  func didSelectItemAtIndex(index idx: Int)
}


class LeftMenuTableViewController: UIViewController {
  
  // MARK: IBOutlets
  @IBOutlet weak var userAvatarImg: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var menuTableView: UITableView!
  
  // MARK: Properties
  let kCellIdentifier = "menuCell"
  let items = ["All","Hot Food","Sandwiches","Hot Pots","Hot Rolls", "Salads","Pies","Dessrts","Drinks","Breakfast","Cookies","Lunch", "Bibimbap", "Salmon", "Shrimp", "Tofu"]
  weak var delegate: LeftMenuDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
   let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
    menuTableView.register(nib, forCellReuseIdentifier: kCellIdentifier)
   
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
//    menuTableView.reloadSections(IndexSet(integer: 0), with: .none)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Circle avatar imageview
    userAvatarImg.layer.cornerRadius = userAvatarImg.frame.size.width/2
    userAvatarImg.layer.masksToBounds = true
    userAvatarImg.clipsToBounds = true
    
    // Border
    userAvatarImg.layer.borderWidth = 1
    userAvatarImg.layer.borderColor = UIColor.black.cgColor
    
    // Shadow img
    userAvatarImg.layer.shadowColor = UIColor.white.cgColor
    userAvatarImg.layer.shadowOpacity = 1
    userAvatarImg.layer.shadowOffset = .zero
    userAvatarImg.layer.shadowRadius = 10
    userAvatarImg.layer.shadowPath = UIBezierPath(rect: userAvatarImg.bounds).cgPath
    userAvatarImg.layer.shouldRasterize = true
  }
}

extension LeftMenuTableViewController: UITableViewDataSource {
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! MenuTableViewCell
    cell.titleLabel.text = items[indexPath.row]
    return cell
  }
  
}

extension LeftMenuTableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let delegate = delegate {
      delegate.didSelectItemAtIndex(index: indexPath.row)
    }
  }
}
