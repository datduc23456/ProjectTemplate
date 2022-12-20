//
//  BaseCollectionViewController.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 25/11/2022.
//

import UIKit
import KafkaRefresh
import SnapKit

class BaseCollectionViewController<T: UICollectionViewCell>: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var adView: SmallNativeAdView!
    var collectionViewHeightConstraint: Constraint!
    var containerView: UIView!
    var scrollView: UIScrollView!
    var collectionView: BaseCollectionView!
    var page: Int = 1
    var headerRefresh: VoidCallBack?
    var footerRefresh: VoidCallBack?
    
    var numberOfColumn: Int {
        return 3
    }
    
    var spacing: Double {
        return 12
    }
    
    var heightForItem: Double {
        return 50
    }
    
    var insets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if numberOfColumn == 0 {
            self.collectionView = BaseCollectionBuilder().withCell(T.self)
                .withScrollDirection(.vertical)
                .withEstimatedItemSize(UICollectionViewFlowLayout.automaticSize)
                .withSpacingInRow(spacing)
                .withSpacingInGrid(spacing)
                .build()
        } else {
            self.collectionView = BaseCollectionBuilder().withCell(T.self)
                .withScrollDirection(.vertical)
                .withSpacingInRow(spacing)
                .withSpacingInGrid(spacing)
                .build()
        }
        self.adView = SmallNativeAdView(frame: .zero)
        self.scrollView = UIScrollView(frame: .zero)
        self.containerView = UIView(frame: .zero)
        
        self.scrollView.addSubview(containerView)
        self.containerView.addSubview(collectionView)
        self.containerView.addSubview(adView)
        self.view.addSubview(scrollView)
        self.scrollView.fillToSuperView()
        self.containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(self.insets.left)
            $0.trailing.equalToSuperview().offset(-self.insets.right)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(self.view.snp.width).offset(-32)
            $0.height.equalTo(1000).priority(.low)
        }
        self.adView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.adView.snp.bottom).offset(self.spacing)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1000)
        }
        self.collectionView.register(ofType: SmallNativeAdCollectionViewCell.self)
        self.collectionView.registerCell(for: T.className)
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.isScrollEnabled = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentSizeDelegate = self
        
        self.scrollView.bindHeadRefreshHandler({ [weak self] in
            guard let `self` = self else { return }
            self.page = 1
            self.headerRefresh?()
        }, themeColor: .white, refreshStyle: .replicatorCircle)
        
        self.scrollView.bindFootRefreshHandler({ [weak self] in
            guard let `self` = self else { return }
            self.page += 1
            self.footerRefresh?()
        }, themeColor: .white, refreshStyle: .replicatorCircle)
        
        self.scrollView.headRefreshControl.layoutIfNeeded()
        self.scrollView.headRefreshControl.presetContentInsets = UIEdgeInsets(top: spacing, left: spacing, bottom: 0, right: spacing)
        self.adView.register(id: "ca-app-pub-3940256099942544/3986624511")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as! T
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if numberOfColumn == 0 {
            return CGSize(width: 1, height: 1)
        }
        let spacing = self.spacing * Double(numberOfColumn - 1) + self.insets.left + self.insets.right
        let widthForItem = (CommonUtil.SCREEN_WIDTH - spacing) / Double(numberOfColumn)
        return CGSize.init(width: widthForItem, height: heightForItem)
    }
}

extension BaseCollectionViewController: CollectionViewAdjustedHeightDelegate {
    func didChangeContentSize(_ collectionView: BaseCollectionView, size contentSize: CGSize) {
        self.collectionView.snp.updateConstraints {
            $0.height.equalTo(contentSize.height)
        }
        delay(0.1, closure: {
            self.view.layoutIfNeeded()
        })

    }
}
