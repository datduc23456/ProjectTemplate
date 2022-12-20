//
//  BaseTableViewCell.swift
//  ProjectDemo
//
//  Created by MacBook Pro on 16/11/2022.
//

import UIKit

struct FlowLayoutAttribute {
    var estimatedItemSize: CGSize
    var minimumInteritemSpacing: CGFloat
    var minimumLineSpacing: CGFloat
    var footerReferenceSize: CGSize
    var headerReferenceSize: CGSize
    var scrollDirection: UICollectionView.ScrollDirection
}

protocol BaseWithCollectionTableViewCellHandler: AnyObject {
    var listPayload: [Any] { get set }
    var didTapActionInCell: ((Any)->Void) { get set }
    var collectionView: BaseCollectionView! { get set }
}

class BaseTableCollectionViewCell<T: UICollectionViewCell>: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BaseWithCollectionTableViewCellHandler {

    var didTapActionInCell: ((Any) -> Void) = {_ in}
    var collectionView: BaseCollectionView!
    var listPayload: [Any] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var flowLayout: FlowLayoutAttribute? {
        return nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        initWithCollectionView()
        print("Register: \(T.self)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initWithCollectionView() {
        guard let flowLayout = flowLayout else { return }
        collectionView = BaseCollectionBuilder().withCell(T.self)
            .withEstimatedItemSize(flowLayout.estimatedItemSize)
            .withFooterReferenceSize(flowLayout.footerReferenceSize)
            .withHeaderReferenceSize(flowLayout.headerReferenceSize)
            .withSpacingInGrid(flowLayout.minimumLineSpacing)
            .withSpacingInRow(flowLayout.minimumInteritemSpacing)
            .withScrollDirection(flowLayout.scrollDirection)
            .build()
        contentView.addSubview(collectionView)
        collectionView.fillToSuperView()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPayload.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as! T
        let payload = self.listPayload[indexPath.row]
        if let baseCell = cell as? BaseCollectionViewCell {
            baseCell.tag = indexPath.row
            baseCell.configCell(payload)
            baseCell.didTapAction = { [weak self] any in
                guard let `self` = self else { return }
                self.didTapActionInCell(any)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = flowLayout else {
            return UICollectionViewFlowLayout.automaticSize
        }
        if flowLayout.estimatedItemSize == UICollectionViewFlowLayout.automaticSize {
            return CGSize(width: 1, height: 34)
        }
        return flowLayout.estimatedItemSize
    }
}
