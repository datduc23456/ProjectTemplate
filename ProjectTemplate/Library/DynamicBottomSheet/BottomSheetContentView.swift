//
//  BottomSheetContentView.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 25/11/2022.
//

import UIKit

class BottomSheetContentView: BaseCustomView {
    
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    var title: String = "" {
        didSet {
            lbTitle.text = title
        }
    }
    
    var content: String = "" {
        didSet {
            lbContent.text = content
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
