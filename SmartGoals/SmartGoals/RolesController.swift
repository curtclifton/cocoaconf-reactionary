//
//  RolesController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/24/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import SmartGoalsModelTouch

// CCC, 4/24/2016. Might be able to extract a protocol for the table view data sources that cover the model
final class RolesController: NSObject, UITableViewDataSource {
    private var roles: [Role] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        #error HERE is where you're working.
        // CCC, 4/24/2016. Kick off roles fetch, retain the signal, implement editing operations
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell") else {
            fatalError("Misconfigured table view")
        }
        
        // CCC, 4/24/2016. want a custom cell eventually, set the cell's view model object to the correct role
        cell.textLabel?.text = roles[indexPath.row].shortName
        return cell
    }
}
