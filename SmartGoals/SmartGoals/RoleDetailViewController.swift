//
//  RoleDetailViewController.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Reactionary
import SmartGoalsModelTouch
import UIKit

class RoleDetailViewController: UIViewController {

    private var signal: Signal<Role>? {
        didSet {
            signalIsConnected = false // new signal, so force reconnect
            connectSignalIfNeeded()
        }
    }
    private var updater: ((Role) -> Void)?
    
    private var role: Role? {
        didSet {
            if let role = role where role != oldValue {
                updater?(role)
            }
        }
    }
    
    @IBOutlet var name: UITextField!
    @IBOutlet var explanation: UITextView! {
        didSet {
            explanation.layer.cornerRadius = 5.0
            explanation.layer.borderWidth = 0.5
            explanation.layer.borderColor = UIColor.grayColor().CGColor
        }
    }
    @IBOutlet var isActive: UISwitch!
    
    override func viewDidLoad() {
        connectSignalIfNeeded()
    }
    
    // MARK: - Public API
    
    func configure(withSignal signal:Signal<Role>, updater: (Role) -> Void) {
        self.signal = signal
        self.updater = updater
    }
    
    // MARK: - Private PAI
    
    private var signalIsConnected = false
    func connectSignalIfNeeded() {
        guard !signalIsConnected else { return /* done */ }
        guard isViewLoaded(), let signal = self.signal else {
            // nothing to do yet
            return
        }

        // Update local copy of role whenever it changes
        signal.map { [weak self] role in self?.role = role }
        
        // Make fields update whenever the pertinent properties change
        let shortNameSignal = signal
            .map({
                $0.shortName
            })
        name.takeValue(fromSignal: shortNameSignal)
        
        let explanationSignal = signal
            .map({
                $0.explanation
            })
        explanation.takeValue(fromSignal: explanationSignal)
        
        let isActiveSignal = signal
            .map({
                $0.isActive
            })
        isActive.takeValue(fromSignal: isActiveSignal)
        
        // Update our local copy of role whenever the user types
        name.valueChangedSignal()
            .flatmap({ $0 })
            .map({ [weak self] shortName in
                self?.role?.shortName = shortName
                })
        
        explanation.valueChangedSignal()
            .map({ [weak self] explanation in
                self?.role?.explanation = explanation
                })
        
        isActive.valueChangedSignal()
            .map({ [weak self] isActive in
                self?.role?.isActive = isActive
                })

        signalIsConnected = true
    }
}
