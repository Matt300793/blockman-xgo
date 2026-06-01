//
//  ViewModelService.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class ViewModelService: NSObject {
    let pushSubject: PublishSubject<(BaseViewModel.Type, Any?, Bool)> = PublishSubject()
    let popSubject: PublishSubject<Bool> = PublishSubject()
    let popToRootSubject: PublishSubject<Bool> = PublishSubject()
    let presentSubject: PublishSubject<(BaseViewModel.Type, Any?, Bool, (() -> Void)?)> = PublishSubject()
    let dismissSubject: PublishSubject<(Bool, (() -> Void)?)> = PublishSubject()
    let resetRootSubject: PublishSubject<BaseViewModel.Type> = PublishSubject()
    
    override init() {
        super.init()
    }
}

extension ViewModelService: NavigationProtocol {
    
    func pushViewModel(_ viewModel: BaseViewModel.Type, params: Any?, animated: Bool) {
        pushSubject.onNext((viewModel, params, animated))
    }
    
    func popViewModel(animated: Bool) {
        popSubject.onNext(animated)
    }
    
    func popToRootViewModel(animated: Bool) {
        popToRootSubject.onNext(animated)
    }
    
    func presentViewModel(_ viewModelToPresent: BaseViewModel.Type, params: Any?, animated: Bool, completion: (() -> Void)?) {
        presentSubject.onNext((viewModelToPresent, params, animated, completion))
    }
    
    func dismissViewModel(animated: Bool, completion: (() -> Void)?) {
        dismissSubject.onNext((animated, completion))
    }
    
    func resetRootViewModel(_ viewModel: BaseViewModel.Type) {
        resetRootSubject.onNext(viewModel)
    }
}
