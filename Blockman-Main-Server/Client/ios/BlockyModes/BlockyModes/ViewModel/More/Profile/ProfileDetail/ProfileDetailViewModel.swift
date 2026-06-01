//
//  ProfileDetailViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/23.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class ProfileDetailViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return ProfileDetailViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return ProfileDetailOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("title_profile_detail", comment: "个人信息")
    }
}


struct ProfileDetailOutput: ViewModelToViewOutput {
    let profileDetailResults: Driver<[SectionObject]>
    let genderPickResult: Driver<BlockyResult>
    let birthdayPickResult: Driver<BlockyResult>
    let portraitUploadResult: Driver<Bool>
    
    init(viewModel: BaseViewModel) {
        let profileDetailViewModel = viewModel as! ProfileDetailViewModel
        let profileDetailInput = profileDetailViewModel.viewInput as! ProfileDetailInput
        
        let portrait = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.nickname(), profileDetailTitle: nil, profileDetailImageUrl: AccountInfoManager.shared.portraiUrl.asDriver(), showUnderline: true, itemHeight: 80)
        
        let nickName = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.nickname(), profileDetailTitle: AccountInfoManager.shared.nickname.asDriver(), profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let genderDriver = AccountInfoManager.shared.gender.asDriver().map({
            $0 == AccountInfoManager.Gender.male ? NSLocalizedString("male", comment: "男") : NSLocalizedString("female", comment: "女")
        })
        let gender = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.gender(), profileDetailTitle: genderDriver, profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let birthday = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.birthday(), profileDetailTitle: AccountInfoManager.shared.birthDay.asDriver(), profileDetailImageUrl: nil, showUnderline: true, itemHeight: 50)
        
        let intrudoction = ProfileTableCellEntity(profileIcon: nil, profileTitle: R.string.localizable.introduction(), profileDetailTitle: AccountInfoManager.shared.introduction.asDriver(), profileDetailImageUrl: nil, showUnderline: false, itemHeight: 50)
        
        profileDetailResults = Driver.just([SectionObject(items: [portrait]), SectionObject(items: [nickName, gender, birthday, intrudoction])])
        
        
        genderPickResult = profileDetailInput.genderInput.flatMap {
            UserNetServer.modifyGender($0).map({ (response) -> BlockyResult in
                AccountInfoManager.shared.updateUserInfo(response["data"] as! [String : Any])
                return .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        }
        
        birthdayPickResult = profileDetailInput.birthdayInput.flatMap({
            UserNetServer.modifyBirthday($0).map({ (response) -> BlockyResult in
                AccountInfoManager.shared.updateUserInfo(response["data"] as! [String : Any])
                return .success
            }).asDriver(onErrorRecover: {
                Driver.just(.fail($0 as! BlockyError))
            })
        })
        
        portraitUploadResult = profileDetailInput.picFilePathInput.flatMap {
            UserNetServer.uploadImage(filePath: $0, fileName: ("UserIcon" + AccountInfoManager.shared.userId.value), uid: AccountInfoManager.shared.userId.value, token: AccountInfoManager.shared.token.value).map({ (response) -> String? in
                return response["data"] as? String
            })
            .asDriver(onErrorJustReturn: nil)
            .filter({
                $0 != nil
            })
            .flatMap({ picURLString in
                UserNetServer.modifyPortrait(picURLString!).map({ (response) -> Bool in
                    AccountInfoManager.shared.updateUserInfo(response["data"] as! [String : Any])
                    return true
                }).asDriver(onErrorJustReturn: false)
            })
        }
    }
}

