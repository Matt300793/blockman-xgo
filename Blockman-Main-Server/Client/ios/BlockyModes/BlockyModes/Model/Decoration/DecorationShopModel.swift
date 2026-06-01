//
//  DecorationShopModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/10.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
/*
"currency": 0,
"details": "string",
"expire": 0,
"hasPurchase": 0,
"iconUrl": "string",
"id": 0,
"isNew": 0,
"name": "string",
"price": 0,
"quantity": 0,
"resourceId": "string",
"sex": 0,
"tag": [
"string"
],
"typeId": 0
*/

class DecorationShopModel: BaseModel {
    
    var currency: Int = 0
    var details: String?
    var expire: Int = 0
    var hasPurchase: Int = 0
    var iconUrl: String?
    var id: Int = 0
    var isNew: Int = 0
    var name: String?
    var price: Int = 0
    var quantity: Int = 0
    var resourceId: String?
    var sex: Int = 1
    var tag: [String]?
    var typeId: Int = 0
}
