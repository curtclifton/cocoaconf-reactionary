//
//  RolesController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/24/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
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
    
    private var rolesSignal: Signal<[Role]>!
    
    // MARK: - NSObject subclass
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundSignal = sharedModel.valuesSignalForType(Role.self)
        rolesSignal = QueueSpecificSignal<[Role]>(signal: backgroundSignal, notificationQueue: NSOperationQueue.mainQueue())
        rolesSignal.map { (roles: [Role]) -> Void in
            self.roles = roles
        }
    }
    
    // MARK: - Internal API
    
    func insertItem(sender: AnyObject? = nil) {
        let _ = sharedModel.instantiateObjectOfType(Role.self)
    }
    
    func deleteItem(atIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        guard let roleToDelete = roles[row, defaultValue: nil] else {
            assert(false, "unexpected index path: \(indexPath)")
            return
        }
        
        sharedModel.delete(value: roleToDelete)
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
