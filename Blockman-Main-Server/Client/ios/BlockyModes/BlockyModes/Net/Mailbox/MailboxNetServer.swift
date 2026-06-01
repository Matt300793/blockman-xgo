//
//  MailboxNetServer.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift

class MailboxNetServer {
    public static func fetchMailsList() -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Mailbox.fetchMails(), showToast: false)
    }
    
    public static func updateMailStatus(_ status: MailboxEntity.Status, mailIDs: [Int64]) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Mailbox.updateMailStatus(status.rawValue, mailIDs), showToast: status == .deleted)
    }
    
    public static func receiveAttachments(_ mailID: Int64) -> Single<[String : Any]> {
        return NetServer.requestWithTarget(Mailbox.receiveAttachment(mailID), showToast: true)
    }
}
