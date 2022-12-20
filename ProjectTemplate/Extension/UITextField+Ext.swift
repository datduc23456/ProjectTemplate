//
//  UITextField+Ext.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 04/12/2022.
//

import Foundation
import UIKit

extension UITextField {
    private struct AssociatedKeys {
        static var isPlaceHolder = "isPlaceHolder"
    }
    
    var isPlaceHolder: Bool? {
        get {
            return  objc_getAssociatedObject(self, &AssociatedKeys.isPlaceHolder) as? Bool
        }

        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.isPlaceHolder, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
