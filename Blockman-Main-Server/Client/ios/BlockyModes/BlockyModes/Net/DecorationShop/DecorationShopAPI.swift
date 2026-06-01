//
//  DecorationShopAPI.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/10.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

let decorationShopPathPrefix = "/shop"

enum DecorationShop {
    case fetchDecorations(Int, Int, Int)  // 获取对应的装饰，第一个参数为装饰类型typeID，第二个为价格类型(0: 所有类型 1: 钻石 2:金币), 第三个参数page
    case purchaseDecoration([Int]) // 购买装饰
}

extension DecorationShop: TargetType {
    
    var baseURL: URL {
        return URL.init(string: serverHost)!
    }
    
    var path: String {
        switch self {
        case let .fetchDecorations(typeID, _, _):
            return "\(decorationShopPathPrefix)/api/v1/shop/decorations/pages/\(typeID)"
        case .purchaseDecoration(_):
            return "\(decorationShopPathPrefix)/api/v1/shop/decorations/buy"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchDecorations(_, _, _):
            return .get
        default:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case let .fetchDecorations(_, currency, page):
            return .requestParameters(parameters: ["currency" : currency, "pageNo" : page, "pageSize" : 20], encoding: URLEncoding.queryString)
        case .purchaseDecoration(let decorations):
//            return .requestPlain
            return .requestParameters(parameters: ["decorationId" : decorations], encoding: URLQueryArrayEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        var header: [String : String] = [:]
        header["userId"] = AccountInfoManager.shared.userId.value
        header["Access-Token"] = AccountInfoManager.shared.token.value
        header["language"] = Locale.current.identifier
        return header
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
}

