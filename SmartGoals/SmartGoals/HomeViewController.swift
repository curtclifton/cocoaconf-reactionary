//
//  HomeViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/23/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit
import SmartGoalsModelTouch

class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var viewControllers: [UIViewController] = []

        let roleController = MainStoryboard().instantiateViewController(.Roles)
        roleController.tabBarItem.title = NSLocalizedString("Roles", comment: "tab title")
        // CCC, 4/24/2016. Set image
        viewControllers.append(roleController)
        
        for timeScale in TimeScale.allValues() {
            let goalSetController = MainStoryboard().instantiateViewController(.GoalSet)
            goalSetController.tabBarItem.title = timeScale.title
            // CCC, 4/24/2016. Set image
            viewControllers.append(goalSetController)
        }
        
        self.viewControllers = viewControllers
        
        // CCC, 4/24/2016. Should be whatever the title of the selected tab is, used on button to reveal sidebar when it's hidden:
        navigationController!.title = NSLocalizedString("Home", comment: "list title")
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
