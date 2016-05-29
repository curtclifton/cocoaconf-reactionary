//
//  RolesController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/24/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import Reactionary
import SmartGoalsModelTouch

// CCC, 4/24/2016. Should be able to extract a protocol for the table view data sources that cover the model
final class RolesController: NSObject, UITableViewDataSource {
    // This needs to be an optional rather than an implicitly unwrapped optional so that we don't trap on roles.didSet if the database is live before all objects are awoken from the nib.
    @IBOutlet var tableView: UITableView?
    
    private var roles: [Role] = [] {
        didSet {
            // CCC, 4/26/2016. Need to diff and do a sensible reload
            tableView?.reloadData()
        }
    }
    
    private var rolesSignal: Signal<[Role]>?
    
    // MARK: - NSObject subclass
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedModelVendor().map { sharedModel in
            let rolesSignal = sharedModel.valuesSignalForType(Role.self)
            rolesSignal.map { (roles: [Role]) -> Void in
                self.roles = roles
            }
            self.rolesSignal = rolesSignal // necessary to keep signal alive
        }
    }
    
    // MARK: - Internal API
    
    func insertItem(sender: AnyObject? = nil) {
        sharedModelVendor().map { sharedModel in
            let _ = sharedModel.instantiateObjectOfType(Role.self)
        }
    }
    
    func deleteItem(atIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        guard let roleToDelete = roles[row, defaultValue: nil] else {
            assert(false, "unexpected index path: \(indexPath)")
            return
        }
        
        sharedModelVendor().map { sharedModel in
            sharedModel.delete(value: roleToDelete)
        }
    }
    
    func showDetail(forRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        guard let roleToEdit = roles[row, defaultValue: nil] else {
            // This might just be corrupted state in a table view. Log and ignore request.
            NSLog("Cannot show detail view for unexpected index path: \(indexPath)")
            return
        }
        
        let detailViewController = mainStoryboard.instantiateViewController(.RoleDetail) as! RoleDetailViewController
        sharedModelVendor().map { sharedModel in
            let signal = sharedModel.valueSignalForIdentifier(roleToEdit.identifier)
            detailViewController.configure(withSignal: signal) { role in
                sharedModel.update(fromValue: role)
            }
            
            var isShowing = false
            signal.map { roleResult in
                switch roleResult {
                case .value:
                    // got a value, so present
                    if !isShowing {
                        Router.sharedRouter.showDetail(detailViewController)
                        isShowing = true
                    }
                case .error(.deleted):
                    if isShowing {
                        Router.sharedRouter.dismissDetail(detailViewController)
                        isShowing = false
                    }
                }
            }
        }
   
        
    }

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell") else {
            fatalError("Misconfigured table view")
        }
        
        let viewModel = roles[indexPath.row].viewModel
        cell.configure(withViewModel: viewModel)
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteItem(atIndexPath: indexPath)
        }
    }
}


