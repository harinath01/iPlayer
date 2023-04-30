//
//  UIView.swift
//  iPlayer2
//
//  Created by Testpress on 30/04/23.
//

import Foundation
import UIKit

extension UIView {
    class func fromNib<T: UIView>(_ name: String? = nil) -> T {
        let nibName = name ?? String(describing: T.self)
        return Bundle(for: T.self).loadNibNamed(nibName, owner: nil, options: nil)![0] as! T
    }
}
