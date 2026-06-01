//
//  GameDetailEntity.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/11/5.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation

class GameDetailEntity {
    
    let gameId: String
    let gameTitle: String
    let appreciationNumber: String
    let gameCategory: String
    let gameIntroduction: String
    let gameThumbnails: [String]
    let isAppreciated: Bool
    
    required init(gameDetailModel: GameDetailModel) {
        gameId = gameDetailModel.gameId
        gameTitle = gameDetailModel.gameTitle
        appreciationNumber = String(gameDetailModel.praiseNumber)
        isAppreciated = gameDetailModel.appreciate
        var categoryString = ""
        let categoryCount = gameDetailModel.gameTypes.count
        switch categoryCount {
        case 0:
            break
        case 1:
            categoryString = gameDetailModel.gameTypes.last!
        default:
            for index in 0..<gameDetailModel.gameTypes.count - 1 {
                categoryString = gameDetailModel.gameTypes[index] + " | "
            }
            categoryString += gameDetailModel.gameTypes.last!
        }
        gameCategory = categoryString
        gameIntroduction = gameDetailModel.gameDetail
        gameThumbnails = gameDetailModel.bannerPic
    }

}
