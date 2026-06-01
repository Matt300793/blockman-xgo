//
//  SettingViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class SettingViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return SettingViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return SettingOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("setting", comment: "设置")
    }
}

struct SettingOutput: ViewModelToViewOutput {
    let settingResults: Driver<[SectionObject]>
    
    init(viewModel: BaseViewModel) {
        let accountSecurity = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.account_and_security(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
//        let messageNotify = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.message_notification(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: false, itemHeight: 50)
//
//        let feedback = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.feedback(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
//
//        let checkUpdate = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.check_update(), profileDetailTitle: Driver.just("1.0.0"), profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let aboutMe = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.about_me(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: false, itemHeight: 50)
        if AccountStatusManager.shared.statusVariable.value == .visit {
            settingResults = Driver.just([SectionObject(items: [aboutMe])])
        }else {
            settingResults = Driver.just([SectionObject(items: [accountSecurity, aboutMe])])
        }
    }
}
