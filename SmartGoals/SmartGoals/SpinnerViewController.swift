//
//  SpinnerViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/25/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    var message = ""
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var label: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        label.text = message
        activityIndicator.startAnimating()
    }
}
