//: Playground - noun: a place where people can play

import UIKit
import SmartGoalsModelTouch

let signal = UpdatableSignal<String>()
signal.map { (str: String) -> Void in
    print("Got string: \(str)")
}

signal.update(toValue: "Dog")
signal.update(toValue: "Cow")
signal.update(toValue: "🐮")

signal.flatmap { (str: String) -> Int? in
    return Int(str)
    }.map {
        print("got int: \($0)")
    }

signal.update(toValue: "1")



