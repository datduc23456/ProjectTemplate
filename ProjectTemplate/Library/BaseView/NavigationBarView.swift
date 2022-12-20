//
//  NavigationBarView.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 18/11/2022.
//

import UIKit

enum NavigationBarType: String {
    case base = "BaseNavigationView"
    
    var height: CGFloat {
        switch self {
        case .base:
            return 44
        }
    }
}

class NavigationBarView: UIView {
    static let BelowNavigationTag = -1
    var type: NavigationBarType = .base
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.layer.shadowPath != nil {
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }
    }
    
    static func initFromNib(type: NavigationBarType, frame: CGRect) -> NavigationBarView {
        let nib = UINib(nibName: type.rawValue, bundle: nil)
        let xibView = nib.instantiate(withOwner: self, options: nil).first as! NavigationBarView
        xibView.frame = frame
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return xibView
    }
    
    static func initUsingAutoLayout(_ type: NavigationBarType, view: UIView) -> NavigationBarView {
        let nav = UINib(nibName: type.rawValue, bundle: .main).instantiate(withOwner: self, options: nil).first as! NavigationBarView
        let height = type.height
        nav.type = type
        view.insertSubview(nav, at: 0)
        nav.translatesAutoresizingMaskIntoConstraints = false
        
        
        var newContraints: [NSLayoutConstraint] = []
        for contraint in view.constraints {
            if let firstItem = contraint.firstItem as? UIView {
                if firstItem.tag == BelowNavigationTag {
                    continue
                }
            }
            if let secondItem = contraint.secondItem as? UIView {
                if secondItem.tag == BelowNavigationTag {
                    continue
                }
            }
            if contraint.firstItem === view, contraint.firstAttribute == .top, contraint.secondItem !== view.safeAreaLayoutGuide {
                newContraints.append(NSLayoutConstraint(item: nav, attribute: .bottom, relatedBy: .equal, toItem: contraint.secondItem, attribute: contraint.secondAttribute, multiplier: contraint.multiplier, constant: contraint.constant))
                contraint.isActive = false
            } else if contraint.secondItem === view, contraint.secondAttribute == .top, contraint.firstItem !== view.safeAreaLayoutGuide {
                newContraints.append(NSLayoutConstraint(item: contraint.firstItem!, attribute: contraint.firstAttribute, relatedBy: .equal, toItem: nav, attribute: .bottom, multiplier: contraint.multiplier, constant: contraint.constant))
                contraint.isActive = false
            }
            else if contraint.firstItem === view.safeAreaLayoutGuide, contraint.firstAttribute == .top, contraint.secondItem !== view  {
                newContraints.append(NSLayoutConstraint(item: nav, attribute: .bottom, relatedBy: .equal, toItem: contraint.secondItem, attribute: contraint.secondAttribute, multiplier: contraint.multiplier, constant: contraint.constant))
                contraint.isActive = false
            } else if contraint.secondItem === view.safeAreaLayoutGuide, contraint.secondAttribute == .top, contraint.firstItem !== view {
                newContraints.append(NSLayoutConstraint(item: contraint.firstItem!, attribute: contraint.firstAttribute, relatedBy: .equal, toItem: nav, attribute: .bottom, multiplier: contraint.multiplier, constant: contraint.constant))
                contraint.isActive = false
            }
        }
        
        NSLayoutConstraint(item: nav, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: nav, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: nav, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: nav, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height + AppDelegate.shared.window!.safeAreaInsets.top).isActive = true
        newContraints.forEach({$0.isActive = true})
        
        return nav
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateNotificationUnread(_ count: Int) {
        //override
    }
    
    func initDefaultBackButton() -> UIButton {
        let backBtn = UIButton()
        backBtn.setImage(#imageLiteral(resourceName: "ic_arrow_back"), for: .normal)
        return backBtn
    }
    
    func drawShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 3
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
