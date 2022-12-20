//
//  UIView+Ext.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 16/11/2022.
//

import Foundation
import UIKit

var gradientLayerKey = "gradientLayer"
var overlayViewKey = "overlayView"
var isLoadingAnimation = "isLoadingAnimation"

extension UIView {
    
    private struct AssociatedKeys {
        static var isLoadingAnimation = "isLoadingAnimation"
    }
    
    var isLoadingAnimation: Bool? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isLoadingAnimation) as? Bool
        }
        
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.isLoadingAnimation, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setHeightConstraint(_ constant: CGFloat) {
        var isUpdated = false
        self.constraints.forEach({
            if $0.firstItem === self, $0.firstAttribute == .height {
                $0.constant = constant
                isUpdated = true
            }
        })
        if !isUpdated {
            self.heightAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }
    
    func setWidthConstraint(_ constant: CGFloat) {
        var isUpdated = false
        self.constraints.forEach({
            if $0.firstItem === self, $0.firstAttribute == .width {
                $0.constant = constant
                isUpdated = true
            }
        })
        if !isUpdated {
            self.widthAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }
    
    /// Create image snapshot of view.
    func snapshot(of rect: CGRect? = nil) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    //    func setHidden(hidden: Bool) {
    ////        isHidden = hidden
    ////        isUserInteractionEnabled = !hidden
    //    }
    
    func getTopMostViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if topController.isKind(of: UINavigationController.self) {
                if let firstVC = topController.children.first {
                    topController = firstVC
                }
            }
            
            return topController
        }
        return nil
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addBlurArea(area: CGRect, style: UIBlurEffect.Style) {
        let effect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: effect)
        let container = UIView(frame: area)
        blurView.frame = CGRect(x: 0, y: 0, width: area.width, height: area.height)
        container.addSubview(blurView)
        container.alpha = 0.9
        self.insertSubview(container, at: 1)
    }
    
    enum ShadowType {
        case up, down, right, left
    }
    
    func drawShadow(color: UIColor = UIColor(hex: "#E8E8E8"), shadowRadius: CGFloat = 2, cornerRadius: CGFloat = 6, types: [ShadowType]  = [.down]) {
        guard let superview = self.superview else { return }
        let shadowView = UIView()
        self.layer.cornerRadius = cornerRadius
        shadowView.layer.cornerRadius = cornerRadius
        shadowView.backgroundColor = color
        
        superview.insertSubview(shadowView, belowSubview: self)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = self.leftAnchor.constraint(equalTo: shadowView.leftAnchor, constant: 0)
        let rightConstraint = shadowView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        let topConstraint = self.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0)
        let bottomConstraint = shadowView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        leftConstraint.isActive = true
        rightConstraint.isActive = true
        topConstraint.isActive = true
        bottomConstraint.isActive = true
        shadowView.layoutIfNeeded()
        if types.contains(.up) {
            topConstraint.constant = shadowRadius
        }
        if types.contains(.down) {
            bottomConstraint.constant = shadowRadius
        }
        if types.contains(.right) {
            rightConstraint.constant = shadowRadius
        }
        if types.contains(.left) {
            leftConstraint.constant = shadowRadius
        }
    }
    
    func startAnimationLoading() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.backgroundGray().cgColor,
            UIColor.lightGray().cgColor,
            UIColor.darkGray().cgColor,
            UIColor.lightGray().cgColor,
            UIColor.backgroundGray().cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: -0.85, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1.15, y: 0)
        gradientLayer.locations = [-0.85, -0.85, 0, 0.15, 1.15]
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = gradientLayer.locations
        animation.toValue = [0, 1, 1, 1.05, 1.15]
        animation.repeatCount = .infinity
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.duration = 1
        gradientLayer.add(animation, forKey: "layer.animation")
        layer.addSublayer(gradientLayer)
        addOverlayView()
        objc_setAssociatedObject(self, &gradientLayerKey, gradientLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func addOverlayView() {
        let overlayView = OverlayView()
        overlayView.frame = frame
        overlayView.backgroundColor = .clear
        addSubview(overlayView)
        objc_setAssociatedObject(self, &overlayViewKey, overlayView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func stopAnimationLoading() {
        let overlayView = objc_getAssociatedObject(self, &overlayViewKey) as? OverlayView
        let gradientLayer = objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer
        overlayView?.removeFromSuperview()
        gradientLayer?.removeFromSuperlayer()
    }
    
    func allSubViewsOf() -> [UIView] {
        var all = [UIView]()
        func getSubview(view: UIView) {
            all.append(view)
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
    
    func shakeWith(duration: Double, angle: CGFloat, yOffset: CGFloat) {
        let numberOfFrames: Double = 7
        let frameDuration = Double(1/numberOfFrames)
        self.layer.anchorPoint = CGPoint(x: 0.5, y: yOffset)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [],
                                animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*2,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*3,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*4,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform(rotationAngle: +angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*5,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform(rotationAngle: -angle)
            }
            UIView.addKeyframe(withRelativeStartTime: frameDuration*6,
                               relativeDuration: frameDuration) {
                self.transform = CGAffineTransform.identity
            }
        },
                                completion: nil
        )
    }
}

extension UIView: FactoryUIView {}

extension UIView {
    //    @IBInspectable public var borderColor: UIColor? {
    //        get {
    //            guard let color = layer.borderColor else { return nil }
    //            return UIColor(cgColor: color)
    //        }
    //        set {
    //            guard let color = newValue else {
    //                layer.borderColor = nil
    //                return
    //            }
    //            layer.borderColor = color.cgColor
    //        }
    //    }
    
    /// : Border width of view; also inspectable from Storyboard.
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /// Corner radius of view; also inspectable from Storyboard.
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
            layer.masksToBounds = true
        }
    }
    /// : Shadow color of view; also inspectable from Storyboard.
    @IBInspectable public var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    /// : Shadow offset of view; also inspectable from Storyboard.
    @IBInspectable public var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// : Shadow opacity of view; also inspectable from Storyboard.
    @IBInspectable public var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// : Shadow radius of view; also inspectable from Storyboard.
    @IBInspectable public var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    func fillToSuperView(){
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
    var screen : CGRect {
        get {
            return UIScreen.main.bounds
        }
    }
    
    // src : https://medium.com/@sdrzn/adding-gesture-recognizers-with-closures-instead-of-selectors-9fb3e09a8f0b
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public func removeAllTapGestureRecognizer() {
        for gestureRecognizer in (self.gestureRecognizers ?? []) {
            self.removeGestureRecognizer(gestureRecognizer)
        }
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0,
                    cornerRadius: CGFloat = 0.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let frame = CGRect.init(x: 0, y: 0, width: self.frame.width + 5, height: self.frame.height)
            let border = UIView(frame: frame)
            border.backgroundColor = color
            border.layer.cornerRadius = cornerRadius
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
}

extension UIView {
    
    func round(radius: CGFloat, boderColor: UIColor = .clear) {
        layer.cornerRadius = radius
        layer.borderColor = boderColor.cgColor
        clipsToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor? = nil, borderWidth: CGFloat? = nil) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        if let borderColor = borderColor, let borderWidth = borderWidth {
            let borderLayer = CAShapeLayer()
            borderLayer.path = mask.path // Reuse the Bezier path
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = borderColor.cgColor
            borderLayer.lineWidth = borderWidth
            borderLayer.frame = self.bounds
            layer.addSublayer(borderLayer)
        }
    }
    
    func rotate(duration: CFTimeInterval = 1.0) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func roundCornersVersionT(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func editCorner(radius: CGFloat? = 0, bot: Bool? = false, top: Bool? = false) {
        if bot == true {
            clipsToBounds = true
            layer.cornerRadius = radius ?? 0
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if top == true {
            clipsToBounds = true
            layer.cornerRadius = radius ?? 0
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func calculatePreferredHeight(preferredWidth: CGFloat? = nil) -> CGFloat {
        let width = preferredWidth ?? frame.width
        let widthConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==\(width)@999)]", options: [], metrics: nil, views: ["view": self])
        addConstraints(widthConstraint)
        let height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        removeConstraints(widthConstraint)
        return height
    }
    
    func sketchShadow(x: CGFloat = 2, y: CGFloat = 2, opacity: Float = 0.4, radius: CGFloat = 4, color: UIColor = .black) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    func addDashedBorder(cornerRadius: CGFloat = 8.0) {
        let viewBorder = CAShapeLayer()
        viewBorder.strokeColor = UIColor.white.cgColor
        viewBorder.lineDashPattern = [2, 2]
        viewBorder.frame = self.bounds
        viewBorder.fillColor = nil
        viewBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        self.layer.insertSublayer(viewBorder, at:0)
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }


    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    func linearGradientBackground(angleInDegs: Int, colors: [CGColor]) -> CAGradientLayer {
          let gradientBaseLayer: CAGradientLayer = CAGradientLayer()
          gradientBaseLayer.frame = self.frame
          gradientBaseLayer.colors = colors
          gradientBaseLayer.startPoint = startAndEndPointsFrom(angle: angleInDegs).startPoint
          gradientBaseLayer.endPoint = startAndEndPointsFrom(angle: angleInDegs).endPoint
          self.layer.insertSublayer(gradientBaseLayer, at: 0)
        return gradientBaseLayer
      }
}

class OverlayView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(bounds)
        context?.setBlendMode(.clear)
        context?.setFillColor(UIColor.clear.cgColor)
        superview?.allSubViewsOf().forEach({
            if $0 != self && $0.isLoadingAnimation == true {
                context?.fill($0.frame)
            }
        })
    }

}

public protocol FactoryUIView {
    static func fromNib() -> Self
}

public extension FactoryUIView where Self: UIView {
    static func fromNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: Self.self), owner: nil, options: nil)!.first as! Self
        return view
    }
}

extension UIColor {

    // convenience by hex string
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        if cString.count == 6 {
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
        } else {
            self.init(red: 1, green: 1, blue: 1, alpha: CGFloat(1.0))
        }
    }

    // TODO: Mock common app color. Change later
    static var appTintColor = UIColor(hex: "#045684")
    static var appYellowColor = UIColor(hex: "#EEBD26")
    static var appRedColor = UIColor(hex: "#D0021B")
    static var appTextColor = UIColor(hex: "#43496A")
    
    convenience init(hexa: String) {
        var cString:String = hexa.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        if cString.count == 8 {
            self.init(red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x000000FF) / 255.0, alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0)
        } else {
            self.init(red: 1, green: 1, blue: 1, alpha: CGFloat(1.0))
        }
    }
    
    class func backgroundGray() -> UIColor {
        return UIColor(red: 246.0 / 255, green: 247 / 255, blue: 248 / 255, alpha: 1)
    }
    
    class func lightGray() -> UIColor {
        return UIColor(red: 238.0 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
    }
    
    class func darkGray() -> UIColor {
        return UIColor(red: 221.0 / 255, green: 221 / 255, blue: 221 / 255, alpha: 1)
    }
}
