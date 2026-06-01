//
//  VIPEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/28.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

struct VIPPrivilegeEntity: ItemEntityConfigurable {
    let thumbnailName: String
    let thumbnailURLString: String
    let title: String
    let supportLevel: String
    let enable: Bool
    
    init(model: VIPPrivilegeModel) {
        if model.enable {
            thumbnailName = "ic_vip_" + model.thumbnailName + "_nor"
        }else {
            thumbnailName = "ic_vip_" + model.thumbnailName + "_enable"
        }
        thumbnailURLString = "http://static.sandboxol.com/sandbox/images/vip/" + model.thumbnailName + ".png"
        title = NSLocalizedString("vip_" + model.localizedTitleKey, comment: "")
        supportLevel = model.supportLevel
        enable = model.enable
    }
}
