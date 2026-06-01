//
//  DecorationShopEntity.swift
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

struct DecorationShopEntity: Equatable, DecorationEntityProtocol {
    static func ==(lhs: DecorationShopEntity, rhs: DecorationShopEntity) -> Bool {
        return lhs.resourceID == rhs.resourceID
    }
    
    static func !=(lhs: DecorationShopEntity, rhs: DecorationShopEntity) -> Bool {
        return lhs.resourceID != rhs.resourceID
    }
    
    enum PriceType: Int {
        case diamond = 1
        case gold = 2
    }
    
    let hasPurchased: Bool
    let isNew: Bool
    let isLimited: Bool
    let price: String
    let priceType: PriceType // 装饰价格币种
    let thumbnailURLString: String
    let resourceID: String
    let typeID: Int
    let id: Int
    let name: String
    let remainQuantityString: String
    
    init(decorationShopModel model: DecorationShopModel) {
        
        id = model.id
        name = model.name ?? "--"
        resourceID = model.resourceId ?? ""
        typeID = model.typeId
        hasPurchased = model.hasPurchase == 1
        isNew = model.isNew == 1
        thumbnailURLString = model.iconUrl ?? ""
        isLimited = model.quantity != 0
        remainQuantityString = model.quantity == 0 ? "" : String(format: NSLocalizedString("decoration_remain_quantity", comment: "剩余数量: %s"), String(model.quantity))
        switch model.currency {
        case 0:
            fallthrough
        case 1:
            priceType = PriceType.diamond
        default:
            priceType = PriceType.gold
        }
        price = String(model.price)
    }
}



