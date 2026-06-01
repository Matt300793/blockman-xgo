//
//  DecorationAPI.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/4.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

let decorationPathPrefix = "/decoration"

enum Decoration {
    case fetchDecorationsWithCategory(Int) // 获取用户拥有的不同种类的装饰
    case fetchVIPDecorationsWithCategory(Int) // 获取VIP不同种类的装饰
    case fetchCurrentUsingDecorations() // 获取正在使用的装扮信息
    case updateUsingDecoration(Int) // 更新或增加用户正在使用得装扮信息
    case deleteUsingDecoration(Int) // 删除用户正在使用得装扮信息
}

extension Decoration : TargetType {
    var baseURL: URL {
        return URL.init(string: serverHost)!
    }
    
    var path: String {
        switch self {
        case .fetchCurrentUsingDecorations:
            return "\(decorationPathPrefix)/api/v1/decorations/using"
        case let .fetchDecorationsWithCategory(category):
            return "\(decorationPathPrefix)/api/v1/decorations/\(category)"
        case let .fetchVIPDecorationsWithCategory(category):
            return "\(decorationPathPrefix)/api/v1/vip/decorations/users/\(category)"
        case let .updateUsingDecoration(decorationID):
            return "\(decorationPathPrefix)/api/v1/decorations/using/\(decorationID)"
        case let .deleteUsingDecoration(decorationID):
            return "\(decorationPathPrefix)/api/v1/decorations/using/\(decorationID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updateUsingDecoration(_):
            return .put
        case .deleteUsingDecoration(_):
            return .delete
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchDecorationsWithCategory(_), .fetchVIPDecorationsWithCategory(_):
            return .requestParameters(parameters: ["os" : "ios"], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
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
