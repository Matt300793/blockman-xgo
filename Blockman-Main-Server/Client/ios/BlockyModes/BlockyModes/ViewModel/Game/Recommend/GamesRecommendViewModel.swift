//
//  GameViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/17.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class GamesRecommendViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return GamesRecommendViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return GamesRecommendOutput.self}
}

class GamesRecommendOutput: ViewModelToViewOutput {
    let recommendResults: Driver<SectionObject>
    let changeAnotherResults: Driver<SectionObject>
    let recentlyPlayResults: Driver<SectionObject>
    
    required init(viewModel: BaseViewModel) {
        let recommendViewModel = viewModel as! GamesRecommendViewModel
        let recommendInput = recommendViewModel.viewInput as! GamesRecommendInput
        
        recommendResults = recommendInput.refreshInput.flatMap({
            GamesNetServer.getRecommnedList().mapModelArray(type: GameModel.self).map({ models -> SectionObject in
                let entity = GamesRecommendTableCellEntity(title: R.string.localizable.section_recommend(), gameModels: models)
                return SectionObject(items: [entity])
            }).asDriver(onErrorJustReturn: SectionObject(items: [GamesRecommendTableCellEntity(title: R.string.localizable.recommend(), gameModels: [])]))
        })
        
        changeAnotherResults = recommendInput.changeAnothersInput.flatMap {
            GamesNetServer.getRecommnedList().mapModelArray(type: GameModel.self).map({ models -> SectionObject in
                let entity = GamesRecommendTableCellEntity(title: R.string.localizable.section_recommend(), gameModels: models)
                return SectionObject(items: [entity])
            }).asDriver(onErrorJustReturn: SectionObject(items: [GamesRecommendTableCellEntity(title: R.string.localizable.recommend(), gameModels: [])]))
        }
        
        recentlyPlayResults = recommendInput.refreshInput.flatMap {
            GamesNetServer.getRecentlyPlayList().mapModelArray(type: GameModel.self).map({ models -> SectionObject in
                let entity = GamesRecommendTableCellEntity(title: R.string.localizable.recently_playing(), gameModels: models)
                return SectionObject(items: [entity])
            }).asDriver(onErrorJustReturn: SectionObject(items: []))
        }
    }
}
