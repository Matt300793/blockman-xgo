//
//  RechargeRecordEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/17.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

struct RechargeRecordEntity: ItemEntityConfigurable {

    let title: String
    let sourceFrom: String
    let createdTime: String
    let status: String
    let itemHeight: CGFloat
    
    init(recordModel: RechargeRecordModel) {
        let currency = recordModel.currency == 1 ? NSLocalizedString("recharge_diamond", comment: "魔方") : NSLocalizedString("recharge_gold", comment: "金币")
        let inOrOut = recordModel.inoutType == 0 ? "+" : "-"
        title = inOrOut + String(recordModel.qty) + " " + currency
        createdTime = recordModel.created ?? ""
        itemHeight = 60
        switch recordModel.status {
        case 1:
            status = NSLocalizedString("common_success", comment: "成功")
        default:
            status = NSLocalizedString("common_fail", comment: "失败")
        }
        
        switch recordModel.transactionType {
        case 1:
            sourceFrom = R.string.localizable.recharge_record_google_pay()
        case 2:
            sourceFrom = R.string.localizable.recharge_record_google_refund()
        case 3:
            sourceFrom = R.string.localizable.recharge_record_buy_decoration()
        case 4:
            sourceFrom = R.string.localizable.recharge_record_recycle_decoration()
        case 5:
            sourceFrom = R.string.localizable.recharge_record_game_buy_props()
        case 6:
            sourceFrom = R.string.localizable.recharge_record_purchase_fail_refund()
        case 7:
            sourceFrom = R.string.localizable.recharge_record_third_pay()
        case 8:
            sourceFrom = R.string.localizable.recharge_record_third_refund()
        case 9:
            sourceFrom = R.string.localizable.recharge_record_apple_pay()
        case 10:
            sourceFrom = R.string.localizable.recharge_record_fetch_from_game()
        default:
            sourceFrom = ""
        }
    }
}
