//
//  DailyTaskEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import Foundation

struct TaskItemEntity: ItemEntityConfigurable {
    
    let count: String
    let status: Int
    let type: Int
    
    init(model: TaskItem) {
        status = model.status
        type = model.type
        count = "\(model.count)"
    }
}

struct DailyTaskEntity {
    let updateTime: String
    let tasks: [TaskItemEntity]
    
    init(model: DailyTaskModel) {
        updateTime = R.string.localizable.daily_reward_update_after_time(String(format: "%02d:%02d:%02d", model.hours, model.minutes, model.seconds))
        tasks = model.tasks.map({
            TaskItemEntity(model: $0)
        })
    }
    
    public static var `default`: DailyTaskEntity {
        get {
            return DailyTaskEntity(model: DailyTaskModel())
        }
    }
}
