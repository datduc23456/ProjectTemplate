//
//  ExampleWireframe.swift
//  ProjectTemplate
//
//  Created by Nguyễn Đạt on 20/12/2022.
//  Copyright © 2022 dat.nguyen. All rights reserved.
//

import UIKit

final class ExampleWireframe: ExampleWireframeInterface {
	var navigator: BaseNavigator!
    static func generateModule(_ payload: Any?) -> UIViewController {
	var storyboardName = "ExampleViewController"
        if UIDevice.current.userInterfaceIdiom == .pad {
            storyboardName = "ExampleViewController_iPad"
        }
        let initialViewController = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() as! ExampleViewController
        initialViewController.payload = payload
	initialViewController.modalPresentationStyle = .fullScreen
        // let vc = initialViewController.topViewController as! ExampleViewController
        let wireframe = ExampleWireframe()
	wireframe.navigator = BaseNavigator()
	wireframe.navigator.delegate = initialViewController
        let interactor = ExampleInteractor()
        let presenter = ExamplePresenter(
            view: initialViewController,
            interactor: interactor,
            wireframe: wireframe)
        interactor.output = presenter
        initialViewController.presenter = presenter
        return initialViewController
    }

	func handleError(_ error: Error, _ completion: (() -> Void)?) {
        
    }
}
