//
//  HomeViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/23/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("View Controllers: \(viewControllers)")
        let tabLabels = [
            NSLocalizedString("5 Year", comment: "goal set interval"),
            NSLocalizedString("1 Year", comment: "goal set interval"),
            NSLocalizedString("Monthly", comment: "goal set interval"),
        ]
        var tabLabelGenerator = tabLabels.generate()
        for case let goalSetViewController as GoalSetTableViewController in viewControllers! {
            let tabBarItem = goalSetViewController.tabBarItem
            tabBarItem.title = tabLabelGenerator.next()! // programmer error to not match tabLabels to storyboard
            print(goalSetViewController)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
