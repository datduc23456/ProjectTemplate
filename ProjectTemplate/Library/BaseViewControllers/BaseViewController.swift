//
//  BaseViewController.swift
//  ArrvisCore
//
//  Created by Nguyễn Đạt on 2018/02/05.
//
//

import UIKit
import Moya
import RxCocoa
import RxSwift

open class BaseViewController: UIViewController {
    
    var realmUtils: RealmUtils! {
        get {
            AppDelegate.shared.realmUtils
        }
    }
    public var currentRootViewController: UIViewController?
    public private(set) var navigator: BaseNavigator!
    var myNavigationBar: NavigationBarView?
    var isFirstLayout: Bool = true
    var viewGradientBottom: UIView!
    var gradient: CAGradientLayer!
    var internetSubscribers: [Disposable] = []
    var alert: UIAlertController!
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        initializePopGesture()
//        handleDidFirstLayoutSubviews()
//        handleViewWillLayoutSubviews {}
        self.view.backgroundColor = APP_COLOR
        viewGradientBottom = UIView()
        gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 1]
        viewGradientBottom.backgroundColor = APP_COLOR
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        internetSubscribers = [
        NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: "InternetConnected"))
            .subscribe(onNext: { [weak self] notification in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async {
                    weakSelf.onConnection(notification: notification)
                }
                
            }),
        NotificationCenter.default.rx
            .notification(NSNotification.Name(rawValue: "InternetLost"))
            .subscribe(onNext: { [weak self] notification in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async {
                    weakSelf.onLostConnection(notification: notification)
                }

            })
        ]
        internetSubscribers.forEach {$0.disposed(by: self)}
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        internetSubscribers.forEach { sub in sub.dispose() }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLayout {
            viewGradientBottom.fadeView(style: .top, percentage: 0.45)
        }
    }
    
    private var currentRootNavigationController: UINavigationController? {
        if let current = currentRootViewController as? UINavigationController {
            return current
        } else if let current = currentRootViewController as? UITabBarController,
            let selected = current.selectedViewController as? UINavigationController {
            return selected
        }
        return nil
    }
    
    public convenience init(navigator: BaseNavigator) {
        self.init(nibName: nil, bundle: nil)
        self.navigator = navigator
        self.navigator.delegate = self
    }
    
    func initCustomNavigation<T:NavigationBarView>(_ type: NavigationBarType) -> T {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let nav = NavigationBarView.initUsingAutoLayout(type, view: view) as! T
        myNavigationBar = nav
        return nav
    }
}

extension BaseViewController {

    private func setBackResultIfCan(vc: UIViewController, result: Any?) {
        guard let backFromNextHandleable = vc as? BackFromNextHandleable else {
            return
        }
        backFromNextHandleable.onBackFromNext(result)
    }
}

extension BaseViewController {
    
    /// Push
    public func pushChildViewController(_ vc: UIViewController, _ fromRoot: Bool, _ animate: Bool) {
        if fromRoot {
            if let navigationController = AppDelegate.shared.appRootViewController.navigationController {
                for viewController in navigationController.viewControllers {
                    if viewController.className == vc.className {
                        navigationController.pushViewController(vc, animated: animate)
                        navigationController.viewControllers = [navigationController.viewControllers.first!, vc]
                        return
                    }
                }
                navigationController.pushViewController(vc, animated: animate)
            }
        } else {
            currentNavigationController(from: nil)?.pushViewController(vc, animated: animate)
        }
    }
    
    /// Pop
    public func popChildViewController(_ result: Any?, _ animate: Bool) {
        let rootViewController = AppDelegate.shared.appRootViewController
        rootViewController.navigationController?.popViewController(animated: animate)

        func completed() {
            if let current = currentViewController() {
                setBackResultIfCan(vc: current, result: result)
            }
        }

        if let coordinator = currentViewController()?.navigationController?.transitionCoordinator, animate {
            coordinator.animate(alongsideTransition: nil) { _ in
                completed()
            }
        } else {
            completed()
        }
    }
    
