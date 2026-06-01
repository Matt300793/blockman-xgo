//
//  VIPModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/2/28.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import HandyJSON

struct VIPPrivilegeModel: HandyJSON {
    var thumbnailName: String = ""
    var localizedTitleKey: String = ""
    var enable: Bool = true
    var supportLevel: String = ""
}
