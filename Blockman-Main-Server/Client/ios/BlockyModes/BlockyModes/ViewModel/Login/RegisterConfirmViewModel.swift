//
//  RegisterConfirmViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/19.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import HandyJSON

class RegisterConfirmViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return RegisterConfirmViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return RegisterConfirmOutput.self}
    
    fileprivate var uid: String
    fileprivate var token: String
    fileprivate let loginFromThird: Bool
    
    required init(viewInput: ViewToViewModelInput) {
        let confirmInput = viewInput as! RegisterConfirmInput
        uid = confirmInput.uidToken.0
        token = confirmInput.uidToken.1
        loginFromThird = confirmInput.uidToken.2
        super.init(viewInput: viewInput)
    }
}

struct RegisterConfirmOutput: ViewModelToViewOutput {
    
    let nicknameValid: Driver<Bool>
    let registerConfirmResult: Driver<BlockyResult>
    let uploadResult: Driver<Bool>
    
    init(viewModel: BaseViewModel) {
        var portraitUrl = ""
        let registerConfirmViewModel = viewModel as! RegisterConfirmViewModel
        let registerConfirmInput = registerConfirmViewModel.viewInput as! RegisterConfirmInput
        
        let imageName = "UserIcon" + String(registerConfirmViewModel.uid)
        
        // 上传头像
        uploadResult = registerConfirmInput.uploadImageInput.flatMap {
            UserNetServer.uploadImage(filePath: $0, fileName: imageName, uid: registerConfirmViewModel.uid, token: registerConfirmViewModel.token).map({ response -> Bool in
                portraitUrl = response["data"] as! String
                return true
            }).asDriver(onErrorJustReturn: false)
        }
        
        nicknameValid = registerConfirmInput.nicknameInput.map { _ in
//            VerifyServer.verify(account: $0).isValid
            return true
        }
        
        let info = Driver.combineLatest(registerConfirmInput.nicknameInput, registerConfirmInput.genderInput) {
            ($0, $1)
        }
        
        registerConfirmResult = registerConfirmInput.doneTap.withLatestFrom(info).flatMapLatest { (info) in
            UserNetServer.registerInfo(nickname: info.0, picUrl: portraitUrl, gender: info.1, uid: registerConfirmViewModel.uid, token: registerConfirmViewModel.token).mapModel(type: UserInfoModel.self).map({ (userInfo) -> BlockyResult in
                userInfo.accessToken = registerConfirmViewModel.token
                userInfo.loginFromThird = registerConfirmViewModel.loginFromThird
                AccountInfoManager.shared.storeUserInfo(userInfo)
                AccountStatusManager.shared.logIn()
                return .success
            }).asDriver(onErrorRecover: { (error) -> SharedSequence<DriverSharingStrategy, BlockyResult> in
                return Driver.just(.fail(error as! BlockyError))
            })
        }
    }
}
