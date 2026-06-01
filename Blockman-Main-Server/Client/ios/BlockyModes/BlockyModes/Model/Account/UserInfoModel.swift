//
//  UserInfoModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/21.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

class UserInfoModel: BaseModel {

#if arch(arm64)
    var userId: Int64 = 0
#else
    var userId: Int32 = 0
#endif
    var sex: Int = 1
    var nickName: String = ""
    var picUrl: String = ""
    var account: String = ""
    var password: String = ""
    var accessToken: String = ""
    var birthday: String = ""
    var details: String = ""
    var telephone: String = ""
    var email: String = ""
    var vip: Int = 0
    var expireDate: String = ""
    var loginFromThird: Bool = false
}
