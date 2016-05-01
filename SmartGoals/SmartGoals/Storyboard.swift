//
//  Storyboard.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/24/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerType: RawRepresentable {
    var rawValue: String { get }
}

protocol Storyboard {
    associatedtype ContainedViewControllerType: ViewControllerType
    var storyboardName: String { get }
    
    // CONSIDER: can we force the return type too? probably need dependent types
    func instantiateViewController(controller: ContainedViewControllerType) -> UIViewController
}

extension Storyboard {
    func instantiateViewController(controller: ContainedViewControllerType) -> UIViewController {
        let storyboardObject = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboardObject.instantiateViewControllerWithIdentifier(controller.rawValue)
        return viewController
    }
}

enum MainViewControllers: String, ViewControllerType {
    case Roles = "Roles"
    case GoalSet = "GoalSet"
    case RoleDetail = "RoleDetail"
}

struct MainStoryboard: Storyboard {
    typealias ContainedViewControllerType = MainViewControllers
    let storyboardName = "Main"
}

let mainStoryboard = MainStoryboard()
