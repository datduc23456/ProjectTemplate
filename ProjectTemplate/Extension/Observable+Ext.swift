//
//  Observable+Ext.swift
//  MVVMRx
//
//  Created by Nguyễn Đạt on 8/8/20.
//  Copyright © 2020 storm. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol OptionalType {
    associatedtype Wrapped
    
    var value: Wrapped? { get }
}

extension Optional: OptionalType{
    var value: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalType {
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }

    func filterNilKeepOptional() -> Observable<Element> {
        return self.filter { (element) -> Bool in
            return element.value != nil
        }
    }

    func replaceNil(with nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}

extension ObservableType {

    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            assertionFailure("Error \(error)")
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    func asDriverComplete() -> SharedSequence<DriverSharingStrategy, Element> {
        return asDriver(onErrorRecover: { (error)  in
            return Driver.empty()
        })
    }
    
    func unwrap<T>() -> Observable<T> where Element == T? {
        return compactMap { $0 }
    }
    
    func merge(with other: Observable<Element>) -> Observable<Element> {
        return Observable.merge(self.asObservable(), other)
    }
    
    func map<T>(to value: T) -> Observable<T> {
        return map { _ in value }
    }
}

extension Reactive where Base: UIView {
    var willMoveToWindow: Observable<Bool> {
        return self.sentMessage(#selector(Base.willMove(toWindow:)))
            .map({ $0.filter({ !($0 is NSNull) }) })
            .map({ $0.isEmpty == false })
    }
    var viewWillAppear: Observable<Void> {
        return self.willMoveToWindow
            .filter({ $0 })
            .map({ _ in Void() })
    }
    var viewWillDisappear: Observable<Void> {
        return self.willMoveToWindow
            .filter({ !$0 })
            .map({ _ in Void() })
    }
}
