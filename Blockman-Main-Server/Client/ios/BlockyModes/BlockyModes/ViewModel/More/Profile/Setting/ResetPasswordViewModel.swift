//
//  ResetPasswordViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/10.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class ResetPasswordViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return ResetPasswordViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return ResetPasswordOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("modify_password", comment: "修改密码")
    }
}


struct ResetPasswordOutput: ViewModelToViewOutput {
#if BLOCKY_OVERSEA
    let emailValid: Driver<Bool>
    let sendEmailResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let resetPwdViewModel = viewModel as! ResetPasswordViewModel
        let resetPwdInput = resetPwdViewModel.viewInput as! ResetPasswordInput
        
        emailValid = resetPwdInput.emailInput.map {
            VerifyServer.verify(email: $0).isValid
        }
        
        sendEmailResult = resetPwdInput.doneTap.withLatestFrom(resetPwdInput.emailInput).flatMapLatest {
            UserNetServer.sendResetPasswordEmail(email: $0).map({_ -> BlockyResult in
                .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
    }
#else
    let phoneValid: Driver<Bool>
    let doneResetValid: Driver<Bool>
    let newPasswordValid: Driver<VerifyResult>
    let fetchVerificationCodeResult: Driver<BlockyResult>
    let resetResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let resetPwdViewModel = viewModel as! ResetPasswordViewModel
        let resetPwdInput = resetPwdViewModel.viewInput as! ResetPasswordInput
        
        var bindingPhone = ""
        
        phoneValid = resetPwdInput.phoneInput.map {
            let isValid = VerifyServer.verify(phone: $0).isValid
            isValid ? bindingPhone = $0 : ()
            return isValid
        }
        
        doneResetValid = Driver.combineLatest(resetPwdInput.verifyCodeInput, resetPwdInput.newPasswordInput, resetPwdInput.doublePasswordInput, resultSelector: { (verifyCode, newPwd, doublePwd) in
            VerifyServer.verify(verificationCode: verifyCode).isValid && newPwd.count >= 6 && doublePwd.count >= 6
        })
        
        newPasswordValid = Driver.combineLatest(resetPwdInput.newPasswordInput, resetPwdInput.doublePasswordInput, resultSelector: {
            VerifyServer.verify(password: $0, doublePassword: $1)
        })
        
        fetchVerificationCodeResult = resetPwdInput.fetchVerificationCodeTap.withLatestFrom(resetPwdInput.phoneInput).flatMapLatest {
            UserNetServer.fetchVerificationCode(phone: $0, type: .passwordReFound).map({_ -> BlockyResult in
                .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
        
        let codeAndNewPwd = Driver.combineLatest(resetPwdInput.newPasswordInput, resetPwdInput.verifyCodeInput) {
            ($0, $1)
        }
        resetResult = resetPwdInput.doneResetTap.filter({ $0
        }).withLatestFrom(codeAndNewPwd).flatMapLatest {
            UserNetServer.resetPassword(pwd: $0.0, phone: bindingPhone, verificationCode: $0.1).map({ _ in BlockyResult
                .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
    }
#endif
}
