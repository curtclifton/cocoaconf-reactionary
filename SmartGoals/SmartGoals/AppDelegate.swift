//
//  AppDelegate.swift
//  SmartGoals
//
//  Created by Curt Clifton on 1/26/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import UIKit
import SmartGoalsModelTouch
import Reactionary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    // CCC, 5/15/2016. hacking in to keep signal alive
    var modelInitiationSignal: Signal<(SmartGoalsModel?, Bool?, Bool?)>?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        let vendor = sharedModelVendor()
        if !vendor.isPrimed {
            application.beginIgnoringInteractionEvents()
            
            // on 0.5 second delay, if not yet live, present loading indicator
            let startSpinner = UpdatableSignal(withInitialValue: true).signal(withDelay: 2.0)
            let canEndSpinner = startSpinner.signal(withDelay: 3.0)
            
            let composite = vendor.signal(zippingWith: startSpinner, and: canEndSpinner)
            modelInitiationSignal = composite
            
            print("\(NSDate())")
            composite.map { [weak self] triple in
                guard let strongSelf = self else { return }
                let (sharedModel, start, canEnd) = triple
                switch (sharedModel, start, canEnd) {
                case (.None, .Some, .None):
                    print("start spinner") // CCC, 5/15/2016.
                case (.Some, .Some, .None):
                    print("keep spinning, we started and haven't spun long enough yet") // CCC, 5/15/2016.
                case (.Some, .Some, .Some):
                    print("stop spinner") // CCC, 5/15/2016.
                    strongSelf.modelInitiationSignal = nil
                case (.Some, .None, .None):
                    print("no need to spin, model went live quickly") // CCC, 5/15/2016.
                    strongSelf.modelInitiationSignal = nil
                default:
                    print("Unhandled case: \(triple)")
                }
            }
            
            // CCC, 5/15/2016. Would like to present a hold-ones-horses indicator after a beat if the database doesn't spin up immediately, then enable user interaction when it is up.
            // after at least one second, or when model is live, remove loading indicator
            vendor.map { _ in
                application.endIgnoringInteractionEvents()
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? EmptyDetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

