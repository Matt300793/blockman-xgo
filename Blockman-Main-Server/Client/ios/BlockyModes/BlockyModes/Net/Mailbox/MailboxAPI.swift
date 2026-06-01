//
//  MailboxAPI.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import Moya

let mailboxPathPrefix = "/mailbox"

enum Mailbox {
    case fetchMails()
    case updateMailStatus(Int, [Int64])
    case receiveAttachment(Int64)
}

extension Mailbox: TargetType {
    var baseURL: URL {
        return URL.init(string: serverHost)!
    }
    
    var path: String {
        switch self {
        case .fetchMails(), .updateMailStatus(_, _):
            return "\(mailboxPathPrefix)/api/v1/mail"
        case .receiveAttachment(_):
            return "\(mailboxPathPrefix)/api/v1/mail/attachment"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMails():
            return .get
        default:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .fetchMails():
            return .requestPlain
        case let .updateMailStatus(status, mailIDs):
            return .requestParameters(parameters: ["status" : status, "ids" : mailIDs], encoding: URLQueryArrayEncoding.default)
        case let .receiveAttachment(mailID):
            return .requestParameters(parameters: ["mailId" : mailID], encoding: URLEncoding.queryString)
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
