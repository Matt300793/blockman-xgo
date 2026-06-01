//
//  RechargeAPI.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/16.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

let rechargePathPrefix = "/pay"

enum Recharge {
    case verify(String, String) // 校验订单
    case fetchRecords(Int) // 消耗记录
    case fetchProperty() // 获取当前用户财产
}

extension Recharge: TargetType {
    
    var baseURL: URL {
        return URL.init(string: serverHost)!
    }
    
    var path: String {
        switch self {
        case .verify(_, _):
            return "\(rechargePathPrefix)/api/v1/pay/ios/verify-receipt"
        case .fetchRecords(_):
            return "\(rechargePathPrefix)/api/v1/wealth/record/users/\(AccountInfoManager.shared.userId.value)"
        case .fetchProperty():
            return "\(rechargePathPrefix)/api/v1/wealth/user"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .verify(_, _):
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .verify(let transactionID, let receipt):
            return .requestParameters(parameters: ["receiptData" : receipt, "transactionId" : transactionID], encoding: JSONEncoding.default)
        case .fetchProperty():
            return .requestPlain
        case let .fetchRecords(page):
            return .requestParameters(parameters: ["pageNo" : page, "pageSize" : 20], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        var header: [String : String] = [:]
        header["userId"] = AccountInfoManager.shared.userId.value
        header["Access-Token"] = AccountInfoManager.shared.token.value
        return header
    }
}
