//
//  ExtensionUseful.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 19/10/2022.
//

import Foundation
import UIKit
import CommonCrypto
import CryptoKit

typealias VoidCallBack = (()->Void)
private var payloadKey = 1

extension Optional {
    func isNil(value: Wrapped) -> Wrapped {
        if self != nil {
            return self!  // `as!` is unnecessary
        }
        return value
    }
}

extension Array {
    func dictionary<Key, Value>(withKey key: KeyPath<Element, Key>, value: KeyPath<Element, Value>) -> [Key: Value] {
        return reduce(into: [:]) { dictionary, element in
            let key = element[keyPath: key]
            let value = element[keyPath: value]
            dictionary[key] = value
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}

extension Data {
    func tranforms<T: Decodable>(to: T.Type) -> T? {
        guard let response = try? JSONDecoder().decode(to, from: self) else { return nil }
        return response
    }
    
    func tranforms1<T: Decodable>(to: T.Type) -> T? {
        return try! JSONDecoder().decode(to, from: self)
    }
    
    func toDictionary() -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func debug() {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])
            let datatwo = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let printableJson = String(data: datatwo, encoding: .utf8)
            print("Json From Data:\n\(printableJson ?? "null")")
        } catch {
            print("Json From Data: ?? :D ??")
        }
    }
}

extension UIViewController {
    public var payload: Any? {
        get {
            return objc_getAssociatedObject(self, &payloadKey)
        }
        set {
            objc_setAssociatedObject(self, &payloadKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let nav = self as? UINavigationController {
                nav.viewControllers.first?.payload = newValue
            }
            if let tab = self as? UITabBarController {
                tab.viewControllers?.forEach({ vc in
                    vc.payload = newValue
                })
            }
        }
    }
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = view.frame
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    func appWindow() -> UIWindow {
        return ((UIApplication.shared.delegate?.window)!)!
    }
}

extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data { Data(self.utf8) }
    
    var md5: String {
        
        if #available(iOS 13.0, *) {
            
            guard let d = self.data(using: .utf8) else { return ""}
            let digest = Insecure.MD5.hash(data: d)
            let h = digest.reduce("") { (res: String, element) in
                let hex = String(format: "%02x", element)
                //print(ch, hex)
                let  t = res + hex
                return t
            }
            return h
            
        } else {
            // Fall back to pre iOS13
            let length = Int(CC_MD5_DIGEST_LENGTH)
            var digest = [UInt8](repeating: 0, count: length)
            
            if let d = self.data(using: .utf8) {
                _ = d.withUnsafeBytes { body -> String in
                    CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)
                    return ""
                }
            }
            let result = (0 ..< length).reduce("") {
                $0 + String(format: "%02x", digest[$1])
            }
            return result
            
        }
    }
}

extension UIColor {
    public class func colorWith(hexStr: String, alpha: CGFloat = 1) -> UIColor {
        let scanner = Scanner(string: hexStr.replacingOccurrences(of: "#", with: "") as String)
        var color: UInt64 = 0
        return scanner.scanHexInt64(&color)
            ? UIColor(red: CGFloat((color & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((color & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(color & 0x0000FF) / 255.0,
                      alpha: alpha)
            : .white
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        let myString = formatter.string(from: self)
        return myString
    }
}

extension String {
    func toDate(timeZone: TimeZone = TimeZone.current, dateFormat: String = "yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func toDateFormat(toFormat: String = "HH:mm", timeZone: TimeZone = .current) -> String {
        return (self.toDate() ?? Date()).toString(format: toFormat)
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Int {
        let divisor = pow(10.0, Double(places))
        return Int(((self) / divisor).rounded())
    }
    
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
