//
//  ProfileViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/17.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ProfileViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return ProfileViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return ProfileOutput.self}
}

struct ProfileOutput: ViewModelToViewOutput {
    let profileResults: Driver<[SectionObject]>
    
    init(viewModel: BaseViewModel) {
        
        let shop = ProfileTableCellEntity(profileIcon: R.image.profile_shop(), profileTitle: R.string.localizable.shop(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let vip = ProfileTableCellEntity(profileIcon: R.image.proflie_vip(), profileTitle: "VIP", profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let topUp = ProfileTableCellEntity(profileIcon: R.image.profile_topup(), profileTitle: R.string.localizable.recharge(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let mailbox = ProfileTableCellEntity(profileIcon: R.image.profile_mailbox(), profileTitle: R.string.localizable.mailbox(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: false, itemHeight: 50)
        
        let setting = ProfileTableCellEntity(profileIcon: R.image.profile_setting(), profileTitle: R.string.localizable.setting(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: false, itemHeight: 50)
        
//        let help = ProfileTableCellEntity(profileIcon: R.image.profile_help(), profileTitle: R.string.localizable.help(), profileDetailTitle: nil, profileDetailImageUrl: nil, showUnderline: false, itemHeight: 50)
        profileResults = AccountStatusManager.shared.statusVariable.asDriver().map { (status) -> [SectionObject] in
            if status == AccountStatusManager.Status.visit {
                return [SectionObject(items: [shop]), SectionObject(items: [setting])]
            }
            return [SectionObject(items: [shop, vip, topUp, mailbox]), SectionObject(items: [setting])]
        }
    }
}
