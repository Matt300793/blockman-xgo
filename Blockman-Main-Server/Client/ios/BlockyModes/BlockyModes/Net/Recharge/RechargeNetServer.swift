//
//  RechargeNetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class RechargeNetServer {
    
    class func verify(transactionID: String, receiptString: String) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Recharge.verify(transactionID, receiptString), showToast: false)
//                   .retryWhen({ (error: Observable<BlockyError>) -> Observable<Int> in
//                        return error.flatMapWithIndex({ (error, index) -> Observable<Int> in
//                            guard index < 3 else {
//                                return Observable.error(error)
//                            }
//                        return Observable<Int>.timer(3, scheduler: MainScheduler.instance)
//                     })
//                 })
    }
    
    class func fetchProperty() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Recharge.fetchProperty(), showToast: false)
    }
    
    class func fetchRecords(page: Int) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Recharge.fetchRecords(page), showToast: false)  
    }
}
