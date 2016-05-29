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
        return mainWindow.rootViewController as! UISplitViewController // configuration error to not have set
    }
    
    func configure(forWindow window: UIWindow) {
        mainWindow = window
        
        let splitViewController = mainWindow.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
    }
    
    func blockInteraction(untilTrue signal: Signal<Bool>, message: String) {
        let application = UIApplication.sharedApplication()
        application.beginIgnoringInteractionEvents()
        SpinnerViewController.present(from: root, message: message, signal: signal) {
            application.endIgnoringInteractionEvents()
        }
    }
    
    func showDetail(viewController: UIViewController) {
        // CCC, 5/1/2016. In landscape, we lose the navigation controller for the details when we do this:
        root.showDetailViewController(viewController, sender: nil)
    }
    
    func dismissDetail(viewController: UIViewController) {
        // CCC, 5/28/2016. need a smarter implementation here, probably want to pop the nav controller stack and only present the placeholder if empty?
        let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
        root.showDetailViewController(emptyDetailViewController, sender: nil)
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