    /// Present
    public func presentChildViewController(_ vc: UIViewController, _ animate: Bool) {
        currentViewController()?.present(vc, animated: animate)
    }

    /// Dismiss
    public func dismisssChildViewController(_ result: Any?, _ animate: Bool, _ completion: (() -> Void)? = nil) {
        currentViewController()?.dismiss(animated: animate, completion: { [weak self] in
            guard let weakSelf = self else { return }
            if let current = weakSelf.currentViewController() {
                weakSelf.setBackResultIfCan(vc: current, result: result)
            }
            completion?()
        })
    }
}

extension BaseViewController {

    public func currentViewController(from: UIViewController? = nil) -> UIViewController? {
        if let from = from {
            if let presented = from.presentedViewController {
                return currentViewController(from: presented)
            }
            if let nav = from as? UINavigationController {
                if let last = nav.children.last {
                    return currentViewController(from: last)
                }
                return nav
            }
            if let tab = from as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return currentViewController(from: selected)
                }
                return tab
            }
            return from
        } else if let presented = presentedViewController {
            return currentViewController(from: presented)
        } else {
            let rootViewController = AppDelegate.shared.navigationRootViewController
            return currentViewController(from: rootViewController)
        }
    }
    
    func currentNavigationController(from: UIViewController?) -> UINavigationController? {
        if let from = from {
            if let nav = from as? UINavigationController {
                return nav
            }
            if let navigationController = from.navigationController {
                return navigationController
            }
            if let parent = from.parent {
                return currentNavigationController(from: parent)
            }
            return nil
        } else {
            return currentNavigationController(from: currentViewController(from: from)!)
        }
    }
}

extension BaseViewController: BaseNavigatorDelegate {
    func didPushViewController(_ vc: UIViewController, _ fromRoot: Bool, _ animate: Bool) {
        self.pushChildViewController(vc, fromRoot, animate)
    }

    func didPresentViewController(_ vc: UIViewController, _ animate: Bool) {
        self.present(vc, animated: true)
    }

    func didReplaceViewController(_ vc: UIViewController) {
        
    }

    func didPopViewController(_ result: Any?, _ animate: Bool) {
        self.popChildViewController(result, animate)
    }

    func didDismissViewController(_ result: Any?, _ animate: Bool) {
        
    }
}

extension UIView {
    
    enum UIViewFadeStyle {
        case bottom
        case top
        case left
        case right
        case vertical
        case horizontal
    }
    
    func fadeView(style: UIViewFadeStyle = .bottom, percentage: Double = 0.4) {
//        percentage càng bé line đậm càng to
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        
        let startLocation = percentage
        let endLocation = 1 - percentage
        
        switch style {
        case .bottom:
            gradient.startPoint = CGPoint(x: 0.5, y: endLocation)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .top:
            gradient.startPoint = CGPoint(x: 0.5, y: startLocation)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, startLocation, endLocation, 1.0] as [NSNumber]
            
        case .left:
            gradient.startPoint = CGPoint(x: startLocation, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .right:
            gradient.startPoint = CGPoint(x: endLocation, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
            gradient.locations = [0.0, startLocation, endLocation, 1.0] as [NSNumber]
        }
        
        layer.mask = gradient
    }

}

extension BaseViewController: InternetHandlerViewController {
    public func onLostConnection(notification: Notification) {
        alert =  UIAlertController(title: "Can't connect to the internet", message: "Connect to the internet\nin order to access", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to setting", style: .default, handler: { (action: UIAlertAction) -> Void in
//            self.dismiss(animated: true, completion: nil)
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingUrl) {
                UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
            } else {
                print("cant open settings")
            }
        }))
        self.didPresentViewController(alert, true)
    }
    
    public func onConnection(notification: Notification) {
        if alert != nil {
            alert.dismiss(animated: true)
        }
    }
}

public protocol InternetHandlerViewController where Self: UIViewController {
    func onConnection(notification: Notification)
    func onLostConnection(notification: Notification)
}
