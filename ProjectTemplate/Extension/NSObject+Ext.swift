//
//  NSObject+Ext.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 16/11/2022.
//

import Foundation

public extension NSObject {
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }

    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}
