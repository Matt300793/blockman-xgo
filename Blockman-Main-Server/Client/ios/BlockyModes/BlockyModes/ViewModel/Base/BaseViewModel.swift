//
//  BaseViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxSwift


class BaseViewModel: NSObject, ViewModelToViewOutputProvider, ViewModelMapper {
    
    private(set) var viewTitle = Variable("")
    
    class var mappedController: BaseViewController.Type {
        fatalError("Subclass must implement the <mappedController> property.")
    }
    
    var outputType: ViewModelToViewOutput.Type? { // ViewModelToViewOutputProvider
        return nil
    }
    
    let viewInput: ViewToViewModelInput
    required  init(viewInput: ViewToViewModelInput) {
        self.viewInput = viewInput
        super.init()
        
        initialize()
    }
    
    func initialize() { }
}
