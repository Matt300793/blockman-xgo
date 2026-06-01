//
//  ModifyIntroductionViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class ModifyIntroductionViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return ModifyIntroductionViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return ModifyIntroductionOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("introduction", comment: "个人简介")
    }
}

struct ModifyIntroductionOutput: ViewModelToViewOutput {
    let modifyValid: Driver<Bool>
    let modifyResult: Driver<Bool>
    
    init(viewModel: BaseViewModel) {
        let modifyIntroductionViewModel = viewModel as! ModifyIntroductionViewModel
        let modifyIntroductionInput = modifyIntroductionViewModel.viewInput as! ModifyIntroductionInput
        
        modifyValid = modifyIntroductionInput.textViewInput.map {
            $0.count < 30
        }
        
        modifyResult = modifyIntroductionInput.doneTap.withLatestFrom(modifyIntroductionInput.textViewInput).flatMap {
            UserNetServer.modifyIntroduction($0).map({ (response) -> Bool in
                AccountInfoManager.shared.updateUserInfo(response["data"] as! [String : Any])
                return true
            }).asDriver(onErrorJustReturn: false)
        }
    }
}
