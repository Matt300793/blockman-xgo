//
//  RechargeEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import HandyJSON
/*
{
    "id": 19,
    "productId": "and.diamond.100",
    "type": "diamonds",
    "price": "$ 99.99",
    "gift": "1300",
    "name": "10000",
    "desc": "10000砖石",
    "diamonds": 6480
}
*/

struct RechargeProductEntity: HandyJSON {
    
    var productId: String!
    var name: String!
    var thumbnail: String!
    var type: String!
    var price: String!
    var gift: String!
    
    init() {
    }
}
