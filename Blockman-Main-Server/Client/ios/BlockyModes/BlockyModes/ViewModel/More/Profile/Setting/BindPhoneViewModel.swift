//
//  BindPhoneViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/26.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class BindPhoneViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return BindPhoneViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return BindPhoneOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("phone_number", comment: "手机号码")
    }
}

struct BindPhoneOutput: ViewModelToViewOutput {
    let phoneValid: Driver<Bool>
    let doneVerifyValid: Driver<Bool>
    let fetchVerificationCodeResult: Driver<BlockyResult>
    let bindResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        var bindingPhone = ""
        
        let bindPhoneViewModel = viewModel as! BindPhoneViewModel
        let bindPhoneInput = bindPhoneViewModel.viewInput as! BindPhoneInput
        
        phoneValid = bindPhoneInput.phoneInput.map {
            let isValid = VerifyServer.verify(phone: $0).isValid
            isValid ? bindingPhone = $0 : ()
            return isValid
        }
        
        let verificationCodeValid = bindPhoneInput.verifyCodeInput.map {
            VerifyServer.verify(verificationCode: $0).isValid
        }
        
        fetchVerificationCodeResult = bindPhoneInput.fetchVerificationCodeTap.withLatestFrom(bindPhoneInput.phoneInput).flatMapLatest {
            UserNetServer.fetchVerificationCode(phone: $0, type: .phoneBind).map({_ -> BlockyResult in
                .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
        
        doneVerifyValid = Driver.combineLatest(phoneValid, verificationCodeValid, resultSelector: { (phone, verification) in
            phone && verification
        })
        
        let phoneAndCode = Driver.combineLatest(bindPhoneInput.phoneInput, bindPhoneInput.verifyCodeInput) {
            ($0, $1)
        }
        bindResult = bindPhoneInput.doneVerifyTap.withLatestFrom(phoneAndCode).flatMapLatest({
            UserNetServer.bindPhone($0.0, verificationCode: $0.1).map({_ -> BlockyResult in
                AccountInfoManager.shared.updateBindedPhone(bindingPhone)
                return .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        })
    }
}
