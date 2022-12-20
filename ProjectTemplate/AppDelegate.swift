//
//  AppDelegate.swift
//  ProjectTemplate
//
//  Created by Nguyễn Đạt on 20/12/2022.
//

import UIKit
import Network

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var monitor: NWPathMonitor!
    var realmUtils: RealmUtils!
    
    static var shared: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure()
            exit(0)
        }
        return delegate
    }
    
    var appRootViewController: UIViewController {
        return (window?.rootViewController)!
    }
    
    var navigationRootViewController: UINavigationController {
        return window!.rootViewController as! UINavigationController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        realmUtils = RealmUtilsProvider.defaultStorage
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InternetConnected"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InternetLost"), object: nil)
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

