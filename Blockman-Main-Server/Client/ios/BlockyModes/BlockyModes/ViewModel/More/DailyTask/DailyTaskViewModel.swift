//
//  DailyTaskViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/6.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class DailyTaskViewModel: BaseViewModel {
    
    override var outputType: ViewModelToViewOutput.Type? {return DailyTaskOutput.self}
    
    override static var mappedController: BaseViewController.Type {return DailyTaskViewController.self}

}

struct DailyTaskOutput: ViewModelToViewOutput {
    let dailyTasks: Driver<DailyTaskEntity>
    let signInResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let taskInput = viewModel.viewInput as! DailyTaskInput
        
        dailyTasks = taskInput.fetchTasksInput.flatMapLatest({
            UserNetServer.fetchDailyTasks().mapModel(type: DailyTaskModel.self).map({
                DailyTaskEntity(model: $0)
            }).asDriver(onErrorJustReturn: DailyTaskEntity.default)
        })
        
        signInResult = taskInput.taskTypeInput.flatMapLatest({
            UserNetServer.signInDailyTask(type: $0).map({ (response) -> BlockyResult in
                let data = response["data"] as! [String : Any]
                let golds = data["golds"] as! Int
                AccountPropertyManager.shared.updateGolds(golds)
                return .success
            })
            .asDriver(onErrorRecover: { (error) in
                Driver.just(.fail(error as! BlockyError))
            })
        })
    }
}
