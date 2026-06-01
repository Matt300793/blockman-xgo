//
//  DecorationShoppingCartViewModel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/15.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit
import RxCocoa

class DecorationShoppingCartViewModel: BaseViewModel {
    override class var mappedController: BaseViewController.Type {return DecorationShoppingCartViewController.self}
    
    override var outputType: ViewModelToViewOutput.Type? {return DecorationShoppingCartOutput.self}
    
    override func initialize() {
        viewTitle.value = NSLocalizedString("title_shopping_cart", comment: "购物车")
    }
    
    public func originPriceAttributedText(golds: Int, diamons: Int) -> NSAttributedString {
        return priceAttributedText(golds: golds, diamons: diamons, isOrigin: true)
    }
    
    public func discountPriceAttributedText(golds: Int, diamons: Int) -> NSAttributedString {
        return priceAttributedText(golds: golds, diamons: diamons, isOrigin: false)
    }
    
    private func priceAttributedText(golds: Int, diamons: Int, isOrigin: Bool) -> NSAttributedString {
        let goldAttachment = NSTextAttachment()
        goldAttachment.image = R.image.common_gold()
        let diamondAttachment = NSTextAttachment()
        diamondAttachment.image = R.image.common_diamond()
        let spaceAttributedText = NSAttributedString(string: " ")
        let originAttributes = [NSForegroundColorAttributeName : isOrigin ? R.color.appColor._555555() : R.color.appColor._d62121(), NSFontAttributeName : isOrigin ? UIFont.size14 : UIFont.size16]
        let goldPriceAttributedText = NSMutableAttributedString(string: "\(golds)", attributes: originAttributes)
        let diamondPriceAttributedText = NSMutableAttributedString(string: "\(diamons)", attributes: originAttributes)
        if AccountInfoManager.shared.vip.value >= 2 {
            if isOrigin {
                let strikeAttribute = [NSBaselineOffsetAttributeName : 0, NSStrikethroughColorAttributeName : R.color.appColor._555555(), NSStrikethroughStyleAttributeName : 2] as [String : Any]
                goldPriceAttributedText.addAttributes(strikeAttribute, range: NSMakeRange(0, "\(golds)".count))
                diamondPriceAttributedText.addAttributes(strikeAttribute, range: NSMakeRange(0, "\(diamons)".count))
            }
        }else if !isOrigin {
            return NSAttributedString(string: R.string.localizable.shop_car_vip_discount_tips(), attributes: originAttributes)
        }
        var string = ""
        if isOrigin {
            string = R.string.localizable.decoration_shopcart_total()
        }else {
            switch AccountInfoManager.shared.vip.value {
            case 2:
                string = NSLocalizedString("shop_car_vip_plus_discount", comment: "")
            case 3:
                string = NSLocalizedString("shop_car_mvp_discount", comment: "")
            default:
                break
            }
        }
        let priceAttributedText = NSMutableAttributedString(string: string, attributes: originAttributes)
        priceAttributedText.append(NSAttributedString(attachment: goldAttachment))
        priceAttributedText.append(spaceAttributedText)
        priceAttributedText.append(goldPriceAttributedText)
        priceAttributedText.append(spaceAttributedText)
        priceAttributedText.append(NSAttributedString(attachment: diamondAttachment))
        priceAttributedText.append(spaceAttributedText)
        priceAttributedText.append(diamondPriceAttributedText)
        return priceAttributedText
    }
}

struct DecorationShoppingCartOutput: ViewModelToViewOutput {
    
    let purchaseResult: Driver<(Int, Int, [Int])>
    
    init(viewModel: BaseViewModel) {
        let shopCartViewModel = viewModel as! DecorationShoppingCartViewModel
        let shopCartInput = shopCartViewModel.viewInput as! DecorationShoppingCartInput
        
        purchaseResult =  shopCartInput.decorationIDsInput.flatMapLatest {
            DecorationShopNetServer.purchase(decorationIDs: $0).map({ response -> (Int, Int, [Int]) in
                let dataDict = response["data"] as! [String : Any]
                let diamondsNeed = dataDict["diamondsNeed"] as! Int // 还差多少钻石；默认为0，表示钻石充足
                let goldsNeed = dataDict["goldsNeed"] as! Int // 还差多少金币；默认为0，表示金币充足
                let IDs: [Int] = []
                var failProductIDs: [Int] = []
                guard let productDict = dataDict["decorationPurchaseStatus"] as? [String : Bool] else {
                    return (diamondsNeed, goldsNeed, failProductIDs)
                }
                failProductIDs = productDict.reduce(into: IDs, { (result, tuple) in
                    let (productID, isSuccessful) = tuple
                    if !isSuccessful {
                        result.append(Int(productID)!)
                    }
                })
                return (diamondsNeed, goldsNeed, failProductIDs)
            }).asDriver(onErrorJustReturn: (-1, -1, []))
        }
    }
}
