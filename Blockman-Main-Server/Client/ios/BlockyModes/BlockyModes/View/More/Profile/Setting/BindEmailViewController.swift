//
//  BindEmailViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/26.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class BindEmailViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return BindEmailInput.self}
    
    private(set) var textField: UITextField?
    private(set) var button: UIButton?
    private(set) var isSendedEmail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func createAndLayoutChildViews() {
        textField = UITextField().addTo(superView: view).configure { (textField) in
            textField.setDefaultStyle(placeHolder: NSLocalizedString("input_email", comment: "输入邮箱"), isSecure: false)
        }.layout(snapKitMaker: { (make) in
            make.top.equalToSuperview().offset(margin_12)
            make.left.right.equalToSuperview().inset(margin_16)
            make.height.equalTo(50)
        })
        
        button = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle(fontSize: 15)
            button.setTitle(NSLocalizedString("next_step", comment: "下一步"), for: .normal)
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(textField!.snp.bottom).offset(margin_10)
            make.centerX.equalToSuperview()
            make.width.equalTo(textField!.snp.width)
            make.height.equalTo(40)
        })
    }

    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let bindEmailOutput = output as! BindEmailOutput
        bindEmailOutput.emailValid.filter({ [unowned self] _ -> Bool in
            return !self.isSendedEmail
        }).drive(button!.rx.isEnabled).disposed(by: disposeBag)
        
        bindEmailOutput.codeValid.filter({ [unowned self] _ -> Bool in
            return self.isSendedEmail
        }).drive(button!.rx.isEnabled).disposed(by: disposeBag)
        
        bindEmailOutput.fetchVerifyCodeResult.drive(onNext: { [unowned self] result in
            switch result {
            case .success:
                self.textField?.text = nil
                self.textField?.placeholder = NSLocalizedString("input_verification_code", comment: "输入验证码")
                self.textField?.keyboardType = .numberPad
                self.button?.setTitle(NSLocalizedString("done", comment: "完成"), for: .normal)
                self.isSendedEmail = true
                BlockyHUD.showText(NSLocalizedString("send_success_check_mail", comment: "发送成功，请检查邮箱"), inView: self.view)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
        
        bindEmailOutput.bindEmailResult.drive(onNext: { [unowned self] result in
            switch result {
            case .success:
                AnalysisManager.trackEvent(AnalysisManager.Event.more_email_suc)
                BlockyHUD.showText(NSLocalizedString("bind_success", comment: "绑定成功"), inView: self.view)
                AppDelegate.globalServive().popViewModel(animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField?.resignFirstResponder()
    }
}

struct BindEmailInput: ViewToViewModelInput {
    
    let emailInput: Driver<String>
    let verifyCodeInput: Driver<String>
    let confirmTap: Driver<Bool>
    
    init(view: BaseViewController) {
        let bindEmailViewController = view as! BindEmailViewController
        emailInput = bindEmailViewController.textField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
        verifyCodeInput = bindEmailViewController.textField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
        confirmTap = bindEmailViewController.button!.rx.tap.asDriver().map({
            bindEmailViewController.isSendedEmail
        })
    }
}
