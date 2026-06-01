//
//  DecorationShopViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/9.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DecorationShopViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return DecorationShopViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return DecorationShopOutput.self}
    
    private let decorationEntityHelper = DecorationEntityHelper()
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("title_decoration_shop", comment: "装饰商城")
    }
    
    // 根据装饰图片URL，找到对应的装饰
    public func fetchDecoration(ofThumbnailURLString URLString: String, in selectedDecorationsDict: [Int : DecorationShopEntity]) -> DecorationShopEntity? {
        return decorationEntityHelper.fetchDecoration(ofThumbnailURLString: URLString, inSubcategoryDecorationDict: selectedDecorationsDict)
    }
    
    // 获取当使用/卸下对应装饰时，左上角悬浮view对应位置的数据
    // 返回 相应的内容 跟 悬浮view 对应位置的索引
    public func categorySuspendViewContent(selectedDecoration: DecorationShopEntity, isUsing: Bool, completion: @escaping ((Any, Int)) -> Void) {
        if isUsing {
            decorationEntityHelper.decorationThumbnailURLStringContent(selectedDecoration, completion: completion)
        }else {
            decorationEntityHelper.decorationThumbnailDefaultContent(selectedDecoration, completion: completion)
        }
    }
    
    // 获取在装饰分类页切换时，左上角悬浮view的数据
    public func categorySuspendViewContents(category: Int, selectedDecorationsDict: [Int : DecorationShopEntity], completion: @escaping ([Any]) -> Void) {
        decorationEntityHelper.decorationThumbnailContents(inCategory: category, forSubcategoryDecorationDict: selectedDecorationsDict, completion: completion)
    }
    
    // 计算所选装饰的金币总价格
    public func calculateTotalGoldPrice(in selectedDecorationsDict: [Int : DecorationShopEntity]) -> Int {
        return selectedDecorationsDict.reduce(into: 0) { (total, tuple) in
            let (_, shopEntity) = tuple
            if shopEntity.priceType == DecorationShopEntity.PriceType.gold, !shopEntity.hasPurchased {
                total += Int(shopEntity.price)!
            }
        }
    }
    
    // 计算所选装饰的钻石总价格
    public func calculateTotalDiamondPrice(in selectedDecorationsDict: [Int : DecorationShopEntity]) -> Int {
        return selectedDecorationsDict.reduce(into: 0) { (total, tuple) in
            let (_, shopEntity) = tuple
            if shopEntity.priceType == DecorationShopEntity.PriceType.diamond, !shopEntity.hasPurchased {
                total += Int(shopEntity.price)!
            }
        }
    }
}

struct DecorationShopOutput: ViewModelToViewOutput {
    let decorationsOfCategory: Driver<[Int : [DecorationShopEntity]]>
    
    init(viewModel: BaseViewModel) {
        let decorationShopViewModel = viewModel as! DecorationShopViewModel
        let decorationShopInput = decorationShopViewModel.viewInput as! DecorationShopInput
        
        decorationsOfCategory = Driver.combineLatest(decorationShopInput.decorationCategoryInput, decorationShopInput.decorationNextPageInput) { (category, page) -> (Int, Int) in
            return (category, page)
            }.flatMap { tuple in
                let (category, page) = tuple
                return DecorationShopNetServer.fetchDecorations(typeID: category, currency: 0, inPage: page).map({ response -> [String : Any] in
                    return response["data"] as! [String : Any]
                }).mapModelArray(type: DecorationShopModel.self).map({ models -> [Int : [DecorationShopEntity]] in
                    let entities = models.map{ model -> DecorationShopEntity in
                        DecorationShopEntity.init(decorationShopModel: model)
                    }
                    return [category : entities]
                }).asDriver(onErrorJustReturn: [category : []])
        }
    }
}
