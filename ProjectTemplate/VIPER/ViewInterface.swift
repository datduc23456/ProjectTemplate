//
//  ViewInterface.swift
//  ArrvisCore
//
//  Created by dat.nguyenquoc on 2018/02/08.
//
//

public protocol ViewInterface: AnyObject, Progressable {
    func handleError(_ error: Error)
}

extension ViewInterface {
    func handleError(_ error: Error) {
        
    }
}
