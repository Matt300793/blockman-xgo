//
//  RegisterViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/18.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RegisterViewController: BaseViewController {

    override var inputType: ViewToViewModelInput.Type? {return RegisterInput.self}
    
    fileprivate weak var hasAccountButton: UIButton?
    fileprivate weak var registerButton: UIButton?
    fileprivate weak var accountInputView: UnderlineInputView?
    fileprivate weak var passwordInputView: UnderlineInputView?
    fileprivate var validPasswordInputView: UnderlineInputView?

    override func createAndLayoutChildViews() {
        
        view.backgroundColor = R.color.appColor.mainBackground()
        
        accountInputView = UnderlineInputView(frame: .zero, placeHolder: R.string.localizable.account_name() + " " + R.string.localizable.more_than_three_digits_or_letters())
            .addTo(superView: view).layout(snapKitMaker: { (make) in
                make.left.right.equalToSuperview().inset(45)
                make.top.equalToSuperview()
                make.height.equalTo(20)
                make.centerX.equalToSuperview()
            })
        
        passwordInputView = UnderlineInputView(frame: .zero, placeHolder: R.string.localizable.account_password() + " " + R.string.localizable.more_than_six_digits_or_letters(), secureTextEntry: true)
            .addTo(superView: view).layout(snapKitMaker: { [unowned self] (make) in
                make.size.centerX.equalTo(self.accountInputView!)
                make.top.equalTo(self.accountInputView!.snp.bottom).offset(26)
            })
        
        validPasswordInputView = UnderlineInputView(frame: .zero, placeHolder: NSLocalizedString("confirm_password", comment: "确认密码"), secureTextEntry: true).addTo(superView: view).layout(snapKitMaker: { [unowned self] (make) in
            make.size.equalTo(self.passwordInputView!.snp.size)
            make.centerX.equalTo(self.passwordInputView!)
            make.top.equalTo(self.passwordInputView!.snp.bottom).offset(26)
        })
        
        registerButton = UIButton().addTo(superView: view).configure({ (btn) in
            btn.setDefaultStyle(fontSize: 16)
            btn.setTitle(NSLocalizedString("create_account", comment: "创建账号"), for: .normal)
            btn.setTitleColor(R.color.appColor.white(), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.equalTo(CGSize(width: 240, height: 40))
            make.top.equalTo(self.validPasswordInputView!.snp.bottom).offset(20)
            make.centerX.equalTo(self.validPasswordInputView!)
        })
        
        hasAccountButton = UIButton().addTo(superView: view).configure({ (btn) in
            btn.setTitle(NSLocalizedString("has_already_account", comment: "已有账号"), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitleColor(R.color.appColor.text_light(), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.top.equalTo(self.registerButton!.snp.bottom).offset(12)
            make.right.equalTo(self.registerButton!)
        })
        hasAccountButton!.rx.tap.asDriver().drive(onNext: { _ in
            AnalysisManager.trackEvent(AnalysisManager.Event.regpage_login)
            NotificationCenter.default.post(name: .BMRegisterControllerSwitchToLogin, object: nil)
        }).disposed(by: disposeBag)
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let registerOutput = output as! RegisterOutput
        registerOutput.registerValid.drive(registerButton!.rx.isEnabled).disposed(by: disposeBag)
        registerOutput.registerResult.drive(onNext: { (result) in
            switch result.1 {
            case .success:
                let jsonResult = result.0
                let userID = String(jsonResult["userId"] as! Int64)
                let token = jsonResult["accessToken"] as! String
                AppDelegate.globalServive().pushViewModel(RegisterConfirmViewModel.self, params: (userID, token, false), animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        validPasswordInputView!.resignResponder()
    }
}

struct RegisterInput: ViewToViewModelInput {
    
    let accountInput: Driver<String>
    let passwordInput: Driver<String>
    let validPasswordInput: Driver<String>
    let registerTap: Driver<()>
    
    init(view: BaseViewController) {
        let loginView = view as! RegisterViewController
        
        accountInput = loginView.accountInputView!.textField.rx.text.orEmpty.asDriver()
        passwordInput = loginView.passwordInputView!.textField.rx.text.orEmpty.asDriver()
        validPasswordInput = loginView.validPasswordInputView!.textField.rx.text.orEmpty.asDriver()
        registerTap = loginView.registerButton!.rx.tap.asDriver().do(onNext: { _ in
            loginView.accountInputView?.resignResponder()
            loginView.passwordInputView?.resignResponder()
            loginView.validPasswordInputView?.resignResponder()
        })
    }
}
