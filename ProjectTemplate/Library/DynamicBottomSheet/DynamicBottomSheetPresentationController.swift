//
//  DynamicBottomSheetPresentationController.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 22/11/2022.
//

import UIKit

class DynamicBottomSheetPresentationController: UIPresentationController {
    
    /// Background View
    public var backgroundView = UIView()
    
    // MARK: - Init
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        configureBackgroundView()
    }
    
    /// Configure the background view
    private func configureBackgroundView() {
        backgroundView.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        backgroundView.alpha = 0
    }
    
    open override func presentationTransitionWillBegin() {
        containerView?.insertSubview(backgroundView, at: 0)
    }
    
    open override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0
        }, completion: nil)
    }
    
}
