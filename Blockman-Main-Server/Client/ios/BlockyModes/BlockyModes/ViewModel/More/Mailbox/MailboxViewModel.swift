//
//  MailboxViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/3/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class MailboxViewModel: BaseViewModel {
    override static var mappedController: BaseViewController.Type {return MailboxViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return MailboxOutput.self}
    
    override func initialize() {
        viewTitle.value = R.string.localizable.mailbox()
    }
}

struct MailboxOutput: ViewModelToViewOutput {
    let mailResults: Driver<SectionObject>
    let clearMailsResult: Driver<Bool>
    
    init(viewModel: BaseViewModel) {
        let mailsInput = viewModel.viewInput as! MailboxInput
        mailResults = mailsInput.refreshMailsInput.flatMapLatest { _ in
            MailboxNetServer.fetchMailsList().mapModelArray(type: MailboxModel.self).map({ models -> SectionObject in
                let entities = models.map({ model -> MailboxEntity in
                    let json = model.toJSON()
                    return MailboxEntity(model: model)
                })
                return SectionObject(items: entities)
            })
            .asDriver(onErrorJustReturn: SectionObject(items: []))
        }
        
        clearMailsResult = mailsInput.clearMailsInput.flatMapLatest({
            MailboxNetServer.updateMailStatus(.deleted, mailIDs: $0).map({ _ in
                true
            })
            .asDriver(onErrorJustReturn: false)
        })
    }
}
