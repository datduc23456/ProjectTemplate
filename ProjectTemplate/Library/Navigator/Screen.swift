//
//  BaseNavigator.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 20/10/2022.
//

import UIKit
public protocol Screen {
    var path: String { get }
    var transition: NavigateTransions { get }
    func createViewController(_ payload: Any?) -> UIViewController
}

public enum NavigateTransions: String {
    case replace
    case push
    case present
}

enum AppScreens: String, Screen, CaseIterable {
    case example
    case home
    case tvShow
    case favorite
    case detail
    case statistical
    case addnote
    case popularpeople
    case playvideo
    case search
    case note
    case action
    case genres
    case usernote
    case watchedList
    case season
    case images
    case videos
    case similar
    case setting
    
    var path: String {
        return rawValue
    }
    
    var transition: NavigateTransions {
        switch self {
        case .playvideo:
            return .present
        default:
            return .push
        }
    }
    
    func createViewController(_ payload: Any? = nil) -> UIViewController {
        switch self {
        case .example:
            return ExampleWireframe.generateModule(payload)
        default:
            return UIViewController()
        }
    }
}
