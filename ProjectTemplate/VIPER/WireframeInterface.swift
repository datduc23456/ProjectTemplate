//
//  WireframeInterface.swift
//  ArrvisCore
//
//  Created by dat.nguyenquoc on 2018/02/08.
// 
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos
import RxSwift

private var imagePickerDelegateKey = 0
private var disposeBagKey = 1

public protocol WireframeInterface: AnyObject, ErrorHandleable {
    var navigator: BaseNavigator! { get }
    static func generateModule(_ payload: Any?) -> UIViewController
}

public extension WireframeInterface {
    func showPlayVideo(_ key: String, _ fromRoot: Bool) {
        navigator.showPlayVideo(key, fromRoot)
    }
    
    func popScreen(result: Any? = nil, animate: Bool = true) {
        navigator.popScreen(result: result, animate: animate)
    }
    
    func alertLostConnection(_ title: String = "", message: String = "", actionMessage: String = "") {
        let alert =  UIAlertController(title: "Can't connect to the internet", message: "Connect to the internet\nin order to access", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to setting", style: .cancel, handler: { (action: UIAlertAction) -> Void in
//            self.dismiss(animated: true, completion: nil)
            guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingUrl) {
                UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
            } else {
                print("cant open settings")
            }
        }))
        navigator.showAlert(alert)
    }
}
