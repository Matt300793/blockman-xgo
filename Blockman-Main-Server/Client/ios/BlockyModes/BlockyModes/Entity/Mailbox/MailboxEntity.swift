//
//  MailboxEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

class MailAttachmentEntity {
    let iconURLString: String
    let id: String
    let name: String
    let qty: Int
    let type: Int
    var isRecevied: Bool = false
    
    init(model: MailAttachmentModel) {
        id = model.itemId
        name = model.name
        type = model.type
        iconURLString = model.icon
        qty = model.qty
    }
}

class MailboxEntity: ItemEntityConfigurable {
    
    enum Status: Int {
        case send = 1
        case read = 2
        case deleted = 3
    }
    
    let itemHeight: CGFloat = 70
    
    var status: Status
    let attachments: [MailAttachmentEntity]
    let content: String
    let id: Int64
    let sendDate: String
    let title: String
    
    init(model: MailboxModel) {
        id = model.id
        title = model.title
        sendDate = Date.init(timeIntervalSince1970: model.sendDate / 1000).convertToString(formatter: "yyyy-MM-dd")
        content = model.content
        status = Status(rawValue: model.status) ?? .send
        attachments = model.attachment.map({
            let attach = MailAttachmentEntity(model: $0)
            attach.isRecevied = model.status == 2
            return attach
        })
    }
    
    public func updateStatus(_ status: MailboxEntity.Status) {
        self.status = status
        if status == .read {
            attachments.forEach({
                $0.isRecevied = true
            })
        }
    }
}
