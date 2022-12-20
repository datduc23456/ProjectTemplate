//
//  BottomSheetLabelView.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 25/11/2022.
//

import UIKit

class BottomSheetLabelView: BaseCustomView {
    
    @IBOutlet weak var icTick: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    var isChoose: Bool = false {
        didSet {
            if isChoose {
                lbTitle.textColor = CHOOSE_GENRE_COLOR
                icTick.isHidden = false
            } else {
                lbTitle.textColor = .white
                icTick.isHidden = true
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
