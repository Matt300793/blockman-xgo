//
//  DecorationModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/1/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
/*
"details": "string",
"expire": 0, 默认为0，表示该装饰永不过期；-1，表示该装饰已过期；单位为天，如30，表示改装饰30天后过期
"iconUrl": "string",
"id": 0,
"name": "string",
"resourceId": "string",
"sex": 0, 默认为0，表示男女通用；1，表示男性专用；2，表示女性专用
"status": 0, 默认为0，表示当前未使用；1，表示当前正在使用该装扮
"tag": [
"string"
],
"typeId": 0
*/

class DecorationModel: BaseModel {
    var details: String = ""
    var expire: Int = 0
    var iconUrl: String = ""
    var id: Int = 0
    var name: String = ""
    var resourceId: String = ""
    var sex: Int = 0
    var status: Int = 0
    var tag: [String] = []
    var typeId: Int = 0
    
    static var defaultVIPCrown: DecorationModel {
        get {
            let crown = DecorationModel()
            crown.resourceId = "default_vip_crown"
            crown.iconUrl = "http://static.sandboxol.com/sandbox/images/crown/no_vip_crown.png"
            return crown
        }
    }
    
    static var defaultVIPCrownResourceID: String {
        get {
            return "default_vip_crown"
        }
    }
}
