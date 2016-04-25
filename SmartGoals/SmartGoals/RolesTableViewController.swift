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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.title = NSLocalizedString("Roles", comment: "list title")

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        
        // CCC, 4/24/2016. Do we want to use a Router to control detail views and whatnot?
        
        // CCC, 4/23/2016. This hacky generated code is like what you need to go fish for the detail view:
//        if let split = self.splitViewController {
//            let controllers = split.viewControllers
//            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
//        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        // CCC, 4/24/2016. Call through to rolesController
        // CCC, 4/24/2016. update the table when the results come back
//        objects.insert(NSDate(), atIndex: 0)
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

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

    // MARK: - Table View

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // CCC, 4/24/2016. Call through to rolesController
            // CCC, 4/24/2016. update the table when the results come back
//            objects.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

