//
//  NavigationProtocol.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/15.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

protocol NavigationProtocol {
    
    func pushViewModel(_ viewModel: BaseViewModel.Type, params: Any?, animated: Bool)
    
    func popViewModel(animated: Bool)
    
    func popToRootViewModel(animated: Bool)
    
    func presentViewModel(_ viewModelToPresent: BaseViewModel.Type, params: Any?, animated: Bool, completion: (() -> Swift.Void)?)
    
    func dismissViewModel(animated: Bool, completion: (() -> Swift.Void)?)
    
    func resetRootViewModel(_ viewModel: BaseViewModel.Type)
}
