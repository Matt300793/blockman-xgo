//
//  ResetPasswordViewController.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/10.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class ResetPasswordViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return ResetPasswordInput.self}

#if BLOCKY_OVERSEA
    private(set) weak var emailTextField: UITextField?
    private(set) weak var doneButton: UIButton?
    
#else
    private(set) weak var phoneTextField: UITextField?
    private(set) weak var verifyCodeTextField: UITextField?
    private(set) weak var fetchVerifyCodeButton: CaptchaCountDownButton?
    private(set) weak var newPasswordTextField: UITextField?
    private(set) weak var doublePasswordTextField: UITextField?
    private(set) weak var doneResetButton: UIButton?
    
    private(set) var passwordVerifyResult: VerifyResult?
#endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false , animated: true)
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
#if BLOCKY_OVERSEA
        emailTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: NSLocalizedString("input_email", comment: "输入邮箱"), isSecure: false)
        }).layout(snapKitMaker: { (make)  in
            make.left.right.equalToSuperview().inset(margin_16)
            make.top.equalToSuperview().offset(margin_12)
            make.height.equalTo(50)
        })
    
        doneButton = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle(fontSize: 15)
            button.setTitle(NSLocalizedString("done", comment: "完成"), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.width.equalTo(self.emailTextField!)
            make.top.equalTo(self.emailTextField!.snp.bottom).offset(margin_12)
            make.centerX.equalTo(self.emailTextField!)
            make.height.equalTo(40)
        })
#else
        let phonePrefixLab = UILabel().config(text: "中国大陆 +86", textColor: R.color.appColor._333333(), textAlignment: .center , font: UIFont.size14)
        phonePrefixLab.backgroundColor = R.color.appColor._fae7ca()
        view.addSubview(phonePrefixLab)
        phonePrefixLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: 123, height: 50))
        }
    
        phoneTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: "输入手机号码", isSecure: false)
        }).layout(snapKitMaker: { (make) in
            make.top.height.equalTo(phonePrefixLab)
            make.left.equalTo(phonePrefixLab.snp.right).offset(1)
            make.right.equalToSuperview().offset(-16)
        })
    
        verifyCodeTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: "输入验证码", isSecure: false)
        }).layout(snapKitMaker: { (make) in
            make.left.equalTo(phonePrefixLab)
            make.top.equalTo(phonePrefixLab.snp.bottom).offset(10)
            make.size.equalTo(CGSize(width: 180, height: 50))
        })
    
        fetchVerifyCodeButton = CaptchaCountDownButton(countDown: 60).addTo(superView: view).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle("获取验证码", for: .normal)
            button.titleLabel.font = UIFont.size15
            button.setTitleColor(R.color.appColor._FEFEFE(), for: .disabled)
        }).layout(snapKitMaker: { (make) in
            make.left.equalTo(verifyCodeTextField!.snp.right).offset(10)
            make.top.height.equalTo(verifyCodeTextField!)
            make.right.equalToSuperview().offset(-16)
        })
    
        newPasswordTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: "输入新密码", isSecure: true)
        }).layout(snapKitMaker: { (make) in
            make.left.right.equalToSuperview().inset(margin_16)
            make.top.equalTo(verifyCodeTextField!.snp.bottom).offset(margin_10)
            make.height.equalTo(verifyCodeTextField!)
        })
    
        doublePasswordTextField = UITextField().addTo(superView: view).configure({ (textField) in
            textField.setDefaultStyle(placeHolder: "重复新密码", isSecure: true)
        }).layout(snapKitMaker: { (make) in
            make.centerX.size.equalTo(newPasswordTextField!)
            make.top.equalTo(newPasswordTextField!.snp.bottom).offset(margin_10)
        })
    
        doneResetButton = UIButton().addTo(superView: view).configure({ (button) in
            button.setDefaultStyle()
            button.setTitle("确定", for: .normal)
            button.titleLabel.font = UIFont.size15
            button.setTitleColor(R.color.appColor._FEFEFE(), for: .disabled)
        }).layout(snapKitMaker: { (make) in
            make.top.equalTo(doublePasswordTextField!.snp.bottom).offset(margin_10)
            make.left.right.equalToSuperview().inset(margin_16)
            make.height.equalTo(newPasswordTextField!)
        })
#endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
#if BLOCKY_OVERSEA
        emailTextField?.resignFirstResponder()
#else
        resignAllTextfieldResponder()
#endif
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let resetPwdOutput = output as! ResetPasswordOutput

#if BLOCKY_OVERSEA
        resetPwdOutput.emailValid.drive(doneButton!.rx.isEnabled).disposed(by: disposeBag)
        resetPwdOutput.sendEmailResult.drive(onNext: { [unowned self] result in
            switch result {
            case .success:
                BlockyHUD.showText(NSLocalizedString("send_success_check_mail", comment: "发送成功，请检查邮箱"), inView: self.view.window!)
                AppDelegate.globalServive().popViewModel(animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
#else
        resetPwdOutput.phoneValid.drive(fetchVerifyCodeButton!.rx.isEnabled).disposed(by: disposeBag)
        resetPwdOutput.doneResetValid.drive(doneResetButton!.rx.isEnabled).disposed(by: disposeBag)
        resetPwdOutput.newPasswordValid.drive(onNext: { [weak self] in
            self?.passwordVerifyResult = $0
        }).disposed(by: disposeBag)
    
        resetPwdOutput.fetchVerificationCodeResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
            BlockyHUD.showText("验证码发送成功", inView: self.view)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    
        resetPwdOutput.resetResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .success:
                BlockyHUD.showText("重置成功", inView: self.view)
                AppDelegate.globalServive().popViewModel(animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
#endif
    }
    
    fileprivate func resignAllTextfieldResponder() {
#if BLOCKY_OVERSEA
#else
        phoneTextField?.resignFirstResponder()
        verifyCodeTextField?.resignFirstResponder()
        newPasswordTextField?.resignFirstResponder()
        doublePasswordTextField?.resignFirstResponder()
#endif
    }
}


struct ResetPasswordInput: ViewToViewModelInput {

#if BLOCKY_OVERSEA
    let emailInput: Driver<String>
    let doneTap: Driver<()>
    init(view: BaseViewController) {
        let resetPasswordView = view as! ResetPasswordViewController
        emailInput = resetPasswordView.emailTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
        doneTap = resetPasswordView.doneButton!.rx.tap.asDriver().throttle(0.5).do(onNext: { _ in
            resetPasswordView.emailTextField?.resignFirstResponder()
        })
    }
#else
    let phoneInput: Driver<String>
    let verifyCodeInput: Driver<String>
    let newPasswordInput: Driver<String>
    let doublePasswordInput: Driver<String>
    let fetchVerificationCodeTap: Driver<()>
    let doneResetTap: Driver<Bool>
    
    init(view: BaseViewController) {
        
    let resetPasswordView = view as! ResetPasswordViewController
    phoneInput = resetPasswordView.phoneTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
    verifyCodeInput = resetPasswordView.verifyCodeTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
    newPasswordInput = resetPasswordView.newPasswordTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
    doublePasswordInput = resetPasswordView.doublePasswordTextField!.rx.text.orEmpty.asDriver().throttle(0.3).distinctUntilChanged()
    fetchVerificationCodeTap = resetPasswordView.fetchVerifyCodeButton!.rx.tap.asDriver()
    doneResetTap = resetPasswordView.doneResetButton!.rx.tap.asDriver().throttle(0.5).map({
        resetPasswordView.resignAllTextfieldResponder()
        switch resetPasswordView.passwordVerifyResult! {
        case let .failed(message: error):
            BlockyAlert.show(title: R.string.localizable.notification(), message: error)
            return false
        default:
            return true
        }
        })
    }
#endif
}
