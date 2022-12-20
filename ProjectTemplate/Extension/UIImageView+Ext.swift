//
//  UIImageView+ext.swift
//  ProjectTemplate
//
//  Created by Nguyễn Đạt on 20/12/2022.
//

import UIKit
import Kingfisher

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
    
    func setImageUrlWithPlaceHolder(url: URL?, _ placeHolder: UIImage = UIImage(named: "placeholder")!) {
        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
