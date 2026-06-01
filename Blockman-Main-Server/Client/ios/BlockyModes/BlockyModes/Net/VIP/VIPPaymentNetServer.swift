//
//  VIPPaymentNetServer.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class VIPPaymentNetServer {
    public static func fetchVIPPriceList() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(VIPPayment.priceList(), showToast: false)
    }
    
    public static func pay(vip productID: String) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(VIPPayment.pay(productID))
    }
}
