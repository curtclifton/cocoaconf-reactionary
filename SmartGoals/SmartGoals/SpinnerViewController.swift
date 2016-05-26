//
//  SpinnerViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/25/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Reactionary
import UIKit

class SpinnerViewController: UIViewController {
    static func present(from host:UIViewController, message: String, signal: Signal<Bool>) {
        // CCC, 5/25/2016. implement
    }
    
    var message = ""
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var label: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        label.text = message
        activityIndicator.startAnimating()
    }
}
