//
//  GameCollectionCellEntity.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/4.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

struct GameCollectionCellEntity: ItemEntityConfigurable {

    let gameId: String
    let gameTitle: String
    let appreciationNumber: String
    let playingNumber: String
    let gameCategory: String
    let gameThumbnail: String
    
    let itemSize: CGSize
    
     init(gameModel: GameModel) {
        gameId = gameModel.gameId
        gameTitle = gameModel.gameTitle
        appreciationNumber = String(gameModel.praiseNumber)
        playingNumber = String(gameModel.onlineNumber) + NSLocalizedString("playing", comment: "在玩")
        var categoryString = ""
        let categoryCount = gameModel.gameTypes.count
        switch categoryCount {
        case 0:
            break
        case 1:
            categoryString = gameModel.gameTypes.last!
        default:
            for index in 0..<gameModel.gameTypes.count - 1 {
                categoryString = gameModel.gameTypes[index] + " | "
            }
            categoryString += gameModel.gameTypes.last!
        }
        gameCategory = categoryString
        gameThumbnail = gameModel.gameCoverPic
        
        let width = (UIScreen.main.bounds.width - 2 * margin_16 - 2) / 2
        itemSize = CGSize(width: width, height: width)
    }
}

