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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let router = Router.sharedRouter
        router.configure(forWindow: self.window!)
        
        let vendor = sharedModelVendor()
        if !vendor.isPrimed {
            let isPrimedSignal = vendor.map { _ in true }
            router.blockInteraction(untilTrue: isPrimedSignal, message: NSLocalizedString("Loading Data", comment: "wait screen message"))
        }
        
        return true
    }
}

