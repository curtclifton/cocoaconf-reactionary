//
//  RolesTableViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 1/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit

// CCC, 4/23/2016. Likely need code along these lines for each of the tab views. Extract a protocol.
final class RolesTableViewController: UITableViewController {

    @IBOutlet var rolesController: RolesController!
    
    // MARK: - UIViewController subclass
    
    override func viewWillAppear(animated: Bool) {
        // Reaching through to tab bar controller's nav item since it's directly nested in the navigation controller, not us
        let navigationItem = tabBarController!.navigationItem
        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.title = NSLocalizedString("Roles", comment: "list title")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: rolesController, action: #selector(RolesController.insertItem(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // CCC, 4/24/2016. Do we want to use a Router to control detail views and whatnot?
        if let splitViewController = self.splitViewController {
            let detailViewController = rolesController.detailView(forRowAtIndexPath: indexPath)
            // CCC, 5/1/2016. In landscape, we lose the navigation controller for the details when we do this:
            splitViewController.showDetailViewController(detailViewController, sender: nil)
        }
    }
}

