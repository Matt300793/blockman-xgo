//
//  LoginViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/18.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: BaseViewModel {
    
    override class var mappedController: BaseViewController.Type {return LoginViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {
        return LoginOutput.self
    }
    
}

struct LoginOutput: ViewModelToViewOutput {
    
    let loginValid: Driver<Bool>
    let loginResult: Driver<BlockyResult>
    let thirdLogInResult: Driver<ThirdLogInManager.Result>
    
    init(viewModel: BaseViewModel) {
        let loginViewModel = viewModel as! LoginViewModel
        let loginInput = loginViewModel.viewInput as! LoginInput
        
        let accountValid = loginInput.accountInput.distinctUntilChanged().map {
            VerifyServer.verify(account: $0)
        }
        
        let passwordValid = loginInput.passwordInput.distinctUntilChanged().map {
            VerifyServer.verify(password: $0, doublePassword: nil)
        }
        
        loginValid = Driver.combineLatest(accountValid, passwordValid, resultSelector: { (account, password) -> Bool in
            switch (account, password) {
            case (.successful, .successful) :
                return true
            default:
                return false
            }
        })
        
        let accountAndPassword = Driver.combineLatest(loginInput.accountInput, loginInput.passwordInput) {
            ($0, $1)
        }
        loginResult = loginInput.loginTap.withLatestFrom(accountAndPassword).flatMapLatest({
            UserNetServer.login(account: $0.0, password: $0.1).mapModel(type: UserInfoModel.self).map({ userInfo -> BlockyResult in
                AccountInfoManager.shared.storeUserInfo(userInfo)
                AccountStatusManager.shared.logIn() // 设置为登录状态
                return .success
            }).asDriver(onErrorRecover: { error -> SharedSequence<DriverSharingStrategy, BlockyResult> in
                return Driver.just(.fail(error as! BlockyError))
            })
        })
        
#if BLOCKY_OVERSEA
        thirdLogInResult = loginInput.thirdLoginTap.flatMap { thirdLogInManager in
            thirdLogInManager.logInByFaceBook().asDriver(onErrorJustReturn: ("", ""))
        }.filter({
            let (userID, token) = $0
            if userID.isEmpty || token.isEmpty {
                BlockyHUD.showText(R.string.localizable.common_request_fail_retry(), inView: AppDelegate.keyWindow())
                return false
            }
            return true
        }).flatMap { tuple in
            let (userID, token) = tuple
            return UserNetServer.login(account: userID, password: token, channel: .facebook).mapModel(type: UserInfoModel.self)
                .map({ (userInfo) -> ThirdLogInManager.Result in
                    if userInfo.nickName.isEmpty { // 第一次第三方登录，只有userid跟token有值，其他均为默认值
                        return .firstLogIn(String(userInfo.userId), userInfo.accessToken)
                    }
                    userInfo.loginFromThird = true
                    AccountInfoManager.shared.storeUserInfo(userInfo)
                    AccountStatusManager.shared.logIn() // 设置为登录状态
                    return .alreadyLogedIn
                }).asDriver(onErrorRecover: { (error) -> SharedSequence<DriverSharingStrategy, ThirdLogInManager.Result> in
                    return Driver.just(.fail(error as! BlockyError))
                })
        }
#endif
    }
}
