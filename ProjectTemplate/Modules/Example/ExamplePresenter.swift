//
//  ExamplePresenter.swift
//  ProjectTemplate
//
//  Created by Nguyễn Đạt on 20/12/2022.
//  Copyright © 2022 dat.nguyen. All rights reserved.
//

final class ExamplePresenter {

    private weak var view: ExampleViewInterface?
    private var interactor: ExampleInteractorInterface
    private var wireframe: ExampleWireframeInterface

    init(view: ExampleViewInterface,
         interactor: ExampleInteractorInterface,
         wireframe: ExampleWireframeInterface) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

extension ExamplePresenter: ExamplePresenterInterface {
}

extension ExamplePresenter: ExampleInteractorOutputInterface {

    func handleError(_ error: Error, _ completion: (() -> Void)?) {
        view?.hideLoading()
        wireframe.handleError(error, completion)
    }
}
