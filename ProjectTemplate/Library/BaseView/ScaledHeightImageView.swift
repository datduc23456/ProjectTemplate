//
//  ScaledHeightImageView.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 26/11/2022.
//

import UIKit

class ScaledHeightImageView: UIImageView {

    override var intrinsicContentSize: CGSize {

        if let myImage = self.image {
            let myImageWidth = myImage.size.width / 2
            let myImageHeight = myImage.size.height / 2
            let myViewHeight = self.frame.size.height
 
            let ratio = myViewHeight/myImageWidth
            let scaledWidth = myImageWidth * ratio

            return CGSize(width: myImageWidth, height: myImageHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }

}
