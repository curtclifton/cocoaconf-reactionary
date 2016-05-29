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

    private var masterViews: [UIViewController] = [] {
        didSet {
            print("set masterViews to “\(masterViews)”")
            updateDisplay(oldMasterViews: oldValue)
        }
    }

    private var detailViews: [UIViewController] = [] {
        didSet {
            print("set detailViews to “\(detailViews)”")
            updateDisplay(oldDetailViews: oldValue)
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
    
    // MARK: Internal API
    
    func configure(forWindow window: UIWindow) {
        mainWindow = window
        
        root.delegate = self
        
        // At launch, we expect the root split view controller to be expanded and to have a master and a detail navigation controller
        assert(root.viewControllers.count == 2)
        
        let detailNavigationController = root.viewControllers.last as! UINavigationController // configuration error if not
        let emptyDetailView = detailNavigationController.topViewController! // configuration error if not set
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
    
    // MARK: Private API
    
    // CCC, 5/29/2016. rename parameters
    // CCC, 5/29/2016. should this really just be a pair of functions? Do we need to call it to update both? Seems likely. Maybe a pair of update flags instead of arrays?
    private func updateDisplay(oldMasterViews oldMasterViews: [UIViewController]? = nil, oldDetailViews: [UIViewController]? = nil) {
        if root.collapsed {
            // CCC, 5/29/2016. do the right thing
        } else {
            if oldMasterViews != nil {
                let masterNavigationController = root.viewControllers.first as! UINavigationController
                updateNavigationStack(controller: masterNavigationController, new: masterViews)
            }
            if oldDetailViews != nil {
                let detailNavigationController = root.viewControllers.last as! UINavigationController
                updateNavigationStack(controller: detailNavigationController, new: detailViews)
                detailViews.first?.navigationItem.leftBarButtonItem = root.displayModeButtonItem()
            }
        }
    }
    
    // CCC, 5/29/2016. Probably don't need oldViews?
    private func updateNavigationStack(controller navigationController: UINavigationController, new newStack: [UIViewController]) {
        let currentCount = navigationController.viewControllers.count
        let newCount = newStack.count
        let isJustASwap = currentCount == 1 && newCount == 1
        navigationController.setViewControllers(newStack, animated: !isJustASwap)
        // Find where the current and desired stacks diverge.
//        let currentStack = navigationController.viewControllers
        
        
        // CCC, 5/29/2016. UINavCont should do this:
//        if newStack.startsWith(currentStack) {
//            let controllersToAdd = newStack.suffixFrom(currentStack.count)
//            for controller in controllersToAdd {
//                let shouldAnimate = (controller == controllersToAdd.last)
//                navigationController.pushViewController(controller, animated: shouldAnimate)
//            }
//        } else if currentStack.startsWith(newStack) {
//            // CCC, 5/29/2016. dismiss first different view
//        } else {
//            // CCC, 5/29/2016. no common base, just swap?
//            
//        }
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