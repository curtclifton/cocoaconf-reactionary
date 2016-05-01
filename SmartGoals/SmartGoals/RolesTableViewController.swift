//
//  RolesTableViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 1/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit

// CCC, 4/23/2016. Likely need code along these lines for each of the tab views
final class RolesTableViewController: UITableViewController {

    // CCC, 4/23/2016. May want a generic detail view controller protocol? Or maybe just use a computed property to get the non-empty view controller if any?
//    var detailViewController: DetailViewController? = nil
    @IBOutlet var rolesController: RolesController!
    
    // MARK: - UIViewController subclass
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // CCC, 4/24/2016. Do we want to use a Router to control detail views and whatnot?
        
        // CCC, 4/23/2016. This hacky generated code is like what you need to go fish for the detail view:
//        if let split = self.splitViewController {
//            let controllers = split.viewControllers
//            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
//        }
    }

    override func viewWillAppear(animated: Bool) {
        // CCC, 4/24/2016. OK? Reaching through to nav controller to circumvent tab bar controller shenanigans
        let navigationItem = tabBarController!.navigationItem
        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.title = NSLocalizedString("Roles", comment: "list title")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: rolesController, action: #selector(RolesController.insertItem(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // CCC, 4/24/2016. Do we want to use a Router to control detail views and whatnot?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // CCC, 4/23/2016. Handle pushing actual detail
//        if segue.identifier == "showDetail" {
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let object = objects[indexPath.row] as! NSDate
//                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // CCC, 4/24/2016. Do we want to use a Router to control detail views and whatnot?
        print("tap: \(indexPath)")
    }
}

