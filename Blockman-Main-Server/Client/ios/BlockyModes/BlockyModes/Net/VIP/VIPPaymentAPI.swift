//
//  VIPPaymentAPI.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2018/3/1.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

let vipPaymentPathPrefix = "/shop"

enum VIPPayment {
    case priceList()
    case pay(String)
}

extension VIPPayment: TargetType {
    var baseURL: URL {
        return URL.init(string: serverHost)!
    }
    
    var path: String {
        switch self {
        case .priceList():
            return "\(vipPaymentPathPrefix)/api/v1/shop/users/vip"
        default:
            return "\(vipPaymentPathPrefix)/api/v1/shop/user/buy/vip"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .priceList():
            return .get
        default:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .priceList():
            return .requestPlain
        case let .pay(vip):
            return .requestParameters(parameters: ["productId" : vip], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        var header: [String : String] = [:]
        header["userId"] = AccountInfoManager.shared.userId.value
        header["Access-Token"] = AccountInfoManager.shared.token.value
        header["language"] = Locale.current.identifier
        return header
    }
}
