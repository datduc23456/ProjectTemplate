//
//  BottomSheetStackView.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 22/11/2022.
//

import UIKit
import SnapKit

protocol BoottomSheetStackViewDelegate: AnyObject {
    func didSelect(_ bottomSheetStackView: BottomSheetStackView, selectedIndex index: Int)
}

enum BottomSheetType {
    case draggable
    case label(title: String, isChoose: Bool)
    case button(title: String, isPrimary: Bool)
    case content(title: String, content: String)
    
    func height() -> CGFloat {
        switch self {
        case .draggable:
            return 14
        case .label:
            return 65
        case .button:
            return 44
        case .content:
            return 92
        }
    }
}

class BottomSheetStackView: BaseCustomView {

    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: BoottomSheetStackViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.stackView.spacing = 8
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func config(_ dataSource: [BottomSheetType]) {
        for index in 0..<dataSource.count {
            let type = dataSource[index]
            switch type {
            case .label(let title, let isChoose):
                let view = BottomSheetLabelView()
                view.lbTitle.text = title
                view.isChoose = isChoose
                self.stackView.addArrangedSubview(view)
                view.snp.makeConstraints {
                    $0.height.equalTo(type.height())
                }
                view.addTapGestureRecognizer { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.didSelect(self, selectedIndex: index)
                }
            case .button(let title, let isPrimary):
                let view = BottomSheetButtonView()
                view.title = title
                view.isPrimary = isPrimary
                self.stackView.addArrangedSubview(view)
                view.snp.makeConstraints {
                    $0.height.equalTo(type.height())
                }
                view.button.addTapGestureRecognizer { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.didSelect(self, selectedIndex: index)
                }
            case .content(let title, let content):
                let view = BottomSheetContentView()
                view.title = title
                view.content = content
                self.stackView.addArrangedSubview(view)
                view.snp.makeConstraints {
                    $0.height.equalTo(type.height())
                }
                view.addTapGestureRecognizer { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.didSelect(self, selectedIndex: index)
                }
            case .draggable:
                let view = BottomSheetDraggableView()
                self.stackView.addArrangedSubview(view)
                view.snp.makeConstraints {
                    $0.height.equalTo(type.height())
                }
                view.addTapGestureRecognizer { [weak self] in
                    guard let `self` = self else { return }
                    self.delegate?.didSelect(self, selectedIndex: index)
                }
            }
        }
        
        //Last View for bottom
        self.stackView.addArrangedSubview(UIView())
    }
}
