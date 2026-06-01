//
//  GamesPageViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/31.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

class GamesPageViewModel: BaseViewModel {
    
    override class var mappedController: BaseViewController.Type {return GamesPageViewController.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("tab_title_games", comment: "游戏")
    }
}
