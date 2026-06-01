//
//  ConfigurationAPI.swift
//  BlockyModes
//
//  Created by KiBen on 2017/12/28.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

enum Configuration {
    case checkAppUpdate
    case fetchAppUpdateInfo
}

extension Configuration: TargetType {
    
    var baseURL: URL {
        switch self {
        case .checkAppUpdate:
            return URL.init(string: "http://itunes.apple.com")!
        case .fetchAppUpdateInfo:
            return URL.init(string: "http://ols.sandboxol.com")!
        }
    }
    
    var path: String {
        switch self {
        case .checkAppUpdate:
#if BLOCKY_OVERSEA
            return "/lookup"
#else
            return "/cn/lookup"
#endif
        case .fetchAppUpdateInfo:
            return "/api/v1/config/ios-blockmods-version-config"
        }
    }
    
    var task: Task {
        switch self {
        case .checkAppUpdate:
            return .requestParameters(parameters: ["id" : 1335948169], encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        return nil
    }
}
