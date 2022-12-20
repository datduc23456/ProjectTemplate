//
//  InteractorInterface.swift
//  ArrvisCore
//
//  Created by dat.nguyenquoc on 2018/02/08.
// 
//

import Foundation
import RxSwift

private var disposeBagKey = 0

public protocol InteractorInterface: AnyObject {
}

extension InteractorInterface {

    fileprivate var disposeBag: DisposeBag {
        get {
            guard let object = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag else {
                self.disposeBag = DisposeBag()
                return self.disposeBag
            }
            return object
        }
        set {
            objc_setAssociatedObject(self, &disposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

extension Disposable {

    /// Disposed
    public func disposed(by: InteractorInterface) {
        self.disposed(by: by.disposeBag)
    }
}
