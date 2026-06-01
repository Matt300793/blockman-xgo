//
//  VIPPaymentModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import HandyJSON

/*
"productId": "and.vip.1.1",
"currency": 1,
"level": 1,
"price": 60,
"months": 1
 */

struct VIPModel: HandyJSON {
    var productId: String = ""
    var currency: Int = 1
    var level: Int = 1
    var price: Int = 0
    var months: Int = 1
}
