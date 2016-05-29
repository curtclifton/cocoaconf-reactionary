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
    
    private var mainWindow: UIWindow!
    
    private var root: UISplitViewController {
        return mainWindow.rootViewController as! UISplitViewController // configuration error if not
    }

    private var masterViews: [UIViewController] = []
    private var detailViews: [UIViewController] = [] {
        didSet {
            print("set detailViews to “\(detailViews)”")
            // CCC, 5/29/2016. actual update what's showing based on detailViews and split view state?
        }
    }
    private var hasNoRealDetails: Bool {
        if detailViews.isEmpty {
            return true
        }
        if detailViews.count > 1 {
            return false
        }
        let isEmptyDetails = (detailViews.first is EmptyDetailViewController)
        return isEmptyDetails
    }
    
    func configure(forWindow window: UIWindow) {
        mainWindow = window
        
        root.delegate = self
        
        // At launch, we expect the root split view controller to be expanded and to have a master and a detail navigation controller
        assert(root.viewControllers.count == 2)
        
        let detailNavigationController = root.viewControllers.last as! UINavigationController // configuration error if not
        let emptyDetailView = detailNavigationController.topViewController! // configuration error if not set
        emptyDetailView.navigationItem.leftBarButtonItem = root.displayModeButtonItem()
        detailViews = [emptyDetailView]
        
        let masterNavigationController = root.viewControllers.first as! UINavigationController // configuration error if not
        let homeTabView = masterNavigationController.topViewController! // configuration error if not set
        masterViews = [homeTabView]
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
        if hasNoRealDetails {
            detailViews = [viewController]
        } else {
            detailViews.append(viewController)
        }
        // CCC, 5/29/2016. can we use didSet on detailViews to do the work?
//        root.showDetailViewController(viewController, sender: nil)
//        detail.setViewControllers([viewController], animated: false)
    }
    
    func dismissDetail(viewController: UIViewController) {
        // CCC, 5/28/2016. need a smarter implementation here, probably want to pop the nav controller stack and only present the placeholder if empty? or maybe keep our own array of the view controllers that we think should be on the nav stack
        guard let existingIndex = detailViews.indexOf(viewController) else {
            // not on stack, so nothing to do
            return
        }
        
        if existingIndex == 0 {
            // popping only real view controller
            let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
            detailViews = [emptyDetailViewController]
            return
        }
        
        detailViews = Array(detailViews.prefixUpTo(existingIndex))
        // CCC, 5/29/2016. can we use didSet on detailViews to do the work?
//        root.showDetailViewController(emptyDetailViewController, sender: nil)
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