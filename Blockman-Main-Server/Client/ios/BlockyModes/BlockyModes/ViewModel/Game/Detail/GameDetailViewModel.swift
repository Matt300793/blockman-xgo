//
//  GameDetailViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/11/3.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class GameDetailViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return GameDetailViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return GameDetailOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("title_games_detail", comment: "游戏详情")
    }
}

struct GameDetailOutput: ViewModelToViewOutput {
    let gameDetailInfo: Driver<GameDetailEntity?>
    let enterGame: Driver<(String, String, Int64, String, String, String)?>
    
    init(viewModel: BaseViewModel) {
        let detailViewModel = viewModel as! GameDetailViewModel
        let detailInput = detailViewModel.viewInput as! GameDetailInput
        
        gameDetailInfo = detailInput.gameIdInput.flatMap {
            GamesNetServer.getGameDetailInfo(gameId: $0).mapModel(type: GameDetailModel.self).map({ gameDetailModel -> GameDetailEntity in
                detailViewModel.viewTitle.value = gameDetailModel.gameTitle
                return GameDetailEntity(gameDetailModel: gameDetailModel)
            }).asDriver(onErrorJustReturn: nil)
        }
        
        enterGame = detailInput.enterGameInput.flatMap { gameType in
            GamesNetServer.fetchGameToken(gameType: gameType).asDriver(onErrorJustReturn: [:])
            }.flatMap({ (response) -> SharedSequence<DriverSharingStrategy, [String : Any]> in
                if response.isEmpty {
                    return Driver.just([:])
                }
                var dictionary = response["data"] as! [String : Any]
                return GamesNetServer.enterGame(token: dictionary["token"] as! String).map({ gameInfo in
                    let info = gameInfo["data"] as! [String : Any] // 合并两次请求结果
                    dictionary += info
                    return dictionary
                }).asDriver(onErrorJustReturn: [:])
            }).map { (totalInfo) -> (String, String, Int64, String, String, String)? in
                guard !totalInfo.isEmpty else {
                    return nil
                }
                // 提取所需数据
                let nickName = totalInfo["name"] as! String
                let signature = totalInfo["signature"] as! String
                let timestamp = totalInfo["timestamp"] as! Int64
                let gameAddr = totalInfo["gaddr"] as! String
                let mapName = totalInfo["mname"] as! String
                let mapURL = totalInfo["downurl"] as! String
                return (nickName, signature, timestamp, gameAddr, mapName, mapURL)
            }
    }
}
