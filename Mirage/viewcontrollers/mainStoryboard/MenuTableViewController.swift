//
//  MenuTableViewController.swift
//  Mirage
//
//  Created by Siena Idea on 26/05/16.
//  Copyright © 2016 Siena Idea. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var exitLabel: UILabel!
    @IBOutlet weak var imageViewExit: UIImageView!
    @IBOutlet weak var optionsLabel: UILabel!
    
    static var person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = MenuTableViewController.person.name
        loginLabel.text = MenuTableViewController.person.user.email
        optionsLabel.text = "Opções"
        exitLabel.text = "Sair"
        
        imageViewExit.image = ImageUtil.imageExitButton
        imageViewExit.tintColor = UIColor.lightGrayColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        userNameLabel.text = MenuTableViewController.person.name
        loginLabel.text = MenuTableViewController.person.user.email
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    @IBAction func exitButton(sender: AnyObject) {
        Server.token.removeAll()
    }
}
