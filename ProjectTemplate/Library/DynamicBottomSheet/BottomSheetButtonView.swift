//
//  BottomSheetButtonView.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 25/11/2022.
//

import UIKit

class BottomSheetButtonView: BaseCustomView {
    
    @IBOutlet weak var button: UIButton!
    
    var title: String = "" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    var isPrimary: Bool = true {
        didSet {
            if isPrimary {
                button.borderWidth = 0
                button.backgroundColor = CHOOSE_GENRE_COLOR
                button.setTitleColor(.black, for: .normal)
            } else {
                button.borderWidth = 1
                button.backgroundColor = UIColor(hex: "#35333A")
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
