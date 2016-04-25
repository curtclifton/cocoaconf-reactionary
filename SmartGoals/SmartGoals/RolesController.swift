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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("Cell") else {
            fatalError("Misconfigured table view")
        }
        
        return cell
    }
}
