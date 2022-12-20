//
//  BaseNavigator.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 20/10/2022.
//

import UIKit

protocol Navigatable {
    var scheme: String {get}
    var routes: [String] {get}

    func getScreen(path: String) -> Screen
}

protocol BaseNavigatorDelegate: AnyObject {
    func didPushViewController(_ vc: UIViewController, _ fromRoot: Bool, _ animate: Bool)
    func didPresentViewController(_ vc: UIViewController, _ animate: Bool)
    func didReplaceViewController(_ vc: UIViewController)
    func didPopViewController(_ result: Any?, _ animate: Bool)
    func didDismissViewController(_ result: Any?, _ animate: Bool)
}

open class BaseNavigator {
    // MARK: - Variables
    weak var delegate: BaseNavigatorDelegate?
}

extension BaseNavigator {
    
    public func showPlayVideo(_ key: String, _ fromRoot: Bool) {
        let vc = AppScreens.playvideo.createViewController(key)
        vc.modalPresentationStyle = .automatic
        delegate?.didPresentViewController(vc, true)
    }
    
    public func showAlert(_ alert: UIAlertController) {
        delegate?.didPresentViewController(alert, true)
    }
    
    public func pushScreen(_ screen: Screen, _ payload: Any? = nil, animate: Bool = true, fromRoot: Bool) {
        let vc = screen.createViewController(payload)
        delegate?.didPushViewController(vc, fromRoot, animate)
    }
    
    public func popScreen(result: Any? = nil, animate: Bool = true) {
        delegate?.didPopViewController(result, animate)
    }

    public func dismissScreen(result: Any? = nil, animate: Bool = true) {
        delegate?.didDismissViewController(result, animate)
    }
}
