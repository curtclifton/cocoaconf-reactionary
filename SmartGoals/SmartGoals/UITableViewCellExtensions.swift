//
//  UITableViewCellExtensions.swift
//  SmartGoals
//
//  Created by Curt Clifton on 4/30/16.
//  Copyright © 2016 curtclifton.net. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewCellModel {
    var text: String? { get }
    var detailText: String? { get }
    var textPlaceholder: String? { get }
    var detailTextPlaceholder: String? { get }
}

extension TableViewCellModel {
    var textOrPlaceholder: String? {
        if let text = self.text where !text.isEmpty {
            return text
        }
        return textPlaceholder
    }
    
    var detailTextOrPlaceholder: String? {
        if let detailText = self.detailText where !detailText.isEmpty {
            return detailText
        }
        return detailTextPlaceholder
    }
    
    var textColor: UIColor {
        if let text = self.text where !text.isEmpty {
            return labelColor
        }
        return placeholderColor
    }
    
    var detailTextColor: UIColor {
        if let detailText = self.detailText where !detailText.isEmpty {
            return labelColor
        }
        return placeholderColor
    }
    
    var labelColor: UIColor {
        return UIColor.blackColor()
    }
    
    var placeholderColor: UIColor {
        return UIColor.grayColor()
    }
}

extension UITableViewCell {
    func configure(withViewModel viewModel: TableViewCellModel) {
        self.textLabel?.text = viewModel.textOrPlaceholder
        self.textLabel?.textColor = viewModel.textColor
        self.detailTextLabel?.text = viewModel.detailTextOrPlaceholder
        self.detailTextLabel?.textColor = viewModel.detailTextColor
    }
}