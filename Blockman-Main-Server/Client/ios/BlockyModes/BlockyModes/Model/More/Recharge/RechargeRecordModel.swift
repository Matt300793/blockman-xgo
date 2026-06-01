//
//  RechargeRecordModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/17.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

/*
 "created": "string",
 "currency": 0,              // 货币类型, 1: 表示砖石；2: 表示金币
 "description": "string",
 "inoutType": 0,            // 消耗/获取类型，0，表示获取；1，表示消耗
 "orderId": "string",
 "qty": 0,                      // 货币数
 "status": 0,                 // 交易状态，0,表示已付款；1，表示成功；2，表示失败
 "transactionType": 0, // 交易类型，如1，表示苹果支付；2，表示苹果退款；3，表示购买装饰; 4,表示退款返现
 "userId": 0
 */

class RechargeRecordModel: BaseModel {

    var created: String?
    var currency = 0
    var description: String?
    var inoutType = 0
    var orderId: String?
    var qty = 0
    var status = 0
    var transactionType = 0
    var userId = 0
}
