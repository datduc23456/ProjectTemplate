//
//  BaseViewController.swift
//  ArrvisCore
//
//  Created by Nguyễn Đạt on 2018/02/05.
//
//

import UIKit
import RxSwift

private var disposeBagKey = 0
private var payloadKey = 1
private var originalContentInsetKey = 0
private var keyboardSubscribersKey = 1
private var isKeyboardVisibleKey = 2

public protocol KeyboardDisplayableViewController where Self: UIViewController {
    var scrollViewForResizeKeyboard: UIScrollView? { get }
    func onKeyboardWillShow(notification: Notification)
    func onKeyboardWillHide(notification: Notification)
}

extension KeyboardDisplayableViewController {

    public var isKeyboardVisible: Bool {
        get {
            return objc_getAssociatedObject(self, &isKeyboardVisibleKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &isKeyboardVisibleKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public var originContentInset: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &originalContentInsetKey) as? UIEdgeInsets ?? nil
        }
        set {
            objc_setAssociatedObject(self, &originalContentInsetKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    private var keyboardSubscribers: [Disposable]? {
        get {
            return objc_getAssociatedObject(self, &keyboardSubscribersKey) as? [Disposable] ?? nil
        }
        set {
            objc_setAssociatedObject(self, &keyboardSubscribersKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public var scrollViewForResizeKeyboard: UIScrollView? {
        return nil
    }

    public func onKeyboardWillShow(notification: Notification) {
        guard let scrollView = scrollViewForResizeKeyboard,
            let originInset = scrollViewForResizeKeyboard?.contentInset,
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        originContentInset = originContentInset ?? originInset
        let insets = UIEdgeInsets(top: originInset.top,
                                  left: originInset.left,
                                  bottom: keyboardFrame.height,
                                  right: originInset.right)
        guard originInset.bottom < keyboardFrame.height, scrollView.adjustedContentInset.bottom < keyboardFrame.height else { return }
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    public func onKeyboardWillHide(notification: Notification) {
        guard let scrollView = scrollViewForResizeKeyboard,
            let originInset = originContentInset else {
                return
        }
        scrollView.contentInset = originInset
        scrollView.scrollIndicatorInsets = originInset
    }

    public func subscribeKeyboardEvents() {
        keyboardSubscribers = [
            NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillShowNotification)
                .subscribe(onNext: { [weak self] notification in
                    guard let weakSelf = self else { return }
                    weakSelf.isKeyboardVisible = true
                    weakSelf.onKeyboardWillShow(notification: notification)
                }
            ),
            NotificationCenter.default.rx
                .notification(UITextInputMode.currentInputModeDidChangeNotification)
                .subscribe(onNext: { [weak self] notification in
                    guard let weakSelf = self else { return }
                    weakSelf.isKeyboardVisible = true
                    weakSelf.onKeyboardWillShow(notification: notification)
                }
            ),
            NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillHideNotification)
                .subscribe(onNext: { [weak self] notification in
                    guard let weakSelf = self else { return }
                    weakSelf.isKeyboardVisible = false
                    weakSelf.onKeyboardWillHide(notification: notification)
                }
            )
        ]
        keyboardSubscribers?.forEach {$0.disposed(by: self)}
    }

    public func unsubscribeKeyboardEvents() {
        keyboardSubscribers?.forEach { sub in sub.dispose() }
    }
}

extension Disposable {

    /// Disposed
    public func disposed(by: UIViewController) {
        self.disposed(by: by.disposeBag)
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
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
