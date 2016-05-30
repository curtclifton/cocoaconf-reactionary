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
class Router: NSObject { // have to subclass NSObject so we can conform to UINavigationBarDelegate below
    static var sharedRouter = Router()
    
    private var mainWindow: UIWindow!
    
    private var root: UISplitViewController {
        return mainWindow.rootViewController as! UISplitViewController // configuration error if not
    }

    private var masterControllers: [UIViewController] = []
    private var detailControllers: [UIViewController] = []
    
    private var hasNoRealDetails: Bool {
        if detailControllers.isEmpty {
            return true
        }
        if detailControllers.count > 1 {
            return false
        }
        let isEmptyDetails = (detailControllers.first is EmptyDetailViewController)
        return isEmptyDetails
    }
    
    private var isConfigured = false
    
    // MARK: Internal API
    
    func configure(forWindow window: UIWindow) {
        mainWindow = window
        
        root.delegate = self
        
        // At launch, we expect the root split view controller to be expanded and to have a master and a detail navigation controller
        assert(root.viewControllers.count == 2)
        
        let detailNavigationController = root.viewControllers.last as! UINavigationController // configuration error if not
        let emptyDetailView = detailNavigationController.topViewController! // configuration error if not set
        detailControllers = [emptyDetailView]
        
        let masterNavigationController = root.viewControllers.first as! UINavigationController // configuration error if not
        let homeTabView = masterNavigationController.topViewController! // configuration error if not set
        masterControllers = [homeTabView]
        
        isConfigured = true
        update()
    }
    
    func blockInteraction(untilTrue signal: Signal<Bool>, message: String) {
        let application = UIApplication.sharedApplication()
        application.beginIgnoringInteractionEvents()
        SpinnerViewController.present(from: root, message: message, signal: signal) {
            application.endIgnoringInteractionEvents()
        }
    }
    
    func showDetail(viewController: UIViewController, replacing: Bool = false) {
        if hasNoRealDetails || replacing {
            detailControllers = [viewController]
        } else {
            detailControllers.append(viewController)
        }
        update()
    }
    
    func dismissDetail(viewController: UIViewController) {
        guard let existingIndex = detailControllers.indexOf(viewController) else {
            // not on stack, so nothing to do
            return
        }
        
        if existingIndex == 0 {
            // popping the only real view controller, so add placeholder
            let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
            detailControllers = [emptyDetailViewController]
        } else {
            detailControllers = Array(detailControllers.prefixUpTo(existingIndex))
        }
        update()
    }
    
    // MARK: Private API
    
    private func update(asIfCollapsed asIfCollapsed: Bool? = nil, primary: UINavigationController? = nil, secondary: UINavigationController? = nil) {
        guard isConfigured else {
            // we should be called again after router is fully configured
            return
        }
        
        let isCollapsed: Bool
        if let asIfCollapsed = asIfCollapsed {
            isCollapsed = asIfCollapsed
        } else {
            isCollapsed = root.collapsed
        }
        
        let primaryNavigationController = primary ?? (root.viewControllers.first as! UINavigationController)  // misconfigured if not
        
        if isCollapsed {
            let fullStack: [UIViewController]
            if hasNoRealDetails {
                fullStack = masterControllers
            } else {
                fullStack = masterControllers + detailControllers
                detailControllers.first?.navigationItem.leftBarButtonItem = nil
                detailControllers.first?.navigationItem.backBarButtonItem = nil
            }
            updateNavigationStack(controller: primaryNavigationController, new: fullStack)
        } else {
            updateNavigationStack(controller: primaryNavigationController, new: masterControllers)
            
            let detailNavigationController = secondary ?? (root.viewControllers.last as! UINavigationController) // misconfigured if not
            updateNavigationStack(controller: detailNavigationController, new: detailControllers)
            detailControllers.first?.navigationItem.leftBarButtonItem = root.displayModeButtonItem()
        }
    }
    
    private func updateNavigationStack(controller navigationController: UINavigationController, new newStack: [UIViewController]) {
        guard navigationController.viewControllers != newStack else {
            // nothing to do
            return
        }
        let currentCount = navigationController.viewControllers.count
        let newCount = newStack.count
        let isJustASwap = currentCount == 1 && newCount == 1
        navigationController.setViewControllers(newStack, animated: !isJustASwap)
        
        // If we're managing the stack, then we need to know when it changes
        navigationController.delegate = self
    }
}

// MARK: - Split view
extension Router: UISplitViewControllerDelegate {
    @objc func splitViewController(splitViewController: UISplitViewController, showViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        fatalError("use Router instance methods instead")
    }
    
    @objc func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
        fatalError("use Router instance methods instead")
    }
    
    @objc func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        // we always handle collapse to deal with our treatment of the detail nav stack
        update(asIfCollapsed: true)
        return true
    }
    
    @objc func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        let primary = primaryViewController as! UINavigationController // misconfigured if not
        let secondary = UINavigationController()
        
        update(asIfCollapsed: false, primary: primary, secondary: secondary)
        return secondary
    }
}

// MARK: - Navigation Bar

extension Router: UINavigationControllerDelegate {
    
    @objc func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        // When a nav controller pops (i.e., user went "back") we need to update our local state
        if root.collapsed {
            if root.viewControllers.count > 1 {
                // not combined yet, ignore assuming that we're handling the transition to make navigation controller match our state
                return
            }
            let combinedNavigationController = root.viewControllers.first as! UINavigationController // misconfigured if not
            assert(combinedNavigationController === navigationController)
            let currentStack = combinedNavigationController.viewControllers
            
            print("currentStack: \(currentStack)")
            
            let (masterSlice, detailSlice) = currentStack.split(atIndex: masterControllers.count)
            masterControllers = Array(masterSlice)
            if detailSlice.isEmpty {
                let emptyDetailViewController = MainStoryboard().instantiateViewController(.Empty)
                detailControllers = [emptyDetailViewController]
            } else {
                detailControllers = Array(detailSlice)
            }
        } else {
            let masterNavigationController = root.viewControllers.first as! UINavigationController // misconfigured if not
            let detailNavigationController = root.viewControllers.last as! UINavigationController // misconfigured if not
            if masterNavigationController === detailNavigationController {
                // not split yet, ignore assuming that we're handling the transition to make navigation controllers match state
                return
            }
            
            if navigationController === masterNavigationController {
                let currentMasterStack = masterNavigationController.viewControllers
                masterControllers = currentMasterStack
            } else if navigationController === detailNavigationController {
                let currentDetailStack = detailNavigationController.viewControllers
                detailControllers = currentDetailStack
            }
        }
    }
}