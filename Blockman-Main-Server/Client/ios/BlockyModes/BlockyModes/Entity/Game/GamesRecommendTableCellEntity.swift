//
//  GamesRecommendCellEntity.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/1.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

struct GamesRecommendTableCellEntity: ItemEntityConfigurable {
    
    let title: String
    let games: [GameModel]
    
    let itemHeight: CGFloat
    
    init(title: String, gameModels: [GameModel]) {
        self.title = title
        games = gameModels
        
        if title == R.string.localizable.section_recommend() {
            guard games.count != 0 else {itemHeight = 130; return}
            let itemW = (UIScreen.main.bounds.width - 2 * 16.0 - 2) / 2
            itemHeight = 2 * itemW + 45
        }else {
            guard games.count != 0 else {
                itemHeight = 0
                return
            }
            itemHeight = 206
        }
    }
}

