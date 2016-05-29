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
    
    var detailViews: [UIViewController] = []
    
    func configure(forWindow window: UIWindow) {
        mainWindow = window
        
        let emptyDetailView = detail.topViewController! // configuration error if not set
        detailViews = [emptyDetailView]
        emptyDetailView.navigationItem.leftBarButtonItem = root.displayModeButtonItem()
        root.delegate = self
    }
    
    func blockInteraction(untilTrue signal: Signal<Bool>, message: String) {
        let application = UIApplication.sharedApplication()
        application.beginIgnoringInteractionEvents()
        SpinnerViewController.present(from: root, message: message, signal: signal) {
            application.endIgnoringInteractionEvents()
        }
    }
    
    // -------------------------------------------------------------------------
    // CCC, 5/28/2016. I'm starting to think that I should manage the full set of VCs on each virtual nav stack independently here, then override all of the UISplitViewControllerDelegate methods to just manage the damn thing myself.
    // -------------------------------------------------------------------------
    
    func showDetail(viewController: UIViewController) {
        // CCC, 5/28/2016. Docs say this should push on nav controller:
        detailViews.append(viewController)
        root.showDetailViewController(viewController, sender: nil)
//        detail.setViewControllers([viewController], animated: false)
    }
    
    func dismissDetail(viewController: UIViewController) {
        // CCC, 5/28/2016. need a smarter implementation here, probably want to pop the nav controller stack and only present the placeholder if empty? or maybe keep our own array of the view controllers that we think should be on the nav stack
        let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
        detailViews = [emptyDetailViewController]
        // CCC, 5/28/2016. Docs say this should push on nav controller:
        root.showDetailViewController(emptyDetailViewController, sender: nil)
//        detail.setViewControllers([emptyDetailViewController], animated: false)
    }
}

// MARK: - Split view
extension Router: UISplitViewControllerDelegate {
    @objc func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        // CCC, 5/28/2016. shouldn't really need this override, but trying to figure out how docs are wrong
        return false
    }
    
    @objc func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? EmptyDetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    @objc func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        // CCC, 5/28/2016. really?
        if detailViews.isEmpty {
            let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
            return emptyDetailViewController
        }
        
        return nil
    }
}