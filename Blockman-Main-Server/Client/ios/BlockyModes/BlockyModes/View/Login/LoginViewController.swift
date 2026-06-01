//
//  LoginViewController.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/18.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController {
    
    override var inputType: ViewToViewModelInput.Type? {return LoginInput.self}
    
#if BLOCKY_OVERSEA
    fileprivate weak var thirdLogInButton: UIButton?
    fileprivate var thirdLogInManager: ThirdLogInManager!
#endif
    fileprivate weak var createAccountButton: UIButton?
    fileprivate weak var forgetPswButton: UIButton?
    fileprivate weak var loginButton: UIButton?
    fileprivate weak var passwordInputView: UnderlineInputView?
    fileprivate weak var accountInputView: UnderlineInputView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = R.color.appColor.mainBackground()
        
        loginButton!.rx.tap.asDriver().drive(onNext: { [unowned self] in
            self.passwordInputView?.resignResponder()
            self.accountInputView?.resignResponder()
        }).disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        thirdLogInManager = ThirdLogInManager(from: self)
        AnalysisManager.trackEvent(AnalysisManager.Event.enter_loginpage)
    }
    
    override func createAndLayoutChildViews() {
        super.createAndLayoutChildViews()
        
        accountInputView = UnderlineInputView(frame: .zero, placeHolder: R.string.localizable.account_name())
            .addTo(superView: view).layout(snapKitMaker: { (make) in
                make.left.right.equalToSuperview().inset(45)
                make.top.equalToSuperview()
                make.height.equalTo(20)
                make.centerX.equalToSuperview()
            })
        
        passwordInputView = UnderlineInputView(frame: .zero, placeHolder: R.string.localizable.account_password(), secureTextEntry: true)
            .addTo(superView: view).layout(snapKitMaker: { [unowned self] (make) in
                make.size.centerX.equalTo(self.accountInputView!)
                make.top.equalTo(self.accountInputView!.snp.bottom).offset(26)
            })
        
        loginButton = UIButton().addTo(superView: view).configure({ (btn) in
            btn.setDefaultStyle(fontSize: 16)
            btn.setTitleColor(R.color.appColor.white(), for: .normal)
            btn.setTitle(NSLocalizedString("log_in", comment: "登录"), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.size.equalTo(CGSize(width: 240, height: 40))
            make.top.equalTo(self.passwordInputView!.snp.bottom).offset(20)
            make.centerX.equalTo(self.passwordInputView!)
        })
        
        createAccountButton = UIButton().addTo(superView: view).configure({ (btn) in
            btn.setTitle(NSLocalizedString("create_Account", comment: "创建账号"), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitleColor(R.color.appColor.text_light(), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.top.equalTo(self.loginButton!.snp.bottom).offset(12)
            make.right.equalTo(self.loginButton!)
        })
        createAccountButton!.rx.tap.asDriver().drive(onNext: { _ in
            AnalysisManager.trackEvent(AnalysisManager.Event.loginpage_reg)
            NotificationCenter.default.post(name: .BMLoginControllerSwitchToRegister, object: nil)
        }).disposed(by: disposeBag)
        
        forgetPswButton = UIButton().addTo(superView: view).configure({ (button) in
            button.setTitle(NSLocalizedString("forget_password", comment: "忘记密码"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(R.color.appColor.text_normal(), for: .normal)
        }).layout(snapKitMaker: { [unowned self] (make) in
            make.left.equalTo(self.loginButton!)
            make.top.equalTo(self.loginButton!.snp.bottom).offset(12)
        })
        forgetPswButton!.rx.tap.asDriver().drive(onNext: { _ in
            AppDelegate.globalServive().pushViewModel(ResetPasswordViewModel.self, params: nil, animated: true)
        }).disposed(by: disposeBag)
        
#if BLOCKY_OVERSEA
        thirdLogInButton = UIButton().addTo(superView: view).configure { (button) in
            button.setImage(R.image.login_facebook(), for: .normal)
            button.setTitle("FaceBook", for: .normal)
            button.setTitleColor(R.color.appColor.text_normal(), for: .normal)
            button.titleLabel?.font = UIFont.size10
            button.alignVertical()
        }.layout { (make) in
            make.bottom.equalToSuperview().offset(-25)
            make.centerX.equalToSuperview()
        }
#endif

        if presentingViewController != nil, let accountPasswordArray = AccountInfoManager.shared.accountPassword() {
            accountInputView?.textField.text = accountPasswordArray.first
            passwordInputView?.textField.text = accountPasswordArray.last
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        accountInputView?.resignResponder()
        passwordInputView?.resignResponder()
    }
    
    override func viewModelOutputDrive(output: ViewModelToViewOutput) {
        let loginOutput = output as! LoginOutput
        loginOutput.loginValid.drive(loginButton!.rx.isEnabled).disposed(by: disposeBag)
        loginOutput.loginResult.drive(onNext: { (result) in
            switch result {
            case .success:
                AnalysisManager.trackEvent(AnalysisManager.Event.account_login_suc)
                if self.presentingViewController != nil {
                    AppDelegate.globalServive().dismissViewModel(animated: true, completion: {
                        AccountPageController.isPresented = false
                    })
                }else {
                    AppDelegate.globalServive().popViewModel(animated: true)
                }
            case let .fail(error):
                AnalysisManager.trackEvent(AnalysisManager.Event.login_failed, parameters: ["code" : String(error.rawValue)])
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
        
        loginOutput.thirdLogInResult.drive(onNext: { [unowned self] (result) in
            switch result {
            case .alreadyLogedIn:
                AppDelegate.globalServive().popViewModel(animated: true)
            case let .firstLogIn(userID, token):
                AppDelegate.globalServive().pushViewModel(RegisterConfirmViewModel.self, params: (userID, token, true), animated: true)
            case let .fail(error):
                self.showAlert(withError: error)
            }
        }).disposed(by: disposeBag)
    }
}

struct LoginInput: ViewToViewModelInput {
    
    let accountInput: Driver<String>
    let passwordInput: Driver<String>
    let loginTap: Driver<()>
#if BLOCKY_OVERSEA
    let thirdLoginTap: Driver<ThirdLogInManager>
#endif
    
    init(view: BaseViewController) {
        let loginView = view as! LoginViewController
        
        accountInput = loginView.accountInputView!.textField.rx.text.orEmpty.asDriver()
        passwordInput = loginView.passwordInputView!.textField.rx.text.orEmpty.asDriver()
        loginTap = loginView.loginButton!.rx.tap.asDriver().do(onNext: {
            AnalysisManager.trackEvent(AnalysisManager.Event.click_login)
            loginView.accountInputView!.resignResponder()
            loginView.passwordInputView!.resignResponder()
        })
        
#if BLOCKY_OVERSEA
        thirdLoginTap = loginView.thirdLogInButton!.rx.tap.asDriver().map({
            loginView.thirdLogInManager
        })
#endif
        
    }
}
