//
//  PresenterInterface.swift
//  ArrvisCore
//
//  Created by dat.nguyenquoc on 2018/02/08.
//
//

public protocol PresenterInterface: AnyObject {
    func viewDidLoad()
    func viewWillAppear(_ animated: Bool)
    func viewDidAppear(_ animated: Bool)
    func viewWillDisappear(_ animated: Bool)
    func viewDidDisappear(_ animated: Bool)
    func setBackResultIfCan(_ result: Any?)
}

extension PresenterInterface {
    public func setBackResultIfCan(_ result: Any?) {
        
    }
    
    public func viewDidLoad() {
        fatalError("Not implemented")
    }

    public func viewWillAppear(_ animated: Bool) {
        fatalError("Not implemented")
    }

    public func viewDidAppear(_ animated: Bool) {
        fatalError("Not implemented")
    }

    public func viewWillDisappear(_ animated: Bool) {
        fatalError("Not implemented")
    }

    public func viewDidDisappear(_ animated: Bool) {
        fatalError("Not implemented")
    }
}
