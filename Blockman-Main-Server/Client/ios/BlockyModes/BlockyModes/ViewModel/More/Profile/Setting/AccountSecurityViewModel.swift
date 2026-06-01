//
//  AccountSecurityViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/24.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class AccountSecurityViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return AccountSecurityViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return AccountSecurityOutput.self}
    
    override func initialize() {
        viewTitle.value = R.string.localizable.account_and_security()
    }
}

struct AccountSecurityOutput: ViewModelToViewOutput {
    let accountSecurityResults: Driver<SectionObject>
    
    init(viewModel: BaseViewModel) {
        
        let modifyPassword = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.modify_password(), profileDetailTitle: Driver.just(NSLocalizedString("tap_to_modify", comment: "点击修改")), profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let email = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.mail(), profileDetailTitle: AccountInfoManager.shared.email.asDriver(), profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
#if BLOCKY_OVERSEA
        let sectionRowEntities = AccountInfoManager.shared.loginFromThird.value ? [email] : [modifyPassword, email]
#else
        let telPhone = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.phone_number(), profileDetailTitle: AccountInfoManager.shared.phone.asDriver(), profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
            
        let sectionRowEntities = [modifyPassword, telPhone]
#endif
        accountSecurityResults = Driver.just(SectionObject(items: sectionRowEntities))
    }
}
