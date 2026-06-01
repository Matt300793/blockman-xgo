//
//  UnbindPhoneViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/27.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class UnbindPhoneViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return UnbindPhoneViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return UnbindPhoneOutput.self}
}

struct UnbindPhoneOutput: ViewModelToViewOutput {
    let unbindResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let unbindPhoneViweModel = viewModel as! UnbindPhoneViewModel
        let unbindPhoneInput = unbindPhoneViweModel.viewInput as! UnbindPhoneInput
        
        unbindResult = unbindPhoneInput.unbindTap.withLatestFrom(unbindPhoneInput.verificationCodeInput).flatMapLatest {
            UserNetServer.unbindPhone(AccountInfoManager.shared.phone.value, verificationCode: $0).map({ _ -> BlockyResult in
                AccountInfoManager.shared.removeBindedPhone()
                return .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
    }
}
