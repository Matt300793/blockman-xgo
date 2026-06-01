//
//  VIPPaymentEntity.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

struct VIPEntity: ItemEntityConfigurable {
    
    let itemHeight: CGFloat = 65
    
    let productID: String
    let productName: String
    let price: String
    let payTypeText: String
    
    init(model: VIPModel) {
        productID = model.productId
        productName = "\(model.months)" + " " + R.string.localizable.month()
        price = "\(model.price)"
        payTypeText = AccountInfoManager.shared.vip.value < model.level ? R.string.localizable.vip_pay_renew_vip() : R.string.localizable.vip_pay_open_vip() 
    }
}
