//
//  Provider.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

//  MARK: Input
protocol ViewToViewModelInput {
    init(view: BaseViewController)
}

protocol ViewToViewModelInputProvider {
    var inputType : ViewToViewModelInput.Type? {get}
    func provideInput() -> ViewToViewModelInput?
}

extension ViewToViewModelInputProvider where Self : BaseViewController {
    func provideInput() -> ViewToViewModelInput? {
        return self.inputType?.init(view: self)
    }
}

//  MARK: Output
protocol ViewModelToViewOutput {
    init(viewModel: BaseViewModel)
}

protocol ViewModelToViewOutputProvider {
    var outputType: ViewModelToViewOutput.Type? {get}
    func provideOutput() -> ViewModelToViewOutput?
}

extension ViewModelToViewOutputProvider where Self : BaseViewModel {
    func provideOutput() -> ViewModelToViewOutput? {
        return self.outputType?.init(viewModel: self)
    }
}
