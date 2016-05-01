//
//  RoleDetailViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit

class RoleDetailViewController: UIViewController {

    @IBOutlet var explanationLabel: UILabel!
    @IBOutlet var explanation: UITextView!
    
    private var hasAddedBaselineConstraint = false
        
    override func viewWillAppear(animated: Bool) {
        explanation.layer.cornerRadius = 5.0
        explanation.layer.borderWidth = 0.5
        explanation.layer.borderColor = UIColor.grayColor().CGColor
    }
}
