//
//  ImageStackView.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 22/11/2022.
//

import UIKit
import SnapKit
import Kingfisher

class ImageStackView: UIStackView {
    
    @IBInspectable var count: Int = 1
    var didTapImage: ((Int) -> Void)?
    var didAdditionImage: VoidCallBack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func selected(_ containerView: UIView) {
        containerView.borderWidth = 1
        containerView.borderColor = CHOOSE_GENRE_COLOR
    }
    
    func unselected(_ containerView: UIView) {
        containerView.borderWidth = 0
    }
    
    func configView(_ imageUrl: [URL] = [], selectedIndex: Int = 0, isAdditionImage: Bool = false) {
        self.layoutIfNeeded()
        for subViews in self.subviews {
            subViews.removeFromSuperview()
        }
        let spacingCount: CGFloat = CGFloat(count - 1) * spacing
        let width: CGFloat = (self.frame.width - spacingCount) / CGFloat(count)
        let indexAddition: Int = isAdditionImage && (imageUrl.count < count) ? imageUrl.count : -1
        for index in 0..<count {
            let containerView = UIView()
            let imageView = UIImageView(frame: containerView.bounds)
            containerView.backgroundColor = .clear
            containerView.addSubview(imageView)
            imageView.contentMode = .scaleAspectFill
            imageView.fillToSuperView()
            containerView.cornerRadius = 8
            containerView.snp.makeConstraints {
                $0.width.equalTo(width)
            }
            containerView.addTapGestureRecognizer(action: { [weak self] in
                guard let `self` = self else { return }
                if let _ = imageUrl[safe: index] {
                    for view in self.arrangedSubviews {
                        self.unselected(view)
                    }
                    self.selected(containerView)
                    self.didTapImage?(index)
                }
            })
            if let url = imageUrl[safe: index] {
                imageView.setImageUrlWithPlaceHolder(url: url)
            }
            
            if index == selectedIndex {
                self.selected(containerView)
            }
            if index == indexAddition {
                imageView.image = UIImage(named: "Group 2196")
                imageView.contentMode = .scaleToFill
                containerView.addTapGestureRecognizer {
                    self.didAdditionImage?()
                }
            }
            self.addArrangedSubview(containerView)
        }
    }
}
