//
//  RegisterViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/18.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class RegisterViewModel: BaseViewModel {

    override class var mappedController: BaseViewController.Type {return RegisterViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return RegisterOutput.self}
    
}


struct RegisterOutput: ViewModelToViewOutput {
    let registerValid: Driver<Bool>
    let registerResult: Driver<([String : Any], BlockyResult)>
    
    init(viewModel: BaseViewModel) {
        let registerViewModel = viewModel as! RegisterViewModel
        let registerInput = registerViewModel.viewInput as! RegisterInput
        
        let accountValid = registerInput.accountInput.distinctUntilChanged().map {
            VerifyServer.verify(account: $0)
        }
        
        let passwordValid = Driver.combineLatest(registerInput.passwordInput, registerInput.validPasswordInput) {
            VerifyServer.verify(password: $0, doublePassword: $1)
        }
        
        registerValid = Driver.combineLatest(accountValid, passwordValid, resultSelector: { (account, password) -> Bool in
            switch (account, password) {
            case (.successful, .successful) :
                return true
            default:
                return false
            }
        })
        
        let accountAndPassword = Driver.combineLatest(registerInput.accountInput, registerInput.passwordInput) {
            ($0, $1)
        }
        registerResult = registerInput.registerTap.withLatestFrom(accountAndPassword).flatMapLatest({
            UserNetServer.register(account: $0.0, password: $0.1).map({ response -> ([String : Any], BlockyResult) in
                let accountInfo = response["data"] as! [String : Any]
                return (accountInfo, .success)
            }).asDriver(onErrorRecover: { (error) -> SharedSequence<DriverSharingStrategy, ([String : Any], BlockyResult)> in
                return Driver.just((["" : ""], .fail(error as! BlockyError)))
            })
        })
    }
}
