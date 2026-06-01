//
//  BindEmailViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/26.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class BindEmailViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return BindEmailViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return BindEmailOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("mail", comment: "邮箱")
    }
    
}

struct BindEmailOutput: ViewModelToViewOutput {
    
    let emailValid: Driver<Bool>
    let codeValid: Driver<Bool>
    let fetchVerifyCodeResult: Driver<BlockyResult>
    let bindEmailResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let bindEmailViewModel = viewModel as! BindEmailViewModel
        let bindEmailInput = bindEmailViewModel.viewInput as! BindEmailInput
        var bindingEmail = ""
        
        emailValid = bindEmailInput.emailInput.map {
            VerifyServer.verify(email: $0).isValid
        }
        
        codeValid = bindEmailInput.verifyCodeInput.map{ code in
            VerifyServer.verify(verificationCode: code, length: 6).isValid
        }
        
        // 发送邮件获取验证码
       fetchVerifyCodeResult = bindEmailInput.confirmTap.filter {
            !$0
        }.withLatestFrom(bindEmailInput.emailInput).flatMapLatest { email in
            UserNetServer.fetchBindEmailVerifyCode(email: email).map({ _ -> BlockyResult in
                bindingEmail = email
                return .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
        
        // 绑定邮箱
        bindEmailResult = bindEmailInput.confirmTap.filter({
            $0
        }).withLatestFrom(bindEmailInput.verifyCodeInput).flatMapLatest({
            UserNetServer.bindEmail(email: bindingEmail, verifyCode: $0).map({ _ -> BlockyResult in
                AccountInfoManager.shared.updateBindEmail(bindingEmail)
                return .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        })
    }
}
