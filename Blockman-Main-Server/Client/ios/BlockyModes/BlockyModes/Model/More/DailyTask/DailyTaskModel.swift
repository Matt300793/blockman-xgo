//
//  DailyTaskModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation
import HandyJSON

/*
 "hours": 0,
 "minutes": 0,
 "seconds": 0,
 "tasks": [
    {
        "count": 0,
        "currency": 0, // 货币类型：1，表示为砖石；2，表示金币
        "status": 0, // 领取状态：0，表示可领取；1，表示已领取；4，表示没有资格领取
        "type": 0 // 每日任务信息,为1时，表示领取金币的任务；为3，表示看广告的任务
    }
 ]
 */

struct TaskItem: HandyJSON {
    var count:Int = 0
    var currency:Int = 0
    var status:Int = 0
    var type:Int = 0
}

struct DailyTaskModel: HandyJSON {
    var hours:Int = 0
    var minutes:Int = 0
    var seconds:Int = 0
    var tasks: [TaskItem] = []
}
