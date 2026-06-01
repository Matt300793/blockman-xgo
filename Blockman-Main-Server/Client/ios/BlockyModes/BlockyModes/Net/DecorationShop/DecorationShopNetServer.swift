//
//  DecorationShopNetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/10.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class DecorationShopNetServer {
    
    class func fetchDecorations(typeID: Int, currency: Int, inPage page : Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(DecorationShop.fetchDecorations(typeID, currency, page), showToast: false)
    }
    
    class func purchase(decorationIDs: [Int]) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(DecorationShop.purchaseDecoration(decorationIDs))
    }
}
