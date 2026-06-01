//
//  ProfileModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/22.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class ProfileModel: BaseModel {

    var profileIcon: UIImage?
    var profileTitle: String?
    var profileDetailImageUrl: Driver<String>?
    var profileDetailTitle: Driver<String>?
    var profileIsShowUnderline: Bool?
    var profileIsShowDetailImage: Bool?
}
