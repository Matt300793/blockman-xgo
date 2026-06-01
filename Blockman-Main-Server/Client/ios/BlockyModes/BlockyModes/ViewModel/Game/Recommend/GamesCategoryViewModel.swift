//
//  GamesCategoryViewModel.swift
//  BlockyModes
//
//  Created by KiBen Hung on 2017/10/31.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa

class GamesCategoryViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return GamesCategoryViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return GamesCategoryOutput.self}
}

struct GamesCategoryOutput: ViewModelToViewOutput {
    let gamesResult: Driver<SectionObject>
    
    init(viewModel: BaseViewModel) {
        let categoryInput = viewModel.viewInput as! GamesCategoryInput
        
        gamesResult = categoryInput.filterConditionInput.flatMapLatest {
            GamesNetServer.getCategoryList(category: $0.0, sortType: $0.1, page: $0.2).map({ response -> [String : Any] in
                response["data"] as! [String : Any]
            })
            .mapModelArray(type: GameModel.self)
            .map({ models -> [ItemEntityConfigurable] in
                models.map({ GameCollectionCellEntity(gameModel: $0) })
            })
            .map({
                SectionObject(items: $0)
            })
            .asDriver(onErrorJustReturn: SectionObject(items: []))
        }
    }
}
