//
//  MailContentViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class MailContentViewModel: BaseViewModel {
    
    override var outputType: ViewModelToViewOutput.Type? {return MailContentOutput.self}
    
    override static var mappedController: BaseViewController.Type {return MailContentViewController.self}
}

struct MailContentOutput: ViewModelToViewOutput {
    let updateStautsResult: Driver<(MailboxEntity.Status, Bool)>
    let receiveAttachResult: Driver<Bool>
    
    init(viewModel: BaseViewModel) {
        let mailContentInput = viewModel.viewInput as! MailContentInput
        updateStautsResult = mailContentInput.updateMailStatusInput.flatMapLatest {
            let (status, mailID) = $0
            return MailboxNetServer.updateMailStatus(status, mailIDs: [mailID]).map({_ in
                (status, true)
            }).asDriver(onErrorJustReturn: (status, false))
        }
        
        receiveAttachResult = mailContentInput.receiveAttachInput.flatMapLatest({
            MailboxNetServer.receiveAttachments($0).map({ _ in
                true
            }).asDriver(onErrorJustReturn: false)
        })
    }
}
