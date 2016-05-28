//
//  SpinnerViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 5/25/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Reactionary
import UIKit

class SpinnerViewController: UIViewController {
    private static var presenterCompositeSignal: Signal<(Bool?, Bool?, Bool?)>? {
        willSet {
            guard presenterCompositeSignal == nil || newValue == nil else {
                // must be setting once or clearing, get set when already set
                fatalError("haven't implemented having multiple delay spinners enqueued at once")
            }
        }
    }
    
    /// Waits asynchronously for `signal` to vend a value, presenting a delay indicator if needed.
    ///
    /// If `signal` vends a value quickly, then no delay indicator is presented. Otherwise an indicator is presented modally over the full screen and is left visible for at least long enough for the user to see it. It's dismissed when, or shortly after, `signal` vends its value.
    /// - parameter host: the view controller from which the delay indicator is presented
    /// - parameter message: a message to display below the indicator
    /// - parameter signal: its currentValue should go from nil to non-nil when the event for which we're waiting occurs
    /// - parameter completionHandler: invoked when `signal` vends a value if no delay indicator was presented, or otherwise when the delay indicator is dismissed
    static func present(from host:UIViewController, message: String, signal: Signal<Bool>, completion: () -> Void) {
        // on 0.5 second delay, if not yet live, present loading indicator
        let startSpinner = UpdatableSignal(withInitialValue: true).signal(withDelay: 0.5)
        let canEndSpinner = startSpinner.signal(withDelay: 1.0)
        
        let composite = signal.signal(zippingWith: startSpinner, and: canEndSpinner)
        presenterCompositeSignal = composite
        
        composite.map { triple in
            let isDone = triple.0 ?? false
            let canSpinStart = triple.1 ?? false
            let hasSpunLongEnough = triple.2 ?? false
            
            switch (isDone, canSpinStart, hasSpunLongEnough) {
            case (false, true, false): // start spinner
                let spinnerViewController = MainStoryboard().instantiateViewController(.Spinner) as! SpinnerViewController
                spinnerViewController.modalTransitionStyle = .CrossDissolve
                spinnerViewController.modalPresentationStyle = .FullScreen
                spinnerViewController.message = message
                host.presentViewController(spinnerViewController, animated: true, completion: nil)
            case (true, true, false): // keep spinning, we started and haven't spun long enough yet
                break
            case (true, true, true): // stop spinner
                host.dismissViewControllerAnimated(true, completion: {
                    completion()
                    presenterCompositeSignal = nil
                })
            case (true, false, false): // no need to spin, wait ended quickly
                completion()
                presenterCompositeSignal = nil
            case (false, true, true): // spinning and still waiting, so nothing to do yet
                break
            default:
                fatalError("Unhandled case: \(triple)")
            }
        }
    }
    
    var message = ""
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var label: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        label.text = message
        activityIndicator.startAnimating()
    }
}
