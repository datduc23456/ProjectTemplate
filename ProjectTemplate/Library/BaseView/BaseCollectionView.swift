//
//  BaseCollectionView.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 16/11/2022.
//

import UIKit

protocol CollectionViewAdjustedHeightDelegate: AnyObject {
    func didChangeContentSize(_ collectionView: BaseCollectionView, size contentSize: CGSize)
}


protocol FactoryUICollectionView {
    static func createWith<T: UICollectionViewCell>(_ type: T.Type) -> Self
}

extension FactoryUICollectionView where Self: BaseCollectionView {
    static func createWith<T: UICollectionViewCell>(_ type: T.Type) -> Self {
        let collectionView = BaseCollectionView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: UICollectionViewLayout())
        collectionView.registerCell(for: T.className)
        return collectionView as! Self
    }
}

class BaseCollectionBuilder {
    
    private var collectionView: BaseCollectionView!
    private var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    func withCell<T: UICollectionViewCell>(_ type: T.Type) -> BaseCollectionBuilder {
        self.collectionView = BaseCollectionView.createWith(T.self)
        return self
    }
    
    func withItemSize(_ size: CGSize) -> BaseCollectionBuilder {
        flowLayout.itemSize = size
        return self
    }
    
    func withEstimatedItemSize(_ size: CGSize) -> BaseCollectionBuilder {
        if size == UICollectionViewFlowLayout.automaticSize {
            flowLayout = CollectionViewFlowLayout()
            flowLayout.estimatedItemSize = size
        }
        return self
    }
    
    func withSpacingInRow(_ spacing: CGFloat) -> BaseCollectionBuilder {
        flowLayout.minimumInteritemSpacing = spacing
        return self
    }
    
    func withSpacingInGrid(_ spacing: CGFloat) -> BaseCollectionBuilder {
        flowLayout.minimumLineSpacing = spacing
        return self
    }
    
    func withFooterReferenceSize(_ size: CGSize) -> BaseCollectionBuilder {
        flowLayout.footerReferenceSize = size
        return self
    }
    
    func withHeaderReferenceSize(_ size: CGSize) -> BaseCollectionBuilder {
        flowLayout.headerReferenceSize = size
        return self
    }
    
    func withScrollDirection(_ scroll: UICollectionView.ScrollDirection) -> BaseCollectionBuilder {
        flowLayout.scrollDirection = scroll
        return self
    }
    
    func build() -> BaseCollectionView {
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.isScrollEnabled = true
        self.collectionView.collectionViewLayout.invalidateLayout()
        return self.collectionView
    }
}

class BaseCollectionView: UICollectionView {
    
    weak var contentSizeDelegate: CollectionViewAdjustedHeightDelegate?
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    override var contentSize: CGSize {
        didSet {
            contentSizeDelegate?.didChangeContentSize(self, size: contentSize)
            self.invalidateIntrinsicContentSize()
        }
    }
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = APP_COLOR
        self.bounces = true
        self.showsHorizontalScrollIndicator = false
//        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BaseCollectionView: FactoryUICollectionView {}
