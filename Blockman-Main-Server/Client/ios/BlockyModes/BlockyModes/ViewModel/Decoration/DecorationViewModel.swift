//
//  DecorationViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2017/10/17.
//  Copyright © 2017年 SandboxOL. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class DecorationViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return DecorationViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return DecorationOutput.self}
    
    private let decorationEntityHelper = DecorationEntityHelper()
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("tab_title_decoration", comment: "装饰")
    }
    
    // 根据装饰图片URL，找到对应的装饰
    public func fetchDecoration(ofThumbnailURLString URLString: String, in selectedDecorationsDict: [Int : DecorationEntity]) -> DecorationEntity? {
        return decorationEntityHelper.fetchDecoration(ofThumbnailURLString: URLString, inSubcategoryDecorationDict: selectedDecorationsDict)
    }
    
    // 获取当使用/卸下对应装饰时，左上角悬浮view对应位置的数据
    // 返回 相应的内容 跟 悬浮view 对应位置的索引
    public func categorySuspendViewContent(selectedDecoration: DecorationEntity, isUsing: Bool, completion: @escaping ((Any, Int)) -> Void) {
        if isUsing {
            decorationEntityHelper.decorationThumbnailURLStringContent(selectedDecoration, completion: completion)
        }else {
            decorationEntityHelper.decorationThumbnailDefaultContent(selectedDecoration, completion: completion)
        }
    }
    
    // 获取在装饰分类页切换时，左上角悬浮view的数据
    public func categorySuspendViewContents(category: Int, selectedDecorationsDict: [Int : DecorationEntity], completion: @escaping ([Any]) -> Void) {
        decorationEntityHelper.decorationThumbnailContents(inCategory: category, forSubcategoryDecorationDict: selectedDecorationsDict, completion: completion)
    }
}

struct DecorationOutput: ViewModelToViewOutput {
    let decorationsCurrentUsing: Driver<[DecorationEntity]>
    let decorationsOfCategory: Driver<[DecorationEntity]>
    let decorationUpdateResult: Driver<BlockyResult>
    let decorationDeleteResult: Driver<BlockyResult>
    
    init(viewModel: BaseViewModel) {
        let decorationViewModel = viewModel as! DecorationViewModel
        let decorationInput = decorationViewModel.viewInput as! DecorationInput
        
        decorationsCurrentUsing = decorationInput.decorationCurrentUsing.flatMap { _ in
            DecorationNetServer.fetchCurrentUsingDecorations().mapModelArray(type: DecorationModel.self).map({
                $0.map({ (model) -> DecorationEntity in
                    DecorationEntity(decorationModel: model)
                })
            }).asDriver(onErrorJustReturn: [])
        }
        
        decorationsOfCategory = decorationInput.decorationCategoryInput.flatMap({ category in
            
            guard category != 6 else {
                return DecorationNetServer.fetchVIPDecorations(category: category).mapModelArray(type: DecorationModel.self).map({
                    $0.map({ (model) -> DecorationEntity in
                        DecorationEntity(decorationModel: model)
                    })
                }).asDriver(onErrorJustReturn: [])
            }
            
            guard category == 3 else {
                return DecorationNetServer.fetchDecorations(category: category).mapModelArray(type: DecorationModel.self).map({
                    $0.map({ (model) -> DecorationEntity in
                        DecorationEntity(decorationModel: model)
                    })
                }).asDriver(onErrorJustReturn: [])
            }
            
            if AccountInfoManager.shared.vip.value == 0 {
                return DecorationNetServer.fetchDecorations(category: category).mapModelArray(type: DecorationModel.self).map({
                    var entities = $0.map({ (model) -> DecorationEntity in
                        DecorationEntity(decorationModel: model)
                    })
                    entities.insert(DecorationEntity.defaultVIPCrown, at: 0)
                    return entities
                }).asDriver(onErrorJustReturn: [])
            }else {
                return DecorationNetServer.fetchDecorations(category: category).mapModelArray(type: DecorationModel.self).map({
                    $0.map({ (model) -> DecorationEntity in
                        DecorationEntity(decorationModel: model)
                    })
                })
                .asDriver(onErrorJustReturn: [])
                .filter({
                    !$0.isEmpty
                })
                .flatMap({ entites in
                    DecorationNetServer.fetchVIPDecorations(category: category).mapModelArray(type: DecorationModel.self).map({ (models) -> [DecorationEntity] in
                        var vEntities = entites
                        vEntities.insert(DecorationEntity(decorationModel: models.first ?? DecorationModel.defaultVIPCrown), at: 0)
                        return vEntities
                    }).asDriver(onErrorJustReturn: entites)
                })
            }
        })
        
        decorationUpdateResult = decorationInput.decorationUpdateInput.flatMap({ decorationID in
            DecorationNetServer.updateUsingDecoration(id: decorationID).map({ _ -> BlockyResult in
                .success
            }).asDriver(onErrorRecover: { error in
                Driver.just(.fail(error as! BlockyError))
            })
        })
        
        decorationDeleteResult = decorationInput.decorationDeleteInput.flatMap({ decorationID in
            DecorationNetServer.deleteUsingDecoration(id: decorationID).map({ _ -> BlockyResult in
                .success
            }).asDriver(onErrorRecover: { error in
                Driver.just(.fail(error as! BlockyError))
            })
        })
    }
}
