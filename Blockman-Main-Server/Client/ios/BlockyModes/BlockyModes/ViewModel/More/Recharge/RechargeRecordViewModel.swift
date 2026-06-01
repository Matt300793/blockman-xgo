//
//  RechargeRecordViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/17.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class RechargeRecordViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return RechargeRecordViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return RechargeRecordOutput.self}
}

struct RechargeRecordOutput: ViewModelToViewOutput {
    let recordResults: Driver<SectionObject>
    
    init(viewModel: BaseViewModel) {
        let recordViewModel = viewModel as! RechargeRecordViewModel
        let recordInput = recordViewModel.viewInput as! RechargeRecordInput
        
        recordResults = recordInput.currentPageInput.flatMapLatest {
            RechargeNetServer.fetchRecords(page: $0).map({ response -> [String : Any] in
                return response["data"] as! [String : Any]
            })
            .mapModelArray(type: RechargeRecordModel.self)
            .map({ (models) -> [ItemEntityConfigurable] in
                models.map({
                    RechargeRecordEntity(recordModel: $0)
                })
            })
            .map({
                SectionObject(items: $0)
            })
            .asDriver(onErrorJustReturn: SectionObject(items: []))
        }
    }
}
