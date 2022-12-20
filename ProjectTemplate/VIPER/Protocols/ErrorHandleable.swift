//
//  ErrorHandleable.swift
//  ArrvisCore
//
//  Created by dat.nguyenquoc on 2018/02/08.
//
//

import Foundation

public protocol ErrorHandleable {
    func handleError(_ error: Error, _ completion: (() -> Void)?)
}
