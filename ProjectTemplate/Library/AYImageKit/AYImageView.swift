//
//  TrendingCollectionViewCell.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 17/11/2022.
//

import UIKit

public class AYImageView: UIView {
    
    public enum ImageViewDownloadResult {
        case success(UIImage)
        case error(Error)
    }

    public typealias ImageViewDownloadImageHandler = (ImageViewDownloadResult) -> ()
    
    private var imageView: UIImageView!
    private var initialsLabel: UILabel!
    private var style: Style = Style.default()
    private var activityIndicator: UIActivityIndicatorView?
    
    /** Initials are get from this text by a function: showInitialsName */
    public var text: String?
    
    /** if `true` ImageDownloader class will cache image in Disk. Default is `true`  */
    public var cacheInDisk = true
    
    /** if `true` ImageDownloader class will cache image in Memory. Default is `false`  */
    public var cacheInMemory = false
    
    /** if `true` AYImageView will be in circular shape. Default is `true`  */
    public var isCircular = false
    
    /** if `true` AYImageView will be interactive and can open ImageViewer. Default is `true`  */
    public var isAllowToOpenImage = true
    
    /** if `true` ImageViewerViewController will show a button to share image. Default is `true`  */
    public var isSharingEnabled = true
    
    /** if `true` AYImageViewer will show activity indicator during downloading image. Default is `true`  */
    public var isShowActivityIndicator = true
    
    /** set Image content mode of imageView. Default is `scaleAspectFit` */
    public var imageContentMode: UIImageView.ContentMode = .scaleAspectFit
    
    /** set ViewController from which ImageViewerViewController will Present */
    public var currentViewController: UIViewController?
    
    /** if set will show a placeholderImage when image from URL not found. */
    public var placeHolderImage: UIImage?
    
    /** if `true` ImageDownloader will download image whether image is present in cache or not. Default is  `false` */
    public var isforceRemoteFetchingEnabled: Bool = false
    public var backgroundColorImage: UIColor = .clear
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// will create image view and label for Initials
    private func setup() {
        setupInitialsLabel()
        setupImageView()
    }
    
    private func setupImageView() {
        if imageView == nil {
            imageView = createImageView()
            addSubview(self.imageView)
        }
    }
    
    /// will create Image view
    private func createImageView() -> UIImageView {
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = imageContentMode
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.backgroundColor = backgroundColorImage
        return imageView
    }
    
    /// to show Image in IMageViewerViewController
    @objc func showImageViewer(_ sender: UITapGestureRecognizer) {
        let imageViewerViewController = AYImageViewerViewController(image: self.imageView.image ?? UIImage(), sourceImageView: self.imageView, isSharingEnabled: self.isSharingEnabled)
        guard let vc = currentViewController else { return }
        vc.present(imageViewerViewController, animated: true)
    }
    
    private func configureView() {
        addTapGesture()
        makeImageViewRound()
//        backgroundColor = .clear
    }

    /// make image circular if "IsCircular set true"
    private func makeImageViewRound() {
        if isCircular {
            clipsToBounds = true
            layer.cornerRadius = self.frame.size.height / 2
        }
    }
    
    /// add tapGesture to open Image in full screen. if "isAllowToOpenImage" set true
    private func addTapGesture() {
        isUserInteractionEnabled = isAllowToOpenImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImageViewer(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    /// initialization of activity indicator
    private func displayActivityIndicator() {
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        activityIndicator?.frame = bounds
        
        DispatchQueue.main.async { [weak self] in
            self?.addSubview((self?.activityIndicator)!)
            self?.activityIndicator!.startAnimating()
        }
    }
    
    /// remove activity indicator from superview
    private func removeActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator?.removeFromSuperview()
        }
    }
    
    /** donwload and set image from given url.
        image can be capture in  ImageViewDownlaodImagehandler*/
    public func setImageFromUrl(url: String, completion: ImageViewDownloadImageHandler? = nil) {
        
        self.backgroundColor = .white.withAlphaComponent(0.5)
        self.imageView.image = placeHolderImage
        
        if isShowActivityIndicator {
            displayActivityIndicator()
        }
        
        AYImageDownloader.shared.fetchImage(from: URL(string: url), forceRemoteFetching: isforceRemoteFetchingEnabled, cacheInMemory: cacheInMemory, cacheInDisk: cacheInDisk) { [weak self] response in
            
            guard let strongSelf = self else { return }
            
            switch response {
            case .failure(let error):
                
                strongSelf.removeActivityIndicator()
                self?.backgroundColor = .clear
                completion?(.error(error))
                return
            case .success(let image):
                
                strongSelf.removeActivityIndicator()
                strongSelf.setImage(image)
                completion?(.success(image))
            }
        }
        
        showInitialsName(text)
    }
    
    
    /// set image directly
    public func setImage(_ image: UIImage) {
        self.imageView.contentMode = imageContentMode
        self.imageView.image = image
        self.refresh()
    }
    
    /// refresh view to render style changes
    private func refresh() {
        configureView()
        if initialsLabel != nil {
            initialsLabel.font = style.font
            initialsLabel.textColor = style.textColor
        }
    }
    
    /// update with new style fo
    public func updateStyle(with style: Style) {
        self.style = style
        refresh()
    }
}

// MARK:- Initials Setting Functions

/// functions related to Initials
extension AYImageView {
    
    /// get initials form text given by user
    private func nameInitials(text: String) -> String? {
        let formatter = PersonNameComponentsFormatter()
        guard let components = formatter.personNameComponents(from: text) else { return ""}
        formatter.style = .abbreviated
        return formatter.string(from: components)
    }
    
    private func setupInitialsLabel() {
        if initialsLabel == nil {
            initialsLabel = self.createInitialsLabel()
            addSubview(self.initialsLabel)
        }
    }
    
    /// create label to set initials
    private func createInitialsLabel() -> UILabel {
        let label = UILabel(frame: self.bounds)
        label.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 18.0 / label.font.pointSize
        label.isAccessibilityElement = false
        label.text = self.text
        return label
    }
    
    /** set initials if image is not present */
    public func showInitialsName(_ text: String?) {
        if let initials = text, !initials.isEmpty {
            initialsLabel.isHidden = false
            initialsLabel.text = nameInitials(text: initials)
        } else {
            initialsLabel.isHidden = true
            initialsLabel.text = ""
        }
    }
}


