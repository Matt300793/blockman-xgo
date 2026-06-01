//
//  GamesAPI.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/2.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

let gamePathPrefix = "/game"

enum Games {
    case recommendationList // 推荐
    case recentlyPlayingList // 最近在玩
    case friendsPlayingList // 好友在玩
    case gameDetailInfo(String) // 游戏详情信息
    case appreciate(String) // 点赞
    case categoryList(Int, String, Int) // 分类列表
    case fetchEnterGameToken(String)
    case enterGame(String)
}

extension Games: TargetType {
    var baseURL: URL {
        switch self {
        case .enterGame(_):
            #if DEBUG
                return URL.init(string: "http://v3.game.sandboxol.com:9902" /*http://120.92.133.131:9902"*/)!
            #else
                return URL.init(string: "http://v3.game.sandboxol.com:9902")!
            #endif
        default:
            return URL.init(string: serverHost)!
        }
    }
    
    var path: String {
        switch self {
        case .recommendationList:
            return "\(gamePathPrefix)/api/\(apiVersion)/games/recommendation"
        case .recentlyPlayingList:
            return "\(gamePathPrefix)/api/\(apiVersion)/games/playlist/recently"
        case .friendsPlayingList:
            return "\(gamePathPrefix)/api/\(apiVersion)/games/playlist/friends"
        case let .gameDetailInfo(gameId):
            return "\(gamePathPrefix)/api/\(apiVersion)/games/\(gameId)"
        case let .appreciate(gameId):
            return "\(gamePathPrefix)/api/\(apiVersion)/games/\(gameId)/appreciation"
        case .categoryList(_, _, _):
            return "\(gamePathPrefix)/api/\(apiVersion)/games"
        case .fetchEnterGameToken(_):
            return "\(gamePathPrefix)/api/\(apiVersion)/game/auth"
        case .enterGame(_):
            return "/v1/dispatch"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .appreciate:
            return .put
        case .enterGame(_):
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .categoryList(category, sort, page):
            return .requestParameters(parameters: ["typeId" : category, "orderType" : sort, "pageNo" : page, "pageSize" : 20], encoding: URLEncoding.queryString)
        case let .fetchEnterGameToken(gameType):
            return .requestParameters(parameters: ["typeId" : gameType], encoding: URLEncoding.queryString)
        case .enterGame(_):
            return .requestParameters(parameters: ["clz" : 0, "rid" : 1001, "name" : AccountInfoManager.shared.nickname.value, "pioneer" : true, "ever" : GameEngineInfo.version], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        var header: [String : String] = [:]
        switch self{
        case let .enterGame(token):
            header["x-shahe-uid"] = AccountInfoManager.shared.userId.value
            header["x-shahe-token"] = token
        default:
            header["userId"] = AccountInfoManager.shared.userId.value
            header["Access-Token"] = AccountInfoManager.shared.token.value
            header["language"] = Locale.current.identifier
        }
        return header
    }
}
