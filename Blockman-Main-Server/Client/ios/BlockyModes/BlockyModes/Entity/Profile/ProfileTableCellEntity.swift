//
//  ProfileTableCellEntity.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/22.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

struct ProfileTableCellEntity: ItemEntityConfigurable {

    var profileIcon: UIImage?
    var profileTitle: String
    var profileDetailTitle: Driver<String>?
    var profileDetailImageUrl: Driver<String>?
    var profileIsShowDetailImage: Bool
    var profileIsShowDetailTitle: Bool
    var profileIsShowIconView: Bool
    var profileIsShowUnderline: Bool
    var profileIsFillShowUnderline: Bool
    
    var itemHeight: CGFloat
    
    init(profileIcon: UIImage?, profileTitle: String, profileDetailTitle: Driver<String>?, profileDetailImageUrl: Driver<String>?, showUnderline: Bool, itemHeight: CGFloat) {
        self.profileIcon = profileIcon
        self.profileTitle = profileTitle
        self.profileDetailTitle = profileDetailTitle
        self.profileDetailImageUrl = profileDetailImageUrl
        self.itemHeight = itemHeight
        
        profileIsShowIconView = profileIcon != nil
        profileIsShowDetailImage = profileDetailImageUrl != nil
        profileIsShowDetailTitle = profileDetailTitle != nil
        profileIsShowUnderline = showUnderline
        profileIsFillShowUnderline = profileIcon == nil
        
    }
}
