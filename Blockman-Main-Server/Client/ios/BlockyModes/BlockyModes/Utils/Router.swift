//
//  Router.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/16.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

struct Router {
#if BLOCKY_OVERSEA
    private let projectName = "BlockyModes_Oversea."
#else
    private let projectName = "BlockyModes."
#endif
    
    fileprivate var viewModelToViewMaps: [String : String] {
        return [projectName + "HomePageViewModel" : projectName + "HomePageViewController",
                    projectName + "AccountPageViewModel" : projectName + "AccountPageController",
                    projectName + "LoginViewModel" : projectName + "LoginViewController",
                    projectName + "RegisterViewModel" : projectName + "RegisterViewController",
                    projectName + "RegisterConfirmViewModel" : projectName + "RegisterConfirmViewController",
                    projectName + "ShopViewModel" : projectName + "ShopViewController",
                    projectName + "ProfileDetailViewModel" : projectName + "ProfileDetailViewController",
                    projectName + "SettingViewModel" : projectName + "SettingViewController",
                    projectName + "ModifyNickNameViewModel" : projectName + "ModifyNickNameViewController",
                    projectName + "ModifyIntroductionViewModel" : projectName + "ModifyIntroductionViewController",
                    projectName + "ModifyPasswordViewModel" : projectName + "ModifyPasswordViewController",
                    projectName + "AccountSecurityViewModel" : projectName + "AccountSecurityViewController",
                    projectName + "BindPhoneViewModel" : projectName + "BindPhoneViewController",
                    projectName + "UnbindPhoneViewModel" : projectName + "UnbindPhoneViewController",
                    projectName + "GameDetailViewModel" : projectName + "GameDetailViewController",
                    projectName + "ResetPasswordViewModel" : projectName + "ResetPasswordViewController",
                    projectName + "BindEmailViewModel" : projectName + "BindEmailViewController",
                    projectName + "DecorationShopViewModel" : projectName + "DecorationShopViewController",
                    projectName + "DecorationShoppingCartViewModel" : projectName + "DecorationShoppingCartViewController",
                    projectName + "RechargeViewModel" : projectName + "RechargeViewController",
                    projectName + "RechargeRecordViewModel" : projectName + "RechargeRecordViewController"]
    }
    
    static func viewController(of viewModel: BaseViewModel.Type) -> BaseViewController {
        return viewModel.mappedController.init(viewModelType: viewModel)
    }
}

extension Router {
    
}
