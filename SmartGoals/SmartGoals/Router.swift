//
//  Router.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/27/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import Reactionary
import UIKit

/// This class provides a common point of control to manage the display of master and detail views in the app.
class Router {
    static var sharedRouter = Router()
    
    var mainWindow: UIWindow!
    
    var root: UISplitViewController {
        return mainWindow.rootViewController as! UISplitViewController // configuration error if not
    }

    var detail: UINavigationController {
        return root.viewControllers.last as! UINavigationController // configuration error if not
    }
    
    func configure(forWindow window: UIWindow) {
        mainWindow = window
        
        detail.topViewController!.navigationItem.leftBarButtonItem = root.displayModeButtonItem() // configuration error if not set
        root.delegate = self
    }
    
    func blockInteraction(untilTrue signal: Signal<Bool>, message: String) {
        let application = UIApplication.sharedApplication()
        application.beginIgnoringInteractionEvents()
        SpinnerViewController.present(from: root, message: message, signal: signal) {
            application.endIgnoringInteractionEvents()
        }
    }
    
    func showDetail(viewController: UIViewController) {
        detail.setViewControllers([viewController], animated: false)
    }
    
    func dismissDetail(viewController: UIViewController) {
        // CCC, 5/28/2016. need a smarter implementation here, probably want to pop the nav controller stack and only present the placeholder if empty? or maybe keep our own array of the view controllers that we think should be on the nav stack
        let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
        detail.setViewControllers([emptyDetailViewController], animated: false)
    }
}

// MARK: - Split view
extension Router: UISplitViewControllerDelegate {
    @objc func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? EmptyDetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
}