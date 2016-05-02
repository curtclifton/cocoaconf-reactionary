//
//  RoleDetailViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import SmartGoalsModelTouch
import UIKit

class RoleDetailViewController: UIViewController {

    // CCC, 5/1/2016. It would be nice to isolate this from the model, perhaps, but that can be a refactoring.
    var identifier: Identifier<Role>!
    private var signal: Signal<Role>?
    private var role: Role? {
        didSet {
            if let role = role where role != oldValue {
                sharedModel.update(fromValue: role)
            }
        }
    }
    
    @IBOutlet var name: UITextField!
    @IBOutlet var explanation: UITextView! {
        didSet {
            explanation.layer.cornerRadius = 5.0
            explanation.layer.borderWidth = 0.5
            explanation.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    @IBOutlet var isActive: UISwitch!
    
    override func viewDidLoad() {
        let signal = sharedModel.valueSignalForIdentifier(identifier)
        self.signal = signal
        
        // Update local copy of role whenever it changes
        signal.map { self.role = $0 }
        
        // Make name text field update whenever the name changes
        let shortNameSignal = signal
            .map({
                $0.shortName
            })
        name.takeValue(fromSignal: shortNameSignal)
        
        // Update our local copy of role whenever the user types
        let shortNameUpdateSignal = name.valueChangedSignal()
        shortNameUpdateSignal
            .flatmap({ $0 })
            .map({
                self.role?.shortName = $0
            })
        
        // CCC, 5/1/2016. Need to wire signals for explanation and isActive
    }
}
