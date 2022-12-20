//
//  BaseCustomView.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 22/11/2022.
//

import UIKit

class BaseCustomView: UIView {
    
    var nibNameView: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initWithNib()
    }
    
    func initWithNib() {
        guard let view = UINib(nibName: nibNameView ?? self.className(), bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        self.backgroundColor = .clear
        commonSetup()
    }
    
    func commonSetup() {
        
    }
    
    func className() -> String {
        if let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last {
            return name
        } else {
            return ""
        }
    }
}

