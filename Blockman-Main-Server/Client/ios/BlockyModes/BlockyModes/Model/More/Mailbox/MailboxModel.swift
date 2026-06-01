//
//  MailboxModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import HandyJSON

/*
 "attachment": [
 {
 "icon": "string",
 "itemId": "string",
 "name": "string",
 "qty": 0,
 "type": 0 // 附件类型，1，表示金币或者砖石
 }
 ],
 "content": "string",
 "id": 0,
 "sendDate": "2018-03-09T04:11:12.256Z",
 "status": 0,  // 邮件状态，1，表示已发送；2，表示已读； 3，表示已删除
 "title": "string",
 "type": 0  // 邮件类型，默认为0，表示普通邮件；1，表示系统邮件
 */

struct MailAttachmentModel: HandyJSON {
    var icon: String = ""
    var itemId: String = ""
    var name: String = ""
    var qty: Int = 0
    var type: Int = 0
}

struct MailboxModel: HandyJSON {
    var attachment: [MailAttachmentModel] = []
    var content: String = ""
    var id: Int64 = 0
    var sendDate: Double = 0
    var status: Int = 0
    var title: String = ""
    var type: Int = 0
}
