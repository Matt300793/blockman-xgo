//
//  ModifyPasswordViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/25.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ModifyPasswordViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return ModifyPasswordViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return ModifyPasswordOutput.self}
    
    override func initialize() {
        viewTitle.value = R.string.localizable.modify_password()
    }
}

struct ModifyPasswordOutput: ViewModelToViewOutput {
    let newPasswordValid: Driver<VerifyResult>
    let modifyValid: Driver<Bool>
    let modifyResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let modifyPwdViewModel = viewModel as! ModifyPasswordViewModel
        let input = modifyPwdViewModel.viewInput as! ModifyPasswordInput
        
        modifyValid = Driver.combineLatest(input.originPwdInput, input.newPwdInput, input.doublePwdInput) {
            $0.count >= 6 && $1.count >= 6 && $2.count >= 6
        }
        
        newPasswordValid = Driver.combineLatest(input.newPwdInput, input.doublePwdInput, resultSelector: {
            VerifyServer.verify(password: $0, doublePassword: $1)
        })
        
        let originAndNewPwd = Driver.combineLatest(input.originPwdInput, input.newPwdInput) {
            ($0, $1)
        }
        modifyResult = input.doneTap.filter({ $0
        }).withLatestFrom(originAndNewPwd).flatMapLatest {
            UserNetServer.modifyPassword(origin: $0.0, new: $0.1).map({ _ in BlockyResult
                .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
    }
}
