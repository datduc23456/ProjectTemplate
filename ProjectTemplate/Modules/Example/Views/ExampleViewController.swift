//
//  ExampleViewController.swift
//  ProjectTemplate
//
//  Created by Nguyễn Đạt on 20/12/2022.
//  Copyright © 2022 dat.nguyen. All rights reserved.
//

import UIKit

final class ExampleViewController: BaseViewController {

    // MARK: - Properties
	var presenter: ExamplePresenterInterface!
}

// MARK: - ExampleViewInterface
extension ExampleViewController: ExampleViewInterface {
}
