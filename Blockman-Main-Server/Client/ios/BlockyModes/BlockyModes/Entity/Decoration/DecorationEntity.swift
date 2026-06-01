//
//  DecorationEntity.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/1/5.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

struct DecorationEntity: Equatable, DecorationEntityProtocol {
    
    static func ==(lhs: DecorationEntity, rhs: DecorationEntity) -> Bool {
        return lhs.resourceID == rhs.resourceID
    }
    
    static func !=(lhs: DecorationEntity, rhs: DecorationEntity) -> Bool {
        return lhs.resourceID != rhs.resourceID
    }
    
    enum Validity {
        case forever // 永久有效
        case expired // 已过期
        case willBeExpired // 将过期
    }
    
    let isLimited: Bool
    var isUsing: Bool
    var validity: Validity // 装饰有效性
    let thumbnailURLString: String
    let expireDayString: String?
    let resourceID: String
    let typeID: Int
    let id: Int
    let gender: Int //默认为0，表示男女通用；1，表示男性专用；2，表示女性专用
    
    init(decorationModel model: DecorationModel) {
        
        id = model.id
        gender = model.sex
        resourceID = model.resourceId
        typeID = model.typeId
        isLimited = model.status == 1
        isUsing = model.status == 1
        thumbnailURLString = model.iconUrl
        switch model.expire {
        case 0:
            validity = Validity.forever
            expireDayString = nil
        case -1:
            validity = Validity.expired
            expireDayString = "已过期"
        default:
            validity = Validity.willBeExpired
            expireDayString = "还有\(model.expire)天过期"
        }
    }
    
    static var defaultVIPCrown: DecorationEntity {
        get {
            return DecorationEntity(decorationModel: DecorationModel.defaultVIPCrown)
        }
    }
    
    static var defaultVIPCrownResourceID: String {
        get {
            return DecorationModel.defaultVIPCrownResourceID
        }
    }
}

