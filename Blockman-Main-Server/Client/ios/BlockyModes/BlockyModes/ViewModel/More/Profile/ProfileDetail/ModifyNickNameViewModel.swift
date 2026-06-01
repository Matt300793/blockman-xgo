//
//  ModifyNickNameViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class ModifyNickNameViewModel: BaseViewModel {

    override class var mappedController: BaseViewController.Type {return ModifyNickNameViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return ModifyNickNameOutput.self}
    
}

struct ModifyNickNameOutput: ViewModelToViewOutput {
    
    let newNicknameValid: Driver<Bool>
//    let modifyResult: Driver<ResponseCode>
    
    init(viewModel: BaseViewModel) {
        let modifyNicknameViewModel = viewModel as! ModifyNickNameViewModel
        let input = modifyNicknameViewModel.viewInput as! ModifyNickNameInput
        
        newNicknameValid = input.nicknameInput.throttle(0.5).distinctUntilChanged().map({
            $0.count >= 6 && $0 != AccountInfoManager.shared.nickname.value
        })
        
//        modifyResult = input.doneTap.withLatestFrom(input.nicknameInput).flatMapLatest {
//            UserNetServer.modifyNickname($0).asDriver(onErrorJustReturn: .failed)
//        }.map { (responseResult) -> ResponseCode in
//            switch responseResult {
//            case let .successful(response):
//                return response.code ?? .fail
//            case .failed:
//                return .fail
//            }
//        }
    }
}